class EventEmitter
  constructor:()->
    @sequence = 0
    @listeners = {}

  on:(callback)=>
    id = @sequence++
    @listeners[id] = callback
    return id

  remove: (listener_id)=>
    delete @listeners[listener_id]

  once: (callback)=>
    id = @on (args...)=>
      @remove id
      callback args...

  emit: (args...)=>
    for id, listener of @listeners
      listener args...
    return id


class EventProvider
  constructor:()->
    @sequence = 0
    @listeners = {}

  on:(key, callback)=>
    id = @sequence++
    @listeners[key] = {} if not (key of @listeners)
    @listeners[key][id] = callback
    return id

  removeListener: (listener_id)=>
    for k, obj of @listeners
      delete obj[listener_id]

  once: (key, callback)=>
    id = @on (key, args...)=>
      @remove id
      callback args...

  emit: (key, args...)=>
    return this if not (key of @listeners)
    for id, callback of @listeners[key]
      callback args...
    return this
