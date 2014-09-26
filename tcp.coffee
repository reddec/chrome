###
# Wrapper of ChromePackaged API - TCPSocket (client)
#
# TODO: Human readable error codes
# TODO: Refactor
#
# Author: RedDec <net.dev@mail.ru>
# 25 Sep 2014
###


##
# TCP client socket reader. Used automatically
#
tcp_reader = ()->
  data = new EventProvider()
  error = new EventProvider()
  chrome.sockets.tcp.onReceive.addListener (info)=>
    data.emit info.socketId, info.data

  chrome.sockets.tcp.onReceiveError.addListener (info)=>
    error.emit(info.socketId, info.resultCode) if info

  return {data: data, error: error}

##
# TCP Socket (client) wrapper for chrome packaged
# app API
#
class TcpSocket extends EventProvider
  @api = tcp_reader()

  ##
  # Create new instance of TcpSocket
  # Publice variables:
  # * paused [boolean] - is socket disabled for receiving messages
  # * closed [boolean] - has been socket closed
  # * connected [boolean] - is socket connected to peer
  #
  # @param socketId [Integer] - Socket file descriptor
  constructor:(@socketId)->
    super()
    @connected = false
    @paused = true
    @closed = false

  ##
  # Enables or disables the application from receiving messages from its peer.
  # Automatically sets to true when connection established.
  # @param state [boolean] - Pause state
  # @done [function(TcpSocket)] - Done callback
  #
  pause: (state, done)=>
    chrome.sockets.tcp.setPaused @socketId, state, ()->
      done this if done

  ##
  # Close TcpSocket. Emits 'disconnect' and 'close' events.
  # Do nothing if not connected, but callback will be invoked.
  # @done [function(TcpSocket)] - Done callback
  close:(done)=>
    if not @closed
      @disconnect ()=>
        @closed = true
        chrome.sockets.tcp.close @socketId, ()=>
          @connected = false
          TcpSocket.api.data.removeListener @tel_id
          TcpSocket.api.error.removeListener @tdl_id
          done this if done
          @emit 'close'
    else
      done this if done

  ##
  # Send data to peer. Emits 'error' if socket is not connected
  # @param data [ArrayBuffer | Object] - Message
  # @done [function(info)] - Done callback
  send: (data, done)=>
    if @connected
      data = if data instanceof ArrayBuffer then data else str2ab(data.toString())
      chrome.sockets.tcp.send @socketId, data, (info)=>
        if not info
          @emit 'error', -3, chrome.runtime.lastError, 'send1'
        else
          @emit('error', info.resultCode, chrome.runtime.lastError, 'send2') if info.resultCode < 0
          done info if done
    else
      @emit 'error', -1, 'ERR:: Socket is not connected', 'send3'

  ##
  # Connect to remote address.
  # Emits 'error' if connection failed.
  # Emits 'connect' if connection established.
  # @param host [string] - remote domain or ip
  # @param port [integer] - remote port number
  # @done [function(TcpSocket)] - Done callback if connected
  connect: (host, port, done)=>
    chrome.sockets.tcp.connect @socketId, host, port, (code)=>
      @connected = code >= 0
      @tdl_id = TcpSocket.api.data.on @socketId, @_data
      @tel_id = TcpSocket.api.error.on @socketId, @_error
      if not @connected
        @emit 'error', code, chrome.runtime.lastError, 'connect'
      else
        @pause @connected, ()=>
          @emit( 'connect', this) if @connected
          done(this) if done

  ##
  # Shutdown connection. Emits 'error' if socket is not connected.
  # Emits 'disconnect' if connection shutdowned.
  # @done [function(TcpSocket)] - Done callback
  disconnect: (done) ->
    if @connected
      chrome.sockets.tcp.disconnect @socketId, ()=>
        @connected = false
        @emit 'disconnect'
    else
      console.log 'error', -1, 'ERR:: Socket is not connected', 'disconnect'
    done this if done

  ##
  # Get socket info. Emits 'error' if socket not connected.
  # Info (https://developer.chrome.com/apps/sockets_tcp#type-SocketInfo):
  # * socketId [integer]
  # * localAddress [string]
  # * localPort [integer]
  # * peerAddress [string]
  # * peerPort [integer]
  # * ...
  # @done [function(info)] - Done callback
  info: (done)->
    if done and @connected
      chrome.sockets.tcp.getInfo @socketId, (info)=>
        return info
    else if done and not @connected
      @emit 'error', -1, 'ERR:: Socket is not connected', 'info'

  _data:(data)=> @emit 'data', data

  _error:(code)=>
    if code != -15 # Disconnect
      # setTimeout(f, 0) - pushes execution to end of JS event queue.
      # Required for processing all events before close socket
      setTimeout ()=>
        (@emit 'error', code,  new Error(chrome.runtime.lastError or code), '_error')
      ,0
    @close()

  ##
  # Create new TcpSocket
  # @done [function(info)] - Done callback
  @create:(done)=>
    chrome.sockets.tcp.create (fd)=> done new TcpSocket fd.socketId
