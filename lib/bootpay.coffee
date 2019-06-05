request = require('superagent')
import 'es6-promise/auto'
import Event from './event'
import Logger from './logger'
import AES from 'crypto-js/aes'
import Base64 from 'crypto-js/enc-base64'
import './style'

window.BootPay =
  VISIT_TIMEOUT: 86400000 # 재 방문 시간에 대한 interval
  SK_TIMEOUT: 1800000 # 30분
  CONFIRM_LOCK: false
  applicationId: undefined
  version: '3.0.4-beta1'
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

  naverpayZzimUrl: (mode = 'production', platform = 'pc') ->
    @urls.naverpayZzimUrl[mode][platform]
  restUrl: ->
    @urls.restUrl[@mode]
  clientUrl: ->
    @urls.clientUrl[@mode]
  analyticsUrl: ->
    @urls.analyticsUrl[@mode]

  isMobile: ->
    a = (navigator.userAgent || navigator.vendor || window.opera)
    (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4)))

  isMobileSafari: ->
    agent = window.navigator.userAgent
    agent.match(/iPad/i) || agent.match(/iPhone/i)

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
  setMode: (mode) -> @mode = mode
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
# device Type을 설정한다. 없을 경우 false를 리턴, 있는 경우 true를 리턴
  setDevice: (deviceType) ->
    @deviceType = @ableDeviceTypes[deviceType] if @ableDeviceTypes[deviceType]?
    @ableDeviceTypes[deviceType]?

# Parent 혹은 Opener에서 데이터를 가져와 통계 데이터를 동기화한다.
  setAnalyticsDataByParent: (parent) ->
    parent.postMessage(JSON.stringify(action: 'BootpayAnalyticsData'), '*')

# 기본적인 통계 데이터를 설정한다.
# Android, iPhone에서 기본적으로 사용하는 코드
  setAnalyticsData: (data) ->
    @setData 'uuid', data.uuid if data.uuid?
    @setData 'sk', data.sk if data.sk?
    @setData 'sk_time', data.sk_time if data.sk_time?
    @setData 'time', data.time if data.time?

# 로그인한 유저 정보를 가져온다.
  getUserData: -> try JSON.parse(@getData('user'))
  catch then undefined
# Javascript로 UUID를 생성한다.
  generateUUID: ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c == 'x' then r else r & 0x3 | 0x8
      v.toString 16
# 로그인 했을때 데이터를 저장한다.
  setUserData: (data) ->
    @setData 'user', JSON.stringify(data)
# 세션 키를 발급하는 로직
  setReadySessionKey: ->
    sessionKeyTime = (new Date()).getTime()
    if @getData('last_time')?.length
      sessionKeyTime = new Date().getTime()
      if @getData('last_time')?.length
        lastTime = parseInt(@getData('last_time')) # 마지막으로 접근한 시간을 기록한다.
        @setData 'last_time', sessionKeyTime
        if isNaN(lastTime) or lastTime + @SK_TIMEOUT < sessionKeyTime # 마지막 접속한 시간에 30분이 지나버린 경우 세션을 초기화한다.
          @setData 'sk', "#{@getData('uuid')}-#{sessionKeyTime}"
          @setData 'sk_time', sessionKeyTime
          @setData 'time', (sessionKeyTime - lastTime)
          Logger.debug "시간이 지나 세션 고유 값 정보를 새로 갱신하였습니다. sk: #{@getData('sk')}, time: #{@getData('sk_time')}"
        else
          Logger.debug "이전 세션을 그대로 이용합니다. sk: #{@getData('sk')}, time: #{@getData('sk_time')}"
    else
      @setData 'last_time', sessionKeyTime
      @setData 'sk', "#{@getData('uuid')}-#{sessionKeyTime}"
      @setData 'sk_time', sessionKeyTime
      Logger.debug "처음 접속하여 세션 고유 값을 설정하였습니다."
