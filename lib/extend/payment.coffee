import Logger from '../logger'
import request from 'superagent'

export default {
# 결제 정보를 보내 부트페이에서 결제 정보를 띄울 수 있게 한다.
  request: (data, lazy = false) ->
    return if @isPaymentLock()
    @removePaymentWindow(false)
    @setPaymentLock(true)
    @bindBootpayPaymentEvent()
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
        user_token: data.user_token if data.user_token?
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
      # 각 함수 호출 callback을 초기화한다.
      # async의 경우엔 초기화하지 않는다
      @methods = {} unless lazy
      @extraValueAppend()
      # 아이템 정보의 Validation
      @integrityItemData() if @params.items?.length
      # 결제 정보 데이터의 Validation
      @integrityParams()
      # True, False의 데이터를 1, 0으로 변경하는 작업을 한다
      @generateTrueFalseParams()
      # 데이터를 AES로 암호화한다.
      encryptData = @encryptParams(@params)
      html = """
        <div id="#{@windowId}">
          <form name="bootpay_form" action="#{[@restUrl(), 'start', 'js', '?ver=' + @version].join('/')}" method="POST">
            <input type="hidden" name="data" value="#{encryptData.data}" />
            <input type="hidden" name="session_key" value="#{encryptData.session_key}" />
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
      @setPaymentLock(false)
      throw e
    @sendPaymentStepData(
      step: 'start'
      status: 1
    )
    @

  startPaymentByUrl: (url, tk = undefined) ->
    try
      @bindBootpayPaymentEvent()
      @removePaymentWindow(false)
      @setConfirmLock(false)
      @tk = if tk?.length then tk else "#{@generateUUID()}-#{(new Date).getTime()}"
      html = """
          <div id="#{@windowId}">
            <form name="bootpay_form" action="#{url}" method="GET">
              <input type="hidden" name="tk" value="#{@tk}" />
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
      throw '결제할 금액을 설정해주세요. ( 100원 이상, 본인인증/정기 결제요청의 경우엔 0원을 입력해주세요. ) [ params: price ]' if (isNaN(price) or price < 100) and (@zeroPaymentMethod.indexOf(@params.method) > -1 or (not @params.method?.length or not @params.pg?.length))
      throw '판매할 상품명을 입력해주세요. [ params: name ]' unless @params.name?.length
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

# Extra value를 조건에 맞게 추가
  extraValueAppend: ->
    if @isSetQuickPopup
      @params.extra ?= {}
      @params.extra.quick_popup = true
      @params.extra.popup = true
      @isSetQuickPopup = false

# 결제창을 조립해서 만들고 부트페이로 결제 정보를 보낸다.
# 보낸 이후에 app.bootpay.co.kr로 데이터를 전송한다.
  start: ->
    @progressMessageShow ''
    if @params.extra? and @params.extra.popup and @params.extra.quick_popup
      @doStartPopup(
        width: '300'
        height: '300'
      )
    else
      @doStartIframe()

# 기존 iFrame으로 결제를 시작한다
  doStartIframe: ->
    # 팝업이 떠있으면 일단 닫는다
    @popupInstance.close() if @popupInstance?
    document.getElementById(@iframeId).addEventListener('load', @progressMessageHide)
    document.bootpay_form.target = 'bootpay_inner_iframe'
    document.bootpay_form.submit()

# 팝업으로 결제를 시작한다
  doStartPopup: (platform) ->
    unless @popupInstance?
      spec = if platform? and platform.width? and platform.width > 0 then "width=#{platform.width},height=#{platform.height},top=#{0},left=#{0},scrollbars=yes,toolbar=no, location=no, directories=no, status=no, menubar=no" else ''
      @popupInstance = window.open('about:blank', 'bootpayPopup', spec)
    @showPopupEventProgress()
    document.bootpay_form.target = 'bootpayPopup'
    document.bootpay_form.submit()

# 팝업으로 시작하는 조건 부 async request 추가
  popupAsyncRequest: (conditions, method) ->
    return alert('비동기로 실행될 함수가 있어야 합니다.') unless method?
    # 먼저 팝업을 띄운다
    @startQuickPopup() if conditions
    # 함수 초기화
    @methods = {}
    method.call().then(
      (data) =>
        @request(data, true)
      (e) =>
        @clearEnvironment(true)
        @forceClose(e.message)
    )
    @

# 사용자 promise 가 발생되기 전 선 팝업을 띄운다
  startQuickPopup: ->
    @isSetQuickPopup = true
    @expressPopupReady()

# 미리 팝업을 준비한다
  expressPopupReady: ->
    if platform? and platform.width? and platform.width > 0
      spec = "width=#{platform.width},height=#{platform.height},top=#{0},left=#{0},scrollbars=yes,toolbar=no, location=no, directories=no, status=no, menubar=no"
    else
      spec = if @isMobile() then '' else "width=750,height=500,top=#{0},left=#{0},scrollbars=yes,toolbar=no, location=no, directories=no, status=no, menubar=no"
    @popupInstance = window.open('https://inapp.bootpay.co.kr/waiting', 'bootpayPopup', spec)

# 결제할 iFrame 창을 만든다.
  iframeHtml: (url) ->
    """
<iframe id="#{@iframeId}" style="height: 0;" name="bootpay_inner_iframe" src="#{url}" allowtransparency="true" scrolling="no"></iframe>
<div class="progress-message-window" id="bootpay-progress-message">
  <div class="progress-message">
    <div class="bootpay-loading">
      <div class="bootpay-loading-spinner">
        <svg viewBox="25 25 50 50" class="bootpay-circle" xmlns="http://www.w3.org/2000/svg">
          <circle cx="50" cy="50" r="20" fill="none" class="bootpay-path"></circle>
        </svg>
      </div>
    </div>
    <div class="bootpay-text">
      <span class="bootpay-inner-text" id="progress-message-text"></span>
    </div>
    <div class="bootpay-popup-close" id="__bootpay-popup-close-button__" style="display: none;">
      <button onclick="window.BootPay.closePopupWithPaymentWindow()">×</button>
    </div>
  </div>
</div>
<div class="progress-message-window over" id="bootpay-progress-button-window">
  <div class="close-message-box">
    <div class="close-popup">
      <div class="close-popup-header">
        <button class="close-btn" onclick="window.BootPay.removePaymentWindow()">×</button>
      </div>
      <h4 class="sub-title" id="__bootpay_close_button_title">선택하신 결제는 팝업으로 결제가 시작됩니다. 결제를 시작할까요?</h4>
      <button class="close-payment-window" onclick="window.BootPay.startPopup();" type="button" id="__bootpay-close-button">결제하기</button>
    </div>
  </div>
</div>
    """

# 팝업결제를 실행한다
  startPopup: ->
    @startPopupPaymentWindow(@popupData)

# 간편결제 비밀번호 direct로 뜨게끔
  verifyPassword: (data = {}) ->
    verifyUrl = [@clientUrl(), 'verify', 'password'].join('/')
    encryptData = @encryptParams(
      user_token: data.userToken
      device_id: data.deviceId
      message: data.message
    )
    document.body.insertAdjacentHTML(
      'beforeend',
      """
        <div id="#{@windowId}">
          <form name="bootpayVerifyForm" action="#{verifyUrl}" method="GET">
            <input type="hidden" name="data" value="#{encryptData.data}" />
            <input type="hidden" name="session_key" value="#{encryptData.session_key}" />
          </form>
          <div class="bootpay-window" id="bootpay-background-window">#{@iframeHtml('')}</div>
        </div>
      """
    )
    @bindVerifyPasswordEvent()
    try document.body.classList.add('bootpay-open')
    catch then ''
    document.getElementById(@iframeId).style.setProperty('height', '100%')
    document.bootpayVerifyForm.target = 'bootpay_inner_iframe'
    document.bootpayVerifyForm.submit()
    @


# 결제를 승인한다
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
      document.bootpay_confirm_form.action = "#{[@restUrl(), 'confirm'].join('/')}?#{@generateUUID()}"
      document.bootpay_confirm_form.target = 'bootpay_inner_iframe'
      document.bootpay_confirm_form.submit()
    @
}