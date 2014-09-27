##
# UDP socket reader. Used automatically
#
udp_reader=()=>
  data = new EventProvider()
  error = new EventProvider()
  chrome.sockets.udp.onReceive.addListener (info)=>
    data.emit info.socketId, info.data, info.remoteAddress, info.remotePort

  chrome.sockets.udp.onReceiveError.addListener (info)=>
    error.emit(info.socketId, info.resultCode) if info

  return {data: data, error: error}

##
# UDP Socket wrapper for chrome packaged
# app API
#
# Example:
#
# UdpSocket.create (sock)=>
#   sock.on 'error', (code, err, from)->
#     console.log 'Error', code, from, err
#   sock.on 'data', (chunk, addr, port)->
#     console.log 'Data', ab2str8(chunk), 'from', addr, port
#
#   sock.bind '0.0.0.0', 0, ()=>
#     console.log 'Bound'
#     sock.info (info)=>
#       console.log 'Info', info
#       sock.send 'Hello world!', '127.0.0.1', info.localPort
#
class UdpSocket extends EventProvider
  @api = udp_reader()

  ##
  # Creates new instance of socket and wrap it to UdpSocket
  # @param done [function(UdpSocket)] - Done callback
  #
  @create:(done)->
    chrome.sockets.udp.create (createInfo)=>
      done(new UdpSocket(createInfo.socketId)) if done

  ##
  # Retrieves the list of currently opened sockets owned by the application.
  # See: https://developer.chrome.com/apps/sockets_udp#method-getSockets
  # @param done [function(List<SocketInfo>)] - Done callback
  #
  @sockets: (done)->
    chrome.sockets.udp.getSockets (socks)=>
      done(socks) if done

  ##
  # Create new instance of UdpSocket
  # @param socketId [integer] - Socket descriptor
  #
  constructor:(@socketId)->
    super()
    @_dta = UdpSocket.api.data.on @socketId, @_data
    @_err = UdpSocket.api.error.on @socketId, @_error

  ##
  # Updates the socket properties.
  # See: https://developer.chrome.com/apps/sockets_udp#method-update
  # @param properties [SocketProperties] - The properties to update.
  # @param done [function(UdpSocket)] - Done callback
  #
  update:(properties, done)->
    chrome.sockets.udp.update @socketId, properties, ()=>
      done(this) if done

  ##
  # Pauses or unpauses a socket. A paused socket is not recieving data
  # @param state [boolean] - Pause or not
  # @param done [function(UdpSocket)] - Done callback
  #
  pause: (state, done)->
    chrome.sockets.udp.setPaused @socketId, state, ()=>
      done(this) if done

  ##
  # Binds the local address and port for the socket.
  # For a client socket, it is recommended to use port 0 to let
  # the platform pick a free port.
  # @param address [string] - IP or address of machine
  # @param port [integer] - port number
  # @param done [function(UdpSocket)] - Done callback
  # @param unpause [boolean] (default = true) - Automatic unpause socket
  #
  bind: (address, port, done, unpause=true)->
    chrome.sockets.udp.bind @socketId, address, port, (result)=>
      if result < 0
        @emit 'error', result, chrome.runtime.lastError, 'bind'
        done(this, false) if done
      else
        @emit 'bind', address, port
        @pause !unpause, ()=>
          done(this, true) if done

  ##
  # Sends data on the given socket to the given address and port.
  # The socket must be bound to a local port before calling this method.
  # @param data [ArrayBuffer | String] - Message to send
  # @param address [string] - IP or address of target machine
  # @param port [integer] - port number
  # @param done [function(UdpSocket)] - Done callback
  #
  send: (data, address, port, done)->
    data = if data instanceof ArrayBuffer then data else str2ab data.toString()
    chrome.sockets.udp.send @socketId, data, address, port, (info)=>
      if info.resultCode < 0
        @emit 'error', info.resultCode, chrome.runtime.lastError, 'send'
      done(this, info.bytesSent) if done

  ##
  # Closes the socket and releases the address/port the socket is bound to.
  # @param done [function(UdpSocket)] - Done callback
  #
  close: (done)->
    chrome.sockets.udp.close @socketId, ()=>
      UdpSocket.api.data.removeListener @_dta
      UdpSocket.api.data.error @_err
      @emit 'close', this
      done(this) if done

  ##
  # Retrieves the state of the given socket
  # @param done [function(SocketInfo, UdpSocket)] - Done callback
  #
  info:(done)->
    chrome.sockets.udp.getInfo @socketId, (info)=>
      done(info, this) if done

  ##
  # Joins the multicast group and starts to receive packets from that group.
  # The socket must be bound to a local port before calling this method.
  # @param address [string] - multicast address
  # @param done [function(UdpSocket)] - Done callback
  #
  join:(address, done)->
    chrome.sockets.udp.joinGroup @socketId, address, (code)=>
      if code < 0
        @emit 'error', code, chrome.runtime.lastError, 'join'
      else
        @emit 'join', address, this
      done(this) if done

  ##
  # Leaves the multicast group previously joined
  # @param address [string] - multicast address
  # @param done [function(UdpSocket)] - Done callback
  #
  leave:(address, done) ->
    chrome.sockets.udp.leaveGroup @socketId, address, (code)=>
      if code < 0
        @emit 'error', code, chrome.runtime.lastError, 'leave'
      else
        @emit 'leave', address, this
      done(this) if done

  ##
  # Sets the time-to-live of multicast packets sent to the multicast group.
  # @param ttl [integer] - The time-to-live value
  # @param done [function(UdpSocket)] - Done callback
  #
  multicastTTL:(ttl, done)->
    chrome.sockets.udp.setMulticastTimeToLive @socketId, ttl, (code)=>
      if code < 0
        @emit 'error', code, chrome.runtime.lastError, 'ttl'
      done(this) if done

  ##
  # Sets whether multicast packets sent from the host to the multicast group
  # will be looped back to the host.
  # @param enable [boolean] - Indicate whether to enable loopback mode.
  # @param done [function(UdpSocket)] - Done callback
  #
  multicastLoopback:(enable, done)->
    setMulticastLoopbackMode @socketId, enable, (code)=>
      if code < 0
        @emit 'error', code, chrome.runtime.lastError, 'ttl'
      done(this) if done

  ##
  # Gets the multicast group addresses the socket is currently joined to.
  # @param done [function(UdpSocket)] - Done callback
  #
  joinedGroups: (done)->
    chrome.sockets.udp.getJoinedGroups @socketId, (groups)=>
      done(groups) if done

  _data:(chunk, addr, port)=> @emit 'data', chunk, addr, port

  _error:(code)=>
    @emit 'error', code, new Error(code), 'acceptError'

window.rdd.UdpSocket = UdpSocket # Export