# 로그인 정보를 절차에 따라 초기화한다.
  expireUserData: ->
    data = @getUserData()
    # 데이터가 없거나 접속 한지 하루가 지나면 데이터를 삭제한다.
    if data? and (data.time + @VISIT_TIMEOUT < new Date().getTime())
      Logger.info "시간이 지나 로그인 유저 정보를 초기화 하였습니다."
      @setData 'user', null
# 통계 시작
  startTrace: (data = undefined) ->
    @setApplicationId() unless @applicationId?.length
    @expireUserData()
    @sendCommonData data
# 통계용 데이터를 부트페이로 전송
  sendCommonData: (data) ->
    url = document.URL
    return if !url or (url.search(/g-cdn.bootpay.co.kr/) == -1 and url.search(/bootpay.co.kr/) > -1 and url.search(/app.bootpay.co.kr/) == -1)
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
    encryptData = AES.encrypt(JSON.stringify(requestData), requestData.sk)
    request.post([@analyticsUrl(), "call?ver=#{@version}"].join('/')).set(
      'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
    ).send(
      data: encryptData.ciphertext.toString(Base64)
      session_key: "#{encryptData.key.toString(Base64)}###{encryptData.iv.toString(Base64)}"
    ).then((res) =>
      Logger.warn "BOOTPAY MESSAGE: #{res.body.message} - Application ID가 제대로 되었는지 확인해주세요." if res.status isnt 200 or res.body.status isnt 200
    ).catch((err) =>
      Logger.warn "BOOTPAY MESSAGE: #{err.body.message} - Application ID가 제대로 되었는지 확인해주세요."
    )
# 로그인 정보를 부트페이 서버로 전송한다.
  startLoginSession: (data) ->
    try
      throw '로그인 데이터를 입력해주세요.' unless data?
      throw '로그인 하는 아이디를 입력해주세요.' unless data.id?
    catch e
      Logger.error e
      alert e
      throw e
    @sendLoginData(
      application_id: if data.application_id? then data.application_id else @applicationId
      id: data.id
      username: data.username
      birth: data.birth
      phone: data.phone
      email: data.email
      gender: data.gender
      area: if data.area? then String(data.area).match(/서울|인천|대구|광주|부산|울산|경기|강원|충청북도|충북|충청남도|충남|전라북도|전북|전라남도|전남|경상북도|경북|경상남도|경남|제주|세종|대전/) else undefined
    )
# 부트페이 서버로 데이터를 전송한다.
  sendLoginData: (data) ->
    return if !data? or !document.URL?
    Logger.debug "로그인 데이터를 전송합니다. data: #{JSON.stringify(data)}"
    data.area = if data.area?.length then data.area[0] else undefined
    encryptData = AES.encrypt(JSON.stringify(data), @getData('sk'))
    request.post([@analyticsUrl(), "login?ver=#{@version}"].join('/')).set(
      'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
    ).send(
      data: encryptData.ciphertext.toString(Base64)
      session_key: "#{encryptData.key.toString(Base64)}###{encryptData.iv.toString(Base64)}"
    ).then((res) =>
      if res.status isnt 200 or res.body.status isnt 200
        Logger.warn "BOOTPAY MESSAGE: #{res.body.message} - Application ID가 제대로 되었는지 확인해주세요."
      else
        json = res.body.data
        @setUserData(
          id: json.user_id
          time: (new Date()).getTime()
        )
    ).catch((err) =>
      Logger.warn "BOOTPAY MESSAGE: #{err.message} - Application ID가 제대로 되었는지 확인해주세요."
    )

