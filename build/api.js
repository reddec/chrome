// Generated by CoffeeScript 1.4.0

/*
# Usefull utils
# Copied and modified from StackOverflow
#
# Modified by: RedDec <net.dev@mail.ru>
# 25 Sep 2014
*/


(function() {
  var EventEmitter, EventProvider, JsonProto, RawProto, TcpSocket, TextProto, ab2str, ab2str8, str2ab, tcp_reader,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ab2str = function(buf) {
    return String.fromCharCode.apply(null, new Uint16Array(buf));
  };

  ab2str8 = function(buf) {
    return String.fromCharCode.apply(null, new Uint8Array(buf));
  };

  str2ab = function(str) {
    var a, buf, bufView, i, _i, _len;
    buf = new ArrayBuffer(str.length * 2);
    bufView = new Uint16Array(buf);
    for (i = _i = 0, _len = str.length; _i < _len; i = ++_i) {
      a = str[i];
      bufView[i] = str.charCodeAt(i);
    }
    return buf;
  };

  EventEmitter = (function() {

    function EventEmitter() {
      this.emit = __bind(this.emit, this);

      this.once = __bind(this.once, this);

      this.remove = __bind(this.remove, this);

      this.on = __bind(this.on, this);
      this.sequence = 0;
      this.listeners = {};
    }

    EventEmitter.prototype.on = function(callback) {
      var id;
      id = this.sequence++;
      this.listeners[id] = callback;
      return id;
    };

    EventEmitter.prototype.remove = function(listener_id) {
      return delete this.listeners[listener_id];
    };

    EventEmitter.prototype.once = function(callback) {
      var id,
        _this = this;
      return id = this.on(function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        _this.remove(id);
        return callback.apply(null, args);
      });
    };

    EventEmitter.prototype.emit = function() {
      var args, id, listener, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this.listeners;
      for (id in _ref) {
        listener = _ref[id];
        listener.apply(null, args);
      }
      return id;
    };

    return EventEmitter;

  })();

  EventProvider = (function() {

    function EventProvider() {
      this.emit = __bind(this.emit, this);

      this.once = __bind(this.once, this);

      this.removeListener = __bind(this.removeListener, this);

      this.on = __bind(this.on, this);
      this.sequence = 0;
      this.listeners = {};
    }

    EventProvider.prototype.on = function(key, callback) {
      var id;
      id = this.sequence++;
      if (!(key in this.listeners)) {
        this.listeners[key] = {};
      }
      this.listeners[key][id] = callback;
      return id;
    };

    EventProvider.prototype.removeListener = function(listener_id) {
      var k, obj, _ref, _results;
      _ref = this.listeners;
      _results = [];
      for (k in _ref) {
        obj = _ref[k];
        _results.push(delete obj[listener_id]);
      }
      return _results;
    };

    EventProvider.prototype.once = function(key, callback) {
      var id,
        _this = this;
      return id = this.on(function() {
        var args, key;
        key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        _this.remove(id);
        return callback.apply(null, args);
      });
    };

    EventProvider.prototype.emit = function() {
      var args, callback, id, key, _ref;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!(key in this.listeners)) {
        return this;
      }
      _ref = this.listeners[key];
      for (id in _ref) {
        callback = _ref[id];
        callback.apply(null, args);
      }
      return this;
    };

    return EventProvider;

  })();

  /*
  # Protocol Utils for of ChromePackaged API - TCPSocket (client)
  #
  # Author: RedDec <net.dev@mail.ru>
  # 25 Sep 2014
  */


  RawProto = (function() {

    function RawProto() {
      this.convert = __bind(this.convert, this);

      this.append = __bind(this.append, this);

    }

    RawProto.prototype.append = function(chunk, emitter) {
      return emitter.emit('message', chunk);
    };

    RawProto.prototype.convert = function(object) {
      if (object instanceof ArrayBuffer) {
        return object;
      } else {
        return str2ab(object.toString());
      }
    };

    RawProto.prototype.finish = function(emitter) {};

    return RawProto;

  })();

  TextProto = (function(_super) {

    __extends(TextProto, _super);

    function TextProto() {
      this.append = __bind(this.append, this);
      return TextProto.__super__.constructor.apply(this, arguments);
    }

    TextProto.prototype.append = function(chunk, emitter) {
      return emitter.emit('message', ab2str8(chunk));
    };

    return TextProto;

  })(RawProto);

  JsonProto = (function() {

    JsonProto.delimiter = '\x01';

    function JsonProto() {
      this.finish = __bind(this.finish, this);

      this.convert = __bind(this.convert, this);

      this.append = __bind(this.append, this);
      this.buf = '';
    }

    JsonProto.prototype.append = function(data, emitter) {
      var char, chunk, idx, last, msg, obj, _i, _len;
      chunk = ab2str8(data);
      last = 0;
      for (idx = _i = 0, _len = chunk.length; _i < _len; idx = ++_i) {
        char = chunk[idx];
        if (char === JsonProto.delimiter) {
          msg = this.buf + chunk.slice(last, idx);
          last = idx + 1;
          this.buf = '';
          obj = void 0;
          try {
            obj = JSON.parse(msg);
          } catch (e) {
            emitter.emit('error', -2, e, 'JsonProto.append');
          }
          if (obj) {
            emitter.emit('message', obj);
          }
        }
      }
      return this.buf += chunk.slice(last);
    };

    JsonProto.prototype.convert = function(data) {
      if (data instanceof ArrayBuffer) {
        return data;
      } else {
        return str2ab(JSON.stringify(data));
      }
    };

    JsonProto.prototype.finish = function(emitter) {
      var obj;
      obj = void 0;
      try {
        obj = JSON.parse(this.buf);
      } catch (e) {
        emitter.emit('error', -2, e, 'JsonProto.finish');
      }
      if (obj) {
        return emitter.emit('message', obj);
      }
    };

    return JsonProto;

  })();

  /*
  # Wrapper of ChromePackaged API - TCPSocket (client)
  #
  # TODO: Human readable error codes
  # TODO: Refactor
  #
  # Author: RedDec <net.dev@mail.ru>
  # 25 Sep 2014
  */


  tcp_reader = function() {
    var data, error,
      _this = this;
    data = new EventProvider();
    error = new EventProvider();
    chrome.sockets.tcp.onReceive.addListener(function(info) {
      return data.emit(info.socketId, info.data);
    });
    chrome.sockets.tcp.onReceiveError.addListener(function(info) {
      if (info) {
        return error.emit(info.socketId, info.resultCode);
      }
    });
    return {
      data: data,
      error: error
    };
  };

  TcpSocket = (function(_super) {

    __extends(TcpSocket, _super);

    TcpSocket.api = tcp_reader();

    function TcpSocket(socketId, IOC) {
      this.socketId = socketId;
      if (IOC == null) {
        IOC = RawProto;
      }
      this._error = __bind(this._error, this);

      this._data = __bind(this._data, this);

      this.connect = __bind(this.connect, this);

      this.send = __bind(this.send, this);

      this.close = __bind(this.close, this);

      this.pause = __bind(this.pause, this);

      TcpSocket.__super__.constructor.call(this);
      this.connected = false;
      this.paused = true;
      this.closed = false;
      this.io = new IOC();
    }

    TcpSocket.prototype.pause = function(state, done) {
      return chrome.sockets.tcp.setPaused(this.socketId, state, function() {
        if (done) {
          return done(this);
        }
      });
    };

    TcpSocket.prototype.close = function(done) {
      var _this = this;
      if (!this.closed) {
        return this.disconnect(function() {
          _this.closed = true;
          return chrome.sockets.tcp.close(_this.socketId, function() {
            _this.connected = false;
            TcpSocket.api.data.removeListener(_this.tel_id);
            TcpSocket.api.error.removeListener(_this.tdl_id);
            if (done) {
              done(_this);
            }
            return _this.emit('close');
          });
        });
      } else {
        if (done) {
          return done(this);
        }
      }
    };

    TcpSocket.prototype.send = function(data, done) {
      var _this = this;
      if (this.connected) {
        data = this.io.convert(data);
        return chrome.sockets.tcp.send(this.socketId, data, function(info) {
          if (!info) {
            return _this.emit('error', -3, chrome.runtime.lastError, 'send1');
          } else {
            if (info.resultCode < 0) {
              _this.emit('error', info.resultCode, chrome.runtime.lastError, 'send2');
            }
            if (done) {
              return done(info);
            }
          }
        });
      } else {
        return this.emit('error', -1, 'ERR:: Socket is not connected', 'send3');
      }
    };

    TcpSocket.prototype.connect = function(host, port, done) {
      var _this = this;
      return chrome.sockets.tcp.connect(this.socketId, host, port, function(code) {
        _this.connected = code >= 0;
        _this.tdl_id = TcpSocket.api.data.on(_this.socketId, _this._data);
        _this.tel_id = TcpSocket.api.error.on(_this.socketId, _this._error);
        if (!_this.connected) {
          return _this.emit('error', code, chrome.runtime.lastError, 'connect');
        } else {
          return _this.pause(_this.connected, function() {
            if (_this.connected) {
              _this.emit('connect', _this);
            }
            if (done) {
              return done(_this);
            }
          });
        }
      });
    };

    TcpSocket.prototype.disconnect = function(done) {
      var _this = this;
      if (this.connected) {
        chrome.sockets.tcp.disconnect(this.socketId, function() {
          _this.connected = false;
          _this.io.finish(_this);
          return _this.emit('disconnect');
        });
      } else {
        console.log('error', -1, 'ERR:: Socket is not connected', 'disconnect');
      }
      if (done) {
        return done(this);
      }
    };

    TcpSocket.prototype.info = function(done) {
      var _this = this;
      if (done && this.connected) {
        return chrome.sockets.tcp.getInfo(this.socketId, function(info) {
          return info;
        });
      } else if (done && !this.connected) {
        return this.emit('error', -1, 'ERR:: Socket is not connected', 'info');
      }
    };

    TcpSocket.prototype._data = function(data) {
      return this.io.append(data, this);
    };

    TcpSocket.prototype._error = function(code) {
      if (code !== -15) {
        setTimeout(this.emit('error', code, new Error(chrome.runtime.lastError || code), '_error'), 0);
      }
      return this.close();
    };

    TcpSocket.create = function(ioc, done) {
      if (ioc == null) {
        ioc = RawProto;
      }
      return chrome.sockets.tcp.create(function(fd) {
        return done(new TcpSocket(fd.socketId, ioc));
      });
    };

    return TcpSocket;

  }).call(this, EventProvider);

}).call(this);
