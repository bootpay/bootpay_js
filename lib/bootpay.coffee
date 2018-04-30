request = require('superagent')
import Logger from './logger'
import CryptoJS from 'crypto-js'
import './style'
window.BootPay =
  VISIT_TIMEOUT: 86400000 # 재 방문 시간에 대한 interval
  SK_TIMEOUT: 1800000 # 30분
  applicationId: undefined
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
  initialize: (logLevel = 1) ->
    @setLogLevel logLevel
    @setReadyUUID()
    @setReadySessionKey()
# meta tag에서 application id를 찾는다.
  setApplicationId: (applicationId = undefined) ->
    if applicationId?
      @applicationId = applicationId
    else
      metaTag = document.querySelector('meta[name="bootpay-application-id"]')
      if metaTag?
        @applicationId = metaTag.getAttribute 'content'
      else
        return alert '<meta name="bootpay-application-id" content="[Application ID를 입력]" /> 다음과 같이 <head>안에 넣어주세요'
#  로그 레벨을 설정한다.
  setLogLevel: (logLevel = 1) -> Logger.setLogLevel logLevel
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
# Javascript로 UUID를 생성한다.
  generateUUID: ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c == 'x' then r else r & 0x3 | 0x8
      v.toString 16
  # 세션 키를 발급하는 로직
  setReadySessionKey: ->
    sessionKeyTime = (new Date()).getTime()
    if @getData('last_time')?.length
      sessionKeyTime = new Date().getTime()
      if @getData('last_time')?.length
        lastTime = parseInt(@getData('last_time')) # 마지막으로 접근한 시간을 기록한다.
        @setData 'last_time', sessionKeyTime
        if isNaN(lastTime) or lastTime + @SK_TIMEOUT < sessionKeyTime # 마지막 접속한 시간에 30분이 지나버린 경우 세션을 초기화한다.
          @setData 'sk', "#{@getData('uuid')}_#{sessionKeyTime}"
          @setData 'sk_time', sessionKeyTime
          @setData 'time', (sessionKeyTime - lastTime)
          Logger.debug "시간이 지나 세션 고유 값 정보를 새로 갱신하였습니다. sk: #{@getData('sk')}, time: #{@getData('sk_time')}"
        else
          Logger.debug "이전 세션을 그대로 이용합니다. sk: #{@getData('sk')}, time: #{@getData('sk_time')}"
    else
      @setData 'last_time', sessionKeyTime
      @setData 'sk', "#{@getData('uuid')}_#{sessionKeyTime}"
      @setData 'sk_time', sessionKeyTime
      Logger.debug "처음 접속하여 세션 고유 값을 설정하였습니다."
  # 로그인 정보를 절차에 따라 초기화한다.
  expireUserData: ->
    data = @getUserData()
    # 데이터가 없거나 접속 한지 하루가 지나면 데이터를 삭제한다.
    if data? and (data.time + @VISIT_TIMEOUT < new Date().getTime())
      Logger.info "시간이 지나 로그인 유저 정보를 초기화 하였습니다."
      @setData 'user', null
  startTrace: (data = undefined) ->
    @setApplicationId() unless @applicationId?.length
    @expireUserData()
    @sendCommonData data

  sendCommonData: (data) ->
    url = document.URL
    return if !url or (url.search(/g-cdn.bootpay.co.kr/) == -1 and url.search(/bootpay.co.kr/) > -1 and  url.search(/app.bootpay.co.kr/) == -1)
    user = @getUserData()
    items = if data? and data.items?.length then data.items else [
      {
        cat1: if data? then data.cat1 else undefined
        cat2: if data? then data.cat2 else undefined
        cat3: if data? then data.cat3 else undefined
        item_img: if data? then data.item_img else undefined
        item_name: if data? then data.item_name else undefined
        unique: if data? then data.unique else undefined
        price: if data? then data.price else undefined
      }
    ]

    requestData =
      application_id: @applicationId
      uuid: @getData('uuid')
      time: @getData('time')
      url: if data? and data.url? then data.url else document.URL
      referer: if document.referrer?.length and document.referrer.search(new RegExp(window.location.hostname)) == -1 then document.referrer else ''
      sk: @getData('sk')
      user_id: if user? then user.id else undefined
      page_type: if data? then data.type else undefined
      items: items
    Logger.debug "활동 정보를 서버로 전송합니다. data: #{JSON.stringify(requestData)}"
    encryptData = CryptoJS.AES.encrypt(JSON.stringify(requestData), requestData.sk)
    request.post([@analyticsUrl, "call?ver=#{@version}"].join('/'))
    .send(
      data: encryptData.ciphertext.toString(CryptoJS.enc.Base64)
      session_key: "#{encryptData.key.toString(CryptoJS.enc.Base64)}###{encryptData.iv.toString(CryptoJS.enc.Base64)}"
    )
    .end((err, res) =>
      Logger.error "BOOTPAY MESSAGE: #{json.message} - Application ID가 제대로 되었는지 확인해주세요." if res.status isnt 200 or res.body.status isnt 200
    )

  getUserData: -> try JSON.parse(@getData('user')) catch then undefined

window.BootPay.initialize()

export default window.BootPay