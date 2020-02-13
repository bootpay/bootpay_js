import 'es6-promise'
import 'babel-polyfill'
import Analytics from './extend/analytics'
import BootpayEvent from './extend/bootpay_event'
import Common from './extend/common'
import Message from './extend/message'
import Notification from './extend/notification'
import Payment from './extend/payment'
import Platform from './extend/platform'
import Storage from './extend/storage'
import Event from './event'
import './style'

window.BootPay =
  VISIT_TIMEOUT: 86400000 # 재 방문 시간에 대한 interval
  SK_TIMEOUT: 1800000 # 30분
  CONFIRM_LOCK: false
  applicationId: undefined
  version: '3.2.0'
  mode: 'production'
  backgroundId: 'bootpay-background-window'
  windowId: 'bootpay-payment-window'
  iframeId: 'bootpay-payment-iframe'
  closeId: 'bootpay-progress-button-window'
  popupWatchInstance: undefined
  popupInstance: undefined
  popupData: undefined
  ieMinVersion: 9
  deviceType: 1
  ableDeviceTypes:
    JS: 1
    ANDROID: 2
    IOS: 3
  methods: {}
  params: {}
  option: {}
  phoneRegex: /^\d{2,3}\d{3,4}\d{4}$/
  dateFormat: /(\d{4})-(\d{2})-(\d{2})/
  zeroPaymentMethod: ['bankalarm', 'auth', 'card_rebill']
  urls: require('../package.json').urls
  tk: undefined
  thirdPartyData: {}

  initialize: (logLevel = 1) ->
    if Element?
      Event.startEventBinding()
      @setLogLevel logLevel
      @setReadyUUID()
      @setReadySessionKey()
      @bindBootpayCommonEvent()


Object.assign(window.BootPay, Analytics, BootpayEvent, Common, Message, Notification, Payment, Platform, Storage)
window.BootPay.initialize()

export default window.BootPay