# 결제 정보를 보내 부트페이에서 결제 정보를 띄울 수 있게 한다.
  request: (data) ->
    @bindBootpayPaymentEvent()
    @removePaymentWindow(false)
    @setConfirmLock(false)
    try
      user = @getUserData()
      # 결제 효청시 application_id를 입력하면 덮어 씌운다. ( 결제 이후 버그를 줄이기 위한 노력 )
      @applicationId = data.application_id if data.application_id?
      @tk = "#{@generateUUID()}-#{(new Date).getTime()}"
      @params =
        application_id: @applicationId
        show_agree_window: if data.show_agree_window? then data.show_agree_window else 0
        device_type: @deviceType
        method: data.method if data.method?
        methods: data.methods if data.methods?
        boot_key: data.boot_key if data.boot_key?
        pg: data.pg if data.pg?
        name: data.name
        items: data.items if data.items?.length
        redirect_url: if data.redirect_url? then data.redirect_url else ''
        return_url: if data.return_url? then data.return_url else ''
        phone: if data.phone?.length then data.phone.replace(/-/g, '') else ''
        uuid: if data.uuid?.length then data.uuid else @getData('uuid')
        order_id: if data.order_id? then String(data.order_id) else ''
        use_order_id: if data.use_order_id? then data.use_order_id else 0
        user_info: if data.user_info? then data.user_info else undefined
        order_info: if data.order_info? then data.order_info else {} # 네이버페이 order 정보
        sk: @getData('sk')
        time: @getData('time')
        price: data.price
        tax_free: if data.tax_free? then data.tax_free else 0
        format: if data.format? then data.format else 'json'
        params: if data.params? then data.params else undefined
        user_id: if user? then user.id else undefined
        path_url: document.URL
        extra: if data.extra? then data.extra else undefined
        account_expire_at: if data.account_expire_at? then data.account_expire_at else undefined
        tk: @tk
        third_party: @thirdPartyData
      # 각 함수 호출 callback을 초기화한다.
      @methods = {}
      # 아이템 정보의 Validation
      @integrityItemData() if @params.items?.length
      # 결제 정보 데이터의 Validation
      @integrityParams() if !@params.method? or @params.method is 'auth'
      # True, False의 데이터를 1, 0으로 변경하는 작업을 한다
      @generateTrueFalseParams()
      # 데이터를 AES로 암호화한다.
      encryptData = AES.encrypt(JSON.stringify(@params), @params.sk)
      html = """
        <div id="#{@windowId}">
          <form name="bootpay_form" action="#{[@restUrl(), 'start', 'js', '?ver=' + @version].join('/')}" method="POST">
            <input type="hidden" name="data" value="#{encryptData.ciphertext.toString(Base64)}" />
            <input type="hidden" name="session_key" value="#{encryptData.key.toString(Base64)}###{encryptData.iv.toString(Base64)}" />
          </form>
          <form id="__BOOTPAY_TOP_FORM__" name="__BOOTPAY_TOP_FORM__" action="#{[@restUrl(), 'continue'].join('/')}" method="post">
          </form>
          <form id="bootpay_confirm_form" name="bootpay_confirm_form" action="#{[@restUrl(), 'confirm'].join('/')}" method="POST">
          </form>
          <div class="bootpay-window" id="bootpay-background-window">#{@iframeHtml('')}</div>
        </div>
        """
      document.body.insertAdjacentHTML 'beforeend', html
      try document.body.classList.add('bootpay-open')
      catch then ''
      @start()
    catch e
      @sendPaymentStepData(
        step: 'start'
        status: -1
        e: e
      )
      throw e
    @sendPaymentStepData(
      step: 'start'
      status: 1
    )
    @

