export default {
  progressMessageHide: ->
    try
      pms = document.getElementById('bootpay-progress-message')
      pms.style.setProperty('display', 'none')
      document.getElementById('progress-message-text').innerText = ''
      document.getElementById(@iframeId).removeEventListener('load', @progressMessageHide)
    catch then return

  progressMessageShow: (msg, closeButton = false) ->
    pms = document.getElementById('bootpay-progress-message')
    pms.style.setProperty('display', 'block')
    document.getElementById('progress-message-text').innerText = msg
    btn = document.getElementById('__bootpay-popup-close-button__')
    btnStyle = if closeButton then 'block' else 'none'
    btn.style.setProperty('display', btnStyle)

  showProgressButton: ->
    clb = document.getElementById(@closeId)
    clb.style.setProperty('display', 'block')

  hideProgressButton: ->
    clb = document.getElementById(@closeId)
    clb.style.setProperty('display', 'none')
}