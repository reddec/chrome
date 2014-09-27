Wrapper of Chrome Packaged API in OOP patterns in CoffeeScript
-------

* Author: RedDec
* Created: 25 Sep 2014

JavaScript object: ` window.rdd `

### Table of contents

* Network
 * TCP
   * [Client](#TcpSocket)
   * [Server](#TcpServer)


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

### sockets

``` sockets(done) ```

Retrieves the list of currently opened sockets owned by the application.
See: https://developer.chrome.com/apps/sockets_tcpServer#type-SocketInfo .

* `done` [function(List<SocketInfo>, TcpServer)] - Done callback