#  결제 요청 정보 Validation
  integrityParams: ->
    price = parseFloat @params.price
    try
      throw '결제할 금액을 설정해주세요. ( 1,000원 이상, 본인인증/정기 결제요청의 경우엔 0원을 입력해주세요. ) [ params: price ]' if (isNaN(price) or price < 1000) and @zeroPaymentMethod.indexOf(@params.method) is -1
      throw '판매할 상품명을 입력해주세요. [ parmas: name ]' unless @params.name?.length
      throw '익스플로러 8이하 버전에서는 결제가 불가능합니다.' if @blockIEVersion()
      throw '휴대폰 번호의 자리수와 형식이 맞지 않습니다. [ params : phone ]' if @params.phone?.length and !@phoneRegex.test(@params.phone)
      throw '판매하려는 제품 order_id를 지정해주셔야합니다. 다른 결제 정보와 겹치지 않은 유니크한 값으로 정해서 보내주시기 바랍니다. [ params: order_id ]' unless @params.order_id?.length
      throw '가상계좌 입금 만료일 포멧이 잘못되었습니다. yyyy-mm-dd로 입력해주세요. [ params: account_expire_at ]' if @params.account_expire_at?.length and !@dateFormat.test(@params.account_expire_at) and @params.method is 'vbank'
      throw '선택 제한 결제 수단 설정은 배열 형태로 보내주셔야 합니다. [ params: methods, ex) ["card", "phone"] ]' if @params.methods? and !Array.isArray(@params.methods)
    catch e
      alert e
      Logger.error e
      throw e
# 아이템 정보 Validation
  integrityItemData: ->
    try
      throw '아이템 정보가 배열 형태가 아닙니다.' unless Array.isArray(@params.items)
      @params.items.forEach (item, index) ->
        throw "통계에 필요한 아이템 이름이 없습니다. [key: item_name, index: #{index}] " unless item.item_name?.length
        throw "통계에 필요한 상품 판매 개수가 없습니다. [key: qty, index: #{index}]" unless item.qty?
        throw "상품 판매 개수를 숫자로 입력해주세요. [key: qty, index: #{index}]" if isNaN(parseInt(item.qty))
        throw "통계를 위한 상품의 고유값을 넣어주세요. [key: unique, index: #{index}]" unless item.unique?.length
        throw "통계를 위해 상품의 개별 금액을 넣어주세요. [key: price, index: #{index}]" unless item.price?
        throw "상품금액은 숫자로만 가능합니다. [key: price, index: #{index}]" if isNaN(parseInt(item.price))
    catch e
      alert e
      Logger.error e
      throw e
# True, False -> 1, 0 으로 Generate 한다
  generateTrueFalseParams: ->
    for index of @params
      @params[index] = 1 if @params[index] is true
      @params[index] = 0 if @params[index] is false

    if @params.extra?
      for index of @params.extra
        @params.extra[index] = 1 if @params.extra[index] is true
        @params.extra[index] = 0 if @params.extra[index] is false

    if @params.third_party?
      for index of @params.third_party
        if @params.third_party[index]? and (typeof @params.third_party[index] is 'object')
          for key of @params.third_party[index]
            @params.third_party[index][key] = 1 if @params.third_party[index][key] is true
            @params.third_party[index][key] = 0 if @params.third_party[index][key] is false
        else
          @params.third_party[index] = 1 if @params.third_party[index] is true
          @params.third_party[index] = 0 if @params.third_party[index] is false

