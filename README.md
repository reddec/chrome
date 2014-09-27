Wrapper of Chrome Packaged API in OOP patterns in CoffeeScript
-------

* Author: RedDec
* Created: 25 Sep 2014

JavaScript object: ` window.rdd `

### Table of contents

* Network
  * [TCP client](#tcpsocket)
  * [TCP server](#tcpserver)
  * [UDP socket](#udpsocket)


# TcpSocket

JavaScript: ` window.rdd.TcpSocket `


[Original API](https://developer.chrome.com/apps/sockets_tcp)

## Example

```coffeescript
TcpSocket.create (sock)->
  sock.on 'data', (data)->
    console.log 'Chunk', ab2str8(data)
  sock.on 'connect', ()->
    console.log 'Connected'
    sock.send 'Hello world!'
  sock.on 'close', ()->
    console.log 'Closed'
  sock.on 'error', (code, err, from)->
    console.log 'ERROR:', from, code, err
  sock.connect '127.0.0.1', 3000
```

## Events


* `connect` [TcpSocket] - socket established connection to remote host
* `disconnect` [TcpSocket] - socket disconnected from remote host
* `close` [TcpSocket] - socket closed
* `data` [ArrayBuffer] - data read from socket
* `error` [code, error, sendet] - raised error

## API


### [static] create

``` create(done) ```

Create new TcpSocket

* `done` [function(TcpSocket)] - Done callback

### [constructor]

``` TcpSocket(@socketId) ```

Create new instance of TcpSocket

* `socketId` [Integer] - Socket file descriptor

Public variables:

* `paused` [boolean] - is socket disabled for receiving messages
* `closed` [boolean] - has been socket closed
* `connected` [boolean] - is socket connected to peer

### pause

``` pause(state, done) ```

Enables or disables the application from receiving messages from its peer.
Automatically sets to true when connection established.

* `state` [boolean] - Pause state
* `done` [function(TcpSocket)] - Done callback


### close

``` close(done) ```

Close TcpSocket. Emits 'disconnect' and 'close' events. Do nothing if not connected, but callback will be invoked.

* `done` [function(TcpSocket)] - Done callback

### send

``` send(data, done) ```

Send data to peer. Emits 'error' if socket is not connected.

* `data` [ArrayBuffer | Object] - Message. Type of messages and end view depends of `IOC`
* `done` [function(info)] - Done callback

### connect

``` connect(host, port, done) ```

Connect to remote address. Emits 'error' if connection failed. Emits 'connect' if connection established.

* `host` [string] - remote domain or ip
* `port` [integer] - remote port number
* `done` [function(info)]- Done callback if connected


### disconnect

``` disconnect(done) ```

Shutdown connection. Emits 'error' if socket is not connected.
Emits 'disconnect' if connection shutdowned.

* `done` [function(TcpSocket)]- Done callback

### info

``` info(done) ```

Get socket info. Emits 'error' if socket not connected.

* `done` [function(info)]- Done callback

Info (https://developer.chrome.com/apps/sockets_tcp#type-SocketInfo):

* socketId [integer]
* localAddress [string]
* localPort [integer]
* peerAddress [string]
* peerPort [integer]
* ...

----


# TcpServer

JavaScript: ` window.rdd.TcpServer `

[Original API](https://developer.chrome.com/apps/sockets_tcpServer)


## Example

CoffeeScript:

```coffeescript
# Echo server
TcpServer.create (server)=>

  server.on 'accept', (sock)=>
    console.log 'Accept'

    sock.on 'data', (data)=>
      sock.send data
    sock.on 'close', ()=>
      console.log('Client closed')
    sock.pause false, ()=>
      console.log 'Reading...'

  server.on 'listen', ()=>
    console.log 'Listen'

  server.on 'error', (code, err, from)->
    console.log 'Err', code, err, from

  server.listen '0.0.0.0', 3001
```

JavaScript:

```javascript
# This is short version of echo server
window.rdd.TcpServer.create(function(server){
  server.on('accept', function(client){
    client.on('data', function(chunk){
      client.send(chunk);
    });
  });
  server.listen('0.0.0.0', 3001);
});
```

## Events


* `listen` [TcpServer] - socket becomes accept clients
* `accept` [TcpSocket, TcpServer] - new client accepted
* `close` [TcpServer] - socket closed
* `disconnect` [TcpServer] - stops listening and closes all child sockets
* `error` [code, error, sender] - raised error

## API

### [static] create

``` create(done) ```

Creates new instance of socket and wrap it to TcpServer

* `done` [function(info)] - Done callback

### [static] sockets

``` sockets(done) ```

Retrieves the list of currently opened sockets owned by the application.
See: https://developer.chrome.com/apps/sockets_tcpServer#type-SocketInfo .

* `done` [function(List<SocketInfo>)] - Done callback


### [constructor] TcpServer

``` TcpServer(socketId) ```

Create new instance of TcpServer based on socket descriptor

* `socketId` [integer] - Socket descriptor

### pause

``` pause(paused, done) ```

Set pause state

* `paused` [boolean] - Enable pause or not
* `done` [function(info)] - Done callback

### listen

``` listen(address, port, backlog, done, unpause) ```

Setup socket in listen mode and start accepting clients.
Emits 'listen' on success.

* `address` [string] - Bind host name or ip
* `port` [integer] - Bind port number
* `backlog` [integer] (default = 1) - Clients queue size
* `done` [function(TcpServer)] - Done callback
* `unpause` [boolean](default = true) - Unpause socket

### disconnect

``` disconnect(done) ```

Stop listening and close all child sockets. Emits 'disconnect' event

* `done` [function(TcpServer)] - Done callback

### close

``` close(done) ```

Destroy socket. Emits 'close'.

* `done` [function(TcpServer)] - Done callback

### info

``` info(done) ```

Get socket info.
See: https://developer.chrome.com/apps/sockets_tcpServer#type-SocketInfo

* `done` [function(TcpServer)] - Done callback

----


# UdpSocket

JavaScript: ` window.rdd.UdpSocket `

[Original API](https://developer.chrome.com/apps/sockets_udp)


## Example

CoffeeScript:

```coffeescript
UdpSocket.create (sock)=>
    sock.on 'error', (code, err, from)->
      console.log 'Error', code, from, err
    sock.on 'data', (chunk, addr, port)->
      console.log 'Data', ab2str8(chunk), 'from', addr, port

    sock.bind '0.0.0.0', 0, ()=>
      console.log 'Bound'
      sock.info (info)=>
        console.log 'Info', info
        sock.send 'Hello world!', '127.0.0.1', info.localPort
```

JavaScript:

```javascript
window.rdd.UdpSocket.create(function(sock) {
  sock.on('error', function(code, err, from) {
    console.log('Error', code, from, err);
  });
  sock.on('data', function(chunk, addr, port) {
    console.log('Data', ab2str8(chunk), 'from', addr, port);
  });
  sock.bind('0.0.0.0', 0, function() {
    console.log('Bound');
    sock.info(function(info) {
      console.log('Info', info);
      sock.send('Hello world!', '127.0.0.1', info.localPort);
    });
  });
});
```

## Events


* `bind` [address, port] - socket bound to address:port
* `close` [UdpSocket] - socket closed
* `join` [address, UdpSocket] - socket joined to multicast group
* `leave` [address, UdpSocket] - socket leaved multicast group
* `error` [code, error, sender] - raised error

## API

### [static] create

``` create(done) ```

Creates new instance of socket and wrap it to UdpSocket

* `done` [function(UdpSocket)] - Done callback

### [static] sockets

``` sockets(done) ```

Retrieves the list of currently opened sockets owned by the application.
See: https://developer.chrome.com/apps/sockets_udp#method-getSockets

* `done` [function(List<SocketInfo>)] - Done callback

### [constructor] UdpSocket

``` UdpSocket(socketId) ```

Create new instance of UdpSocket

* `socketId` [integer] - Socket descriptor

### update

``` update(properties, done) ```

Updates the socket properties.
See: https://developer.chrome.com/apps/sockets_udp#method-update

* `properties` [SocketProperties] - The properties to update.
* `done` [function(UdpSocket)] - Done callback

### pause

``` pause(state, done) ```

Pauses or unpauses a socket. A paused socket is not recieving data

* `state` [boolean] - Pause or not
* `done` [function(UdpSocket)] - Done callback

### bind

``` bind(address, port, done, unpause) ```

Binds the local address and port for the socket.
For a client socket, it is recommended to use port 0 to let
the platform pick a free port.

* `address` [string] - IP or address of machine
* `port` [integer] - port number
* `done` [function(UdpSocket)] - Done callback
* `unpause` [boolean] (default = true) - Automatic unpause socket

### send

``` send(data, address, port, done) ```

Sends data on the given socket to the given address and port.
The socket must be bound to a local port before calling this method.

* `data` [ArrayBuffer | String] - Message to send
* `address` [string] - IP or address of target machine
* `port` [integer] - port number
* `done` [function(UdpSocket)] - Done callback

### close

``` close(done) ```

Closes the socket and releases the address/port the socket is bound to.

* `done` [function(UdpSocket)] - Done callback

### info

``` info(done) ```

Retrieves the state of the given socket

* `done` [function(SocketInfo, UdpSocket)] - Done callback

### join

``` join(address, done) ```

Joins the multicast group and starts to receive packets from that group.
The socket must be bound to a local port before calling this method.

* `address` [string] - multicast address
* `done` [function(UdpSocket)] - Done callback

### leave

``` leave(address, done) ```

Leaves the multicast group previously joined

* `address` [string] - multicast address
* `done` [function(UdpSocket)] - Done callback

### multicastTTL

``` multicastTTL(ttl, done) ```

Sets the time-to-live of multicast packets sent to the multicast group.

* `ttl` [integer] - The time-to-live value
* `done` [function(UdpSocket)] - Done callback

### multicastLoopback

``` multicastLoopback(enable, done) ```

Sets whether multicast packets sent from the host to the multicast group
will be looped back to the host.

* `enable` [boolean] - Indicate whether to enable loopback mode.
* `done` [function(UdpSocket)] - Done callback

### joinedGroups

``` joinedGroups(done) ```

Gets the multicast group addresses the socket is currently joined to.

* done [function(UdpSocket)] - Done callback
