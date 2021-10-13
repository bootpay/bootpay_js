export default {
# 모바일인지 구분
  isMobile: ->
    a = (navigator.userAgent || navigator.vendor || window.opera)
    /Mobile|iP(hone|od|ad)|Android|BlackBerry|IEMobile|Kindle|NetFront|Silk-Accelerated|(hpw|web)OS|Fennec|Minimo|Opera M(obi|ini)|Blazer|Dolfin|Dolphin|Skyfire|Zune/.test(a)

  isSafari: ->
    agent = window.navigator.userAgent.toLowerCase()
    agent.indexOf('safari') > -1 && agent.indexOf('chrome') is -1
# 모바일 사파리인지 구분
  isMobileSafari: ->
    agent = window.navigator.userAgent
    (agent.match(/iPad/i) || agent.match(/iPhone/i)) && !agent.match(/CriOS/i)?

  getiOSVersion: ->
    try ((/CPU.*OS ([0-9_]{1,6})|(CPU like).*AppleWebKit.*Mobile/i.exec(window.navigator.userAgent))[1].replace(/_/g, '.')) || -1
    catch then -1

# IE인지 검사한다
  isIE: ->
    window.navigator.userAgent.indexOf('MSIE') > 0 || window.navigator.userAgent.match(/Trident.*rv\:11\./)?.length
# IE 버전 이하인지 검사한다
  isLtBrowserVersion: (version) ->
    sAgent = window.navigator.userAgent
    idx = sAgent.indexOf("MSIE")
    return false unless idx > 0
    version > parseInt(sAgent.substring(idx + 5, sAgent.indexOf(".", idx)))
# IE 버전 blocking
  blockIEVersion: -> @isLtBrowserVersion @ieMinVersion
# Platform String Return
  platformSymbol: ->
    if @isMobile()
      if @isMobileSafari() then 'ios' else 'android'
    else
      'pc'
}