# 결제창을 조립해서 만들고 부트페이로 결제 정보를 보낸다.
# 보낸 이후에 app.bootpay.co.kr로 데이터를 전송한다.
  start: ->
    @progressMessageShow ''
    document.getElementById(@iframeId).addEventListener('load', @progressMessageHide)
    document.bootpay_form.target = 'bootpay_inner_iframe'
    document.bootpay_form.submit()

  notify: (data, success = undefined, error = undefined, timeout = 3000) ->
    @removePaymentWindow(false)
    user = @getUserData()
    @applicationId = if data.application_id? then data.application_id else @applicationId
    @params = {}
    @params.device_type = @deviceType
    @params.method = data.method if data.method?
    @params.application_id = @applicationId
    @params.name = data.name
    @params.user_info = data.user_info
    @params.redirect_url = if data.redirect_url? then data.redirect_url else ''
    @params.return_url = if data.return_url? then data.return_url else ''
    @params.phone = if data.phone?.length then data.phone.replace(/-/g, '') else ''
    @params.uuid = if data.uuid?.length then data.uuid else window.localStorage['uuid']
    @params.order_id = if data.order_id? then String(data.order_id) else undefined
    @params.order_info = if data.order_info? then data.order_info else {} # 네이버페이 order 정보
    @params.sk = window.localStorage.getItem('sk')
    @params.time = window.localStorage.getItem('time')
    @params.price = data.price
    @params.format = @option.format if data.format?
    @params.params = data.params
    @params.user_id = if user? then user.id else undefined
    @params.bank_account = if data.bank_account? then data.bank_account else undefined
    @params.bank_name = if data.bank_name? then data.bank_name else undefined
    @params.order_unique = if data.order_unique? then data.order_unique else 0
    @integrityItemData() if @params.items?.length
    @params.items = data.items
    @integrityParams() if !@params.method? or !@params.method isnt 'auth'
    encryptData = AES.encrypt(JSON.stringify(@params), @getData('sk'))
    request.post([@restUrl(), "notify?ver=#{@version}&format=json"].join('/')).set(
      'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
    ).timeout(
      response: timeout
      deadline: timeout
    ).send(
      data: encryptData.ciphertext.toString(Base64)
      session_key: "#{encryptData.key.toString(Base64)}###{encryptData.iv.toString(Base64)}"
    ).then((res) =>
      if res.status isnt 200 or res.body.status isnt 200
        Logger.error "BOOTPAY MESSAGE: #{res.body.message} - Application ID가 제대로 되었는지 확인해주세요."
        error.apply @, ["BOOTPAY MESSAGE: #{res.body.message} - Application ID가 제대로 되었는지 확인해주세요.", res.body] if error?
      else
        success.apply @, [res.body.data] if success?
    ).catch((err) =>
      error.apply @, ["서버 오류로 인해 결제가 되지 않았습니다. #{err.message}"] if error?
    )
