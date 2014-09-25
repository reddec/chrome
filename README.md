Wrapper of ChromePackaged API in OOP patterns in CoffeeScript
-------


#### TODO: Human readable error codes
#### TODO: Refactor

* Author: RedDec <net.dev@mail.ru>
* 25 Sep 2014


TcpSocket
======

[Original API](https://developer.chrome.com/apps/sockets_tcp)

## [constructor]

```TcpSocket(@socketId, IOC=RawProto)```

Create new instance of TcpSocket

* `socketId` [Integer] - Socket file descriptor
* `mode` [class] - IO converter. See: RawProto, TextProto, JsonProto

Public variables:

* `paused` [boolean] - is socket disabled for receiving messages
* `closed` [boolean] - has been socket closed
* `connected` [boolean] - is socket connected to peer

## pause

```pause(state, done)```

Enables or disables the application from receiving messages from its peer.
Automatically sets to true when connection established.

* `state` [boolean] - Pause state
* `done` [function(TcpSocket)] - Done callback


## close

``` close(done) ```

Close TcpSocket. Emits 'disconnect' and 'close' events. Do nothing if not connected, but callback will be invoked.

* `done` [function(TcpSocket)] - Done callback

## send

``` send(data, done) ```

Send data to peer. Emits 'error' if socket is not connected.

* `data` [ArrayBuffer | Object] - Message. Type of messages and end view depends of `IOC`
* `done` [function(info)] - Done callback

## connect

``` connect(host, port, done) ```

Connect to remote address. Emits 'error' if connection failed. Emits 'connect' if connection established.

* `host` [string] - remote domain or ip
* `port` [integer] - remote port number
* `done` [function(info)]- Done callback if connected


## disconnect

``` disconnect(done) ```

Shutdown connection. Emits 'error' if socket is not connected.
Emits 'disconnect' if connection shutdowned.

* `done` [function(TcpSocket)]- Done callback

## info

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

## [static] create

``` create(ioc=RawProto, done) ```

Create new TcpSocket

* `ioc` [class] -  protocol converter. RawProto, TextProto, JsonProto
* `done` [function(TcpSocket)] - Done callback
