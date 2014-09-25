###
# Protocol Utils for of ChromePackaged API - TCPSocket (client)
#
# Author: RedDec <net.dev@mail.ru>
# 25 Sep 2014
###

##
# Read and writes raw bytes
#
class RawProto
  constructor:()->

  append:(chunk, emitter)=> emitter.emit 'message', chunk

  ##
  # Writes bytes. If object is not bytes, object converts to string then
  # into bytes
  #
  convert:(object)=>
    return if object instanceof ArrayBuffer then object else str2ab object.toString()

  finish: (emitter)->

##
# Read and writes 8bytes text
#
class TextProto extends RawProto

  append:(chunk, emitter)=> emitter.emit 'message', ab2str8 chunk

##
# Read and writes JSON objects with fixed delimiter (\x01)
#
class JsonProto
  @delimiter = '\x01'
  constructor:()->
    @buf = ''

  append:(data, emitter)=>
    chunk = ab2str8 data
    last = 0
    for char, idx in chunk
      if char == JsonProto.delimiter
        msg = @buf + chunk.slice(last, idx)
        last = idx + 1
        @buf = ''
        obj = undefined
        try
          obj = JSON.parse msg
        catch e
          emitter.emit 'error', -2, e, 'JsonProto.append'
        emitter.emit 'message', obj if obj
    @buf += chunk.slice last

  convert:(data)=>
    return if data instanceof ArrayBuffer then data else str2ab JSON.stringify(data)

  finish: (emitter)=>
    obj = undefined
    try
      obj = JSON.parse @buf
    catch e
      emitter.emit 'error', -2, e, 'JsonProto.finish'
    emitter.emit('message', obj) if obj