# 창이 닫혔을 때 이벤트 처리
  bindBootpayPaymentEvent: ->
    window.off 'message.BootpayGlobalEvent'
    window.on('message.BootpayGlobalEvent', (e) =>
      try
        data = {}
        data = JSON.parse e.data if e.data? and typeof e.data is 'string' and /Bootpay/.test(e.data)
        data.action = data.action.replace(/Child/g, '') if data.action?
      #        console.log data
      catch e
        Logger.error "data: #{e.data}, #{e.message} json parse error"
        return
      switch data.action
        when 'BootpayPopup'
        # iFrame창을 삭제한다.
          @popupData = data
          @progressMessageHide()
          # 아이폰은 사파리 정책상 팝업을 띄우려면 사용자의 직접적인 액션이 있어야 한다.
          if @isMobileSafari()
            @showProgressButton()
          else
            @startPopupPaymentWindow(data)
        when 'BootpayFormSubmit'
          for k, v of data.params
            input = document.createElement('INPUT')
            input.setAttribute('type', 'hidden')
            input.setAttribute('name', k)
            input.value = v
            document.__BOOTPAY_TOP_FORM__.appendChild(input)
          document.__BOOTPAY_TOP_FORM__.action = data.url
          document.__BOOTPAY_TOP_FORM__.acceptCharset = data.charset
          document.__BOOTPAY_TOP_FORM__.submit()
        when 'BootpayCancel'
          @progressMessageShow '취소중입니다.'
          try
            @clearEnvironment()
            @methods.cancel.call @, data if @methods.cancel?
          catch e
            @sendPaymentStepData(
              step: 'cancel'
              status: -1
              e: e
            )
            throw e
          @sendPaymentStepData(
            step: 'cancel'
            status: 1
          )
          @removePaymentWindow()
        when 'BootpayBankReady'
          try
            @clearEnvironment()
            @methods.ready.call @, data if @methods.ready?
          catch e
            @sendPaymentStepData(
              step: 'ready'
              status: -1
              e: e
            )
            throw e
          @sendPaymentStepData(
            step: 'ready'
            status: 1
          )
        when 'BootpayConfirm'
          @progressMessageShow '승인중입니다.'
          try
            @clearEnvironment()
            if !@methods.confirm?
              @transactionConfirm data
            else
              @methods.confirm.call(@, data)
          catch e
            @sendPaymentStepData(
              step: 'confirm'
              status: -1
              e: e
            )
            throw e
          @sendPaymentStepData(
            step: 'confirm'
            status: 1
          )
        when 'BootpayResize'
          iframeSelector = document.getElementById(@iframeId)
          backgroundSelector = document.getElementById(@backgroundId)
          closeSelector = document.getElementById(@closeId)
          if data.reset
            iframeSelector.removeAttribute 'style'
            backgroundSelector.removeAttribute 'style'
            closeSelector.removeAttribute 'style'
            iframeSelector.setAttribute('scrolling', undefined)
          else
            iframeSelector.style.setProperty('max-width', data.width)
            iframeSelector.style.setProperty('width', '100%')
            iframeSelector.style.setProperty('height', data.height)
            iframeSelector.style.setProperty('max-height', data.maxHeight)
            iframeSelector.style.setProperty('background-color', data.backgroundColor) if data.backgroundColor?
            backgroundSelector.style.setProperty('background-color', 'transparent') if data.transparentMode is 'true'
            closeSelector.style.setProperty('display', 'block') if data.showCloseWindow is 'true'
            # ie 9이하에서는 overflow 속성을 인식하지 못한다.
            iframeSelector.style.overflow = data.overflow
            iframeSelector.setAttribute 'scrolling', data.scrolling if data.scrolling?
        when 'BootpayError'
          try
            @clearEnvironment()
            @methods.error.call @, data if @methods.error?
          catch e
            @sendPaymentStepData(
              step: 'error'
              status: -1
              msg: e
            )
            throw e
          @sendPaymentStepData(
            step: 'error'
            status: 1
          )
          @removePaymentWindow()
        when 'BootpayDone'
          @progressMessageHide()
          try
            @clearEnvironment(data.popup_close)
            @methods.done.call @, data
          catch e
            @sendPaymentStepData(
              step: 'done'
              status: -1
              e: e
            )
            throw e
          @sendPaymentStepData(
            step: 'done'
            status: 1
          )
          isClose = if data.is_done_close? then data.is_done_close  else true
          @removePaymentWindow() if isClose
        when 'BootpayClose'
          @progressMessageHide()
          @removePaymentWindow()
    )
  bindBootpayCommonEvent: ->
    window.off 'message.BootpayCommonEvent'
    window.on('message.BootpayCommonEvent', (e) =>
      try
        data = {}
        data = JSON.parse e.data if e.data? and typeof e.data is 'string' and /Bootpay/.test(e.data)
      catch e
        Logger.debug "data: #{e.data}, #{e.message} json parse error"
        return
      switch data.action
        when 'BootpayAnalyticsData'
          e.source.postMessage(JSON.stringify(
            action: 'BootpayAnalyticsReceived'
            uuid: @getData('uuid')
            sk: @getData('sk')
            sk_time: @getData('sk_time')
            time: @getData('time')
            user: @getData('user')
          ), '*')
        when 'BootpayAnalyticsReceived'
          Logger.debug "receive analytics data: #{JSON.stringify(data)}"
          @setAnalyticsData(data)
    )

# 결제 실행 단계를 로그로 보낸다.
  sendPaymentStepData: (data) ->
    return if !@tk? or !@applicationId? # Transaction key가 없다면 실행할 필요가 없다.
    data.version = @version
    data.tk = @tk
    data.application_id = @applicationId
    if data.e?
      data.msg = try data.e.message
      catch then data.e
      data.trace = try data.e.stack
      catch then undefined
    encryptData = AES.encrypt(JSON.stringify(data), @getData('sk'))
    request.post([@analyticsUrl(), "event"].join('/')).set(
      'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
    ).send(
      data: encryptData.ciphertext.toString(Base64)
      session_key: "#{encryptData.key.toString(Base64)}###{encryptData.iv.toString(Base64)}"
    ).then((res) =>
      Logger.debug "BOOTPAY MESSAGE: 결제 이벤트 데이터 정보 전송"
    ).catch((err) =>
      Logger.error "BOOTPAY MESSAGE: 결제 이벤트 데이터 정보 전송실패 #{JSON.stringify(err)}"
    )

  forceClose: ->
    @methods.cancel.call @, {
      action: 'BootpayCancel',
      message: '사용자에 의한 취소'
    } if @methods.cancel?
    @removePaymentWindow()

  isLtBrowserVersion: (version) ->
    sAgent = window.navigator.userAgent
    idx = sAgent.indexOf("MSIE")
    return false unless idx > 0
    version > parseInt(sAgent.substring(idx + 5, sAgent.indexOf(".", idx)))
