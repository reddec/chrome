
##
# TCP server socket reader. Used automatically
#
server_reader = ()->
  accept = new EventProvider()
  error = new EventProvider()

  chrome.sockets.tcpServer.onAccept.addListener (info)=>
    accept.emit info.socketId, info.clientSocketId

  chrome.sockets.tcpServer.onAcceptError.addListener (info)=>
    error.emit(info.socketId, info.resultCode) if info

  return {accept: accept, error: error}

##
# TCP Socket (server) wrapper for chrome packaged
# app API
#
class TcpServer extends EventProvider
  @api = server_reader()

  ##
  # Create new instance of TcpSocketServer
  # @param socketId [integer] - Socket descriptor
  #
  constructor:(@socketId)->
    super()

  ##
  # Creates new instance of socket and wrap it to TcpServer
  # @param done [function(TcpServer)] - Done callback
  #
  @create: (done)->
    chrome.sockets.tcpServer.create (createInfo)=>
      done(new TcpServer(createInfo.socketId)) if done

  ##
  # Retrieves the list of currently opened sockets owned by the application.
  # See: https://developer.chrome.com/apps/sockets_tcpServer#type-SocketInfo
  # @param done [function(List<SocketInfo>)] - Done callback
  #
  @sockets:(done)=>
    chrome.sockets.tcpServer.getSockets (socketsInfo)=>
      done(socketsInfo) if done
  ##
  # Set pause state
  # @param paused [boolean] - Enable pause or not
  # @param done [function(TcpServer)] - Done callback
  #
  pause:(paused, done)=>
    chrome.sockets.tcpServer.setPaused @socketId, paused, ()=>
      done(this) if done

  ##
  # Setup socket in listen mode and start accepting clients.
  # Emits 'listen' on success.
  # @param address [string] - Bind host name or ip
  # @param port [integer] - Bind port number
  # @param backlog [integer] (default = 1) - Clients queue size
  # @param done [function(TcpServer)] - Done callback
  # @param unpause [boolean](default = true) - Unpause socket
  #
  listen:(address, port, backlog=1, done, unpause=true)=>
    chrome.sockets.tcpServer.listen @socketId, address, port, backlog, (result)=>
      if result<0
        @emit 'error', result, chrome.runtime.lastError, 'listen'
        done(this, false) if done
      else
        @_acc = TcpServer.api.accept.on(@socketId, @_accept)
        @_ace = TcpServer.api.error.on(@socketId, @_error)
        @emit 'listen', this
        if unpause
          @pause false, ()=>
            done(this, true) if done
        else
          done(this, true) if done

  ##
  # Stop listening and close all child sockets
  # @param done [function(TcpServer)] - Done callback
  #
  disconnect: (done)=>
    chrome.sockets.tcpServer.disconnect @socketId, ()=>
      TcpServer.api.accept.removeListener(@_acc) if @_acc
      TcpServer.api.error.removeListener(@_ace) if @_ace
      @emit 'disconnect', this
      done(this) if done

  ##
  # Destroy socket
  # @param done [function(TcpServer)] - Done callback
  #
  close:(done)=>
    @disconnect ()=>
      chrome.sockets.tcpServer.close @socketId, ()=>
        @emit 'close', this
        done(this) if done

  ##
  # Get socket info.
  # See: https://developer.chrome.com/apps/sockets_tcpServer#type-SocketInfo
  # @param done [function(SocketInfo, TcpServer)] - Done callback
  #
  info:(done)=>
    if done
      chrome.sockets.tcpServer.getInfo @socketId, (info)=>
        done(info, this)



  _error:(code)=>
    @emit 'error', code, new Error(code), 'acceptError'

  _accept:(client)=>
    s = new TcpSocket(client)
    s.connected = true
    @emit 'accept', s

window.rdd.TcpServer = TcpServer # Export
