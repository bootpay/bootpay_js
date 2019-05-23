export default {
  namespaces: {}
  on: (event, cb, opts) ->
    @namespaces = {} unless @namespaces?
    @namespaces[event] = cb
    options = opts || false
    @addEventListener(event.split('.')[0], cb, options)
    @
  off: (event) ->
    if @namespaces? and @namespaces[event]?
      @removeEventListener(event.split('.')[0], @namespaces[event])
      delete @namespaces[event]
    @
  startEventBinding: ->
    if window?
      window.on = @.on
      window.off = @.off
    if document?
      document.on = @.on
      document.off = @.off
    if Element?
      Element::on = @.on
      Element::off = @.off
}