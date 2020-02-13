export default {
  progressMessageHide: ->
    try
      pms = document.getElementById('bootpay-progress-message')
      pms.style.setProperty('display', 'none')
      document.getElementById('progress-message-text').innerText = ''
      document.getElementById(@iframeId).removeEventListener('load', @progressMessageHide)
    catch then return

  progressMessageShow: (msg) ->
    pms = document.getElementById('bootpay-progress-message')
    pms.style.setProperty('display', 'block')
    document.getElementById('progress-message-text').innerText = msg

  showProgressButton: ->
    clb = document.getElementById(@closeId)
    clb.style.setProperty('display', 'block')

  hideProgressButton: ->
    clb = document.getElementById(@closeId)
    clb.style.setProperty('display', 'none')
}