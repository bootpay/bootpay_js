events =
  namespaces: {}
  on: (event, cb, opts) ->
    @namespaces = {} unless @namespaces?
    @namespaces[event] = cb
    options = opts || false
    @addEventListener( event.split('.')[0], cb, options )
    @
  off: (event) ->
    if @namespaces? and @namespaces[event]?
      @removeEventListener(event.split('.')[0], @namespaces[event])
      delete @namespaces[event]
    @

window.on = events.on
document.on = events.on
Element::on = events.on
window.off = events.off
document.off = events.off
Element::off = events.off