export default Ajax =
  ableMethods: ['GET', 'POST', 'PATCH', 'DELETE', 'PUT']
  XMLHttpFactories: [
    -> new XMLHttpRequest()
    -> new ActiveXObject("Msxml2.XMLHTTP")
    -> new ActiveXObject("Msxml3.XMLHTTP")
    -> new ActiveXObject("Microsoft.XMLHTTP")
  ]
  request: (options) ->
    return alert '요청하려는 URL를 입력해주세요.' unless options.url?.length
    options.method = 'GET' unless options.method?.length
    options.method = options.method.toUpperCase()
    # 기본 Default Content Type
    options.header = {} unless options.header?
    options.header['Content-Type'] = 'application/x-www-form-urlencoded' unless options.header['Content-Type']
    return alert "#{@ableMethods.join(', ')} method만 요청이 가능합니다." if @ableMethods.indexOf(options.method) is -1
    req = @createXMLHTTPObject()
    return unless req?
    if options.method is 'GET' or options.method is 'DELETE'
      params = ''
      for key in options.data
        params += "#{key}=#{options.data[key]}"
    req.open(options.url, true)
    for key in options.header
      req.setRequestHeader(key, options.header[key])
    req.onreadystatechange = ->
      if req.readyState is 4
        if req.status is 200 or req.status is 304
          options.success.apply @, [req] if options.success?
        else
          options.error.apply @, [req] if options.error?
      else
        return
    req.send(options.data) if options.method is 'POST' or options.method is 'PATCH' or options.method is 'PUT'

  createXMLHTTPObject: ->
    http = undefined
    for obj in @XMLHttpFactories
      try
        http = obj()
      catch
        continue
      break
    http