import Ajax from './ajax'
import Logger from './logger'
import './style'
window.BootPay =
  VISIT_TIMEOUT: 86400000 # 재 방문 시간에 대한 interval
  SK_TIMEOUT: 1800000 # 30분
  version: require('../package.json').version
  restUrl: require('../package.json').urls.restUrl[process.env.NODE_ENV]
  clientUrl: require('../package.json').urls.clientUrl[process.env.NODE_ENV]
  analyticsUrl: require('../package.json').urls.analyticsUrl[process.env.NODE_ENV]
  paymentWindowId: 'bootpay-payment-window'
  iframeId: 'bootpay-payment-iframe'
  deviceType: 1
  methods: {}
  params: {}
  option: {}
  phoneRegex: /^\d{2,3}\d{3,4}\d{4}$/
#----------------------------------------------------------
# UUID가 없을 경우 바로 LocalStorage에 저장한다.
# Comment by Gosomi
# Date: 2018-04-29
#----------------------------------------------------------
  setReadyUUID: -> @setData 'uuid', @generateUUID() unless @getData('uuid')?.length
#----------------------------------------------------------
# Local Storage에서 데이터를 저장한다.
# Comment by Gosomi
# Date: 2018-04-28
#----------------------------------------------------------
  setData: (key, value) -> window.localStorage.setItem key, value
#----------------------------------------------------------
# Local Storage에서 데이터를 가져온다.
# Comment by Gosomi
# Date: 2018-04-28
#----------------------------------------------------------
  getData: (key) -> window.localStorage.getItem key
  generateUUID: ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c == 'x' then r else r & 0x3 | 0x8
      v.toString 16

export default window.BootPay