# IE 버전 blocking
  blockIEVersion: -> @isLtBrowserVersion @ieMinVersion
# 결제창을 삭제한다.
  removePaymentWindow: (callClose = true) ->
    document.body.style.removeProperty('bootpay-modal-open')
    try document.body.classList.remove('bootpay-open')
    catch then ''
    document.getElementById(@windowId).outerHTML = '' if document.getElementById(@windowId)?
    try
      @methods.close @ if @methods.close? and callClose
    catch e
      @sendPaymentStepData(
        step: 'close'
        status: -1
        e: e
      )
      throw e
    @sendPaymentStepData(
      step: 'close'
      status: 1
    )
    @tk = undefined
# 결제할 iFrame 창을 만든다.
  iframeHtml: (url) ->
    """
<iframe id="#{@iframeId}" name="bootpay_inner_iframe" src="#{url}" allowtransparency="true" scrolling="no"></iframe>
<div class="progress-message-window" id="bootpay-progress-message">
  <div class="progress-message spinner">
    <div class="bounce1 bounce"></div><div class="bounce2 bounce"></div><div class="bounce3 bounce"></div>         &nbsp;
    <span class="text" id="progress-message-text"></span>
  </div>
</div>
<div class="progress-message-window over" id="bootpay-progress-button-window">
  <div class="close-message-box">
    <div class="close-popup">
      <h4 class="sub-title">선택하신 결제는 팝업으로 결제가 시작됩니다. 결제를 시작할까요?</h4>
      <button class="close-payment-window" onclick="window.BootPay.startPopup();" type="button" id="__bootpay-close-button">결제 시작하기</button>
    </div>
  </div>
</div>
    """
  startPopup: ->
    @startPopupPaymentWindow(@popupData)

  progressMessageHide: ->
    pms = document.getElementById('bootpay-progress-message')
    pms.style.setProperty('display', 'none')
    document.getElementById('progress-message-text').innerText = ''
    try document.getElementById(@iframeId).removeEventListener('load', @progressMessageHide)
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

  cancel: (method) ->
    @methods.cancel = method
    @
  confirm: (method) ->
    @methods.confirm = method
    @
  ready: (method) ->
    @methods.ready = method
    @
  error: (method) ->
    @methods.error = method
    @
  done: (method) ->
    @methods.done = method
    @
  close: (method) ->
    @methods.close = method
    @

  setConfirmLock: (lock) ->
    @CONFIRM_LOCK = lock

  isConfirmLock: ->
    @CONFIRM_LOCK

  clearEnvironment: (isClose = 1) ->
    clearInterval(@popupWatchInstance) if @popupWatchInstance
    isClose = if isClose? then isClose else 1
    if @popupInstance? and isClose
      @popupInstance.close()
      @popupInstance = undefined

  startPopupPaymentWindow: (data) ->
    document.getElementById(@iframeId).style.display = 'none';
    @clearEnvironment()
    @hideProgressButton()
    @progressMessageShow('팝업창을 닫으면 종료됩니다.')
    query = []
    for k, v of data.params
      query.push("#{k}=#{v}")
    @popupInstance = window.open("#{data.submit_url}?#{query.join('&')}", 'bootpay_inner_popup')
    @popupWatchInstance = setInterval(=>
      if @popupInstance.closed # 창을 닫은 경우
        clearInterval(@popupWatchInstance) if @popupWatchInstance?
        window.postMessage(
          JSON.stringify(
            action: 'BootpayCancel'
            message: '팝업창을 닫았습니다.'
          )
        , '*')
    , 3000)

  transactionConfirm: (data) ->
    if @isConfirmLock()
      console.log 'Transaction Lock'
    else
      @setConfirmLock(true)
      if !data? or !data.receipt_id?
        alert '결제 승인을 하기 위해서는 receipt_id 값이 포함된 data값을 함께 보내야 합니다.'
        Logger.error 'this.transactionConfirm(data); 이렇게 confirm을 실행해주세요.'
        return

      html = """
        <input type="hidden" name="receipt_id" value="#{data.receipt_id}" />
        <input type="hidden" name="application_id" value="#{@applicationId}" />
      """
      document.getElementById('bootpay_confirm_form').innerHTML = html
      document.bootpay_confirm_form.action = [@restUrl(), 'confirm'].join('/')
      document.bootpay_confirm_form.target = 'bootpay_inner_iframe'
      document.bootpay_confirm_form.submit()
    @

# 네이버페이 Zzim 추가 Method
  addNaverPayZzim: (data, timeout = 60000) ->
    @removePaymentWindow(false)
    @setApplicationId data.application_id if data.application_id?
    try
      throw new Error('item_id를 입력해주세요.') unless data.item_id?.length
      throw new Error('item_name을 입력해주세요.') unless data.item_name?.length
      throw new Error('item_desc를 입력해주세요.') unless data.item_desc?.length
      throw new Error('item_uprice를 입력해주세요.') unless data.item_uprice?
      throw new Error('item_image를 입력해주세요.') unless data.item_image?.length
      throw new Error('item_url을 입력해주세요.') unless data.item_url?.length
    catch e then return alert(e.message)
    requestUrl = @naverpayZzimUrl((if data.test_mode then 'development' else 'production'), (if @isMobile() then 'mobile' else 'pc'))
    encryptData = AES.encrypt(JSON.stringify(data), @getData('sk'))
    request.post([@restUrl(), "npay/zzim.json"].join('/')).set(
      'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
    ).timeout(
      response: timeout
      deadline: timeout
    ).send(
      data: encryptData.ciphertext.toString(Base64)
      session_key: "#{encryptData.key.toString(Base64)}###{encryptData.iv.toString(Base64)}"
    ).end(
      (error, response) =>
        if response.statusCode is 200
          document.body.insertAdjacentHTML 'beforeend', """
            <div id="#{@windowId}">
              <form id="__BOOTPAY_TOP_FORM__" name="__BOOTPAY_TOP_FORM__" action="#{[@restUrl(), 'continue'].join('/')}" method="post">
            </div>
          """
          document.__BOOTPAY_TOP_FORM__.innerHTML = """
            <input type="hidden" name="ITEM_ID" value="#{response.body.data.item_id}" />
            <input type="hidden" name="SHOP_ID" value="#{response.body.data.shop_id}" />
          """
          @popupInstance = window.open("about:blank", 'bootpay_inner_popup', if @isMobile() then '' else 'width=500,height=300,toolbar=no,location=no,status=no,scrollbar=no,menubar=no')
          document.__BOOTPAY_TOP_FORM__.action = requestUrl
          document.__BOOTPAY_TOP_FORM__.target = 'bootpay_inner_popup'
          document.__BOOTPAY_TOP_FORM__.method = 'GET'
          document.__BOOTPAY_TOP_FORM__.submit()
        else
          Logger.error response.body
          alert(response.body.message)
    )
  # thirdparty API 데이터
  setThirdPartyApi: (key, value) ->
    @thirdPartyData[key] = value

  useOnestoreApi: (thirdPartyOption = {}, enable = true) ->
    thirdPartyOption.use = enable
    @setThirdPartyApi 'onestore', thirdPartyOption

window.BootPay.initialize()

export default window.BootPay