import Logger from '../logger'
import request from 'superagent'

export default {
# 창이 닫혔을 때 이벤트 처리
  bindBootpayPaymentEvent: ->
    window.off 'message.BootpayGlobalEvent'
    window.on('message.BootpayGlobalEvent', (e) =>
      try
        data = {}
        data = JSON.parse e.data if e.data? and typeof e.data is 'string' and /Bootpay/.test(e.data)
        data.action = data.action.replace(/Child/g, '') if data.action?
      catch e
        Logger.error "data: #{e.data}, #{e.message} json parse error"
        return
      switch data.action
      # 팝업창으로 결제창 호출 이벤트
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayPopup'
        # iFrame창을 삭제한다.
          @popupData = data
          @progressMessageHide()
          if @isIE()
            @startPopupPaymentWindow(data)
          else
            @showPopupButton()
      # 결제창 form submit 방식으로 동작할 때 action
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
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
      # 사용자가 결제창을 취소했을 때 이벤트
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayCancel'
          @progressMessageShow '취소중입니다.'
          try
            @clearEnvironment()
            @cancelMethodCall(data) if @methods.cancel?
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
      # 가상계좌 입금 대기 상태 ( 계좌 발급이 되었을 때 호출 )
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayBankReady'
          try
            @progressMessageHide()
            @clearEnvironment(if @popupInstance? then 0 else 1)
            @readyMethodCall(data)
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
      # 결제 승인 전 action
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayConfirm'
          @progressMessageShow '승인중입니다.'
          try
            @clearEnvironment()
            if !@methods.confirm?
              @transactionConfirm data
            else
              @confirmMethodCall(data)
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
      # 결제창 resize 이벤트
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
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
      # 결제 진행시 오류가 났을 때 호출 되는 action
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayError'
          try
            @clearEnvironment()
            @errorMethodCall(data)
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
      # 결제 완료시 호출되는 action
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayDone'
          @progressMessageHide()
          try
            @clearEnvironment(data.popup_close)
            @doneMethodCall(data)
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
          isClose = if data.is_done_close? then data.is_done_close else true
          @removePaymentWindow() if isClose
      # 사용자 혹은 PG에서 창이 닫히는 action
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayClose'
          @clearEnvironment()
          @progressMessageHide()
          @removePaymentWindow()
      # iFrame 결제창을 app에서 notify 받아 보여준다
      # Comment by Gosomi
      # Date: 2020-06-30
      # @return [undefined]
        when 'BootpayShowPaymentWindow'
        # iframe 창의 결제창을 보여준다
          document.getElementById(@iframeId).style.removeProperty('display')
          document.getElementById(@iframeId).style.setProperty('height', '100%')
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
# 비밀번호 인증 관련 event를 받는다
# Comment by Gosomi
# Date: 2020-10-10
# @return [Hash]
  bindEasyEvent: ->
    window.off 'message.BootpayEasyEvent'
    window.on('message.BootpayEasyEvent', (e) =>
      try
        data = {}
        data = JSON.parse e.data if e.data? and typeof e.data is 'string' and /Bootpay/.test(e.data)
        data.action = data.action.replace(/Child/g, '') if data.action?
      catch e
        Logger.error "data: #{e.data}, #{e.message} json parse error"
        return
      switch data.action
        when 'BootpayEasyError'
          @methods.easyError(data) if @methods.easyError?
          @removeVerifyWindow()
        when 'BootpayEasySuccess'
          @methods.easySuccess(data) if @methods.easySuccess?
          @removeVerifyWindow()
        when 'BootpayEasyCancel'
          @methods.easyCancel(data) if @methods.easyCancel?
          @removeVerifyWindow()
    )
# 강제로 창을 닫는다
# Comment by Gosomi
# Date: 2020-02-13
# @return [undefined]
  forceClose: (message = undefined) ->
    @cancelMethodCall(
      action: 'BootpayCancel',
      message: if message? then message else '사용자에 의한 취소'
    )
    @removePaymentWindow()

  timeIntervalByPlatform: ->
    if @isMobile() then 300 else 0

# 결제창을 삭제한다.
  removePaymentWindow: (callClose = true) ->
    # Payment Lock을 해제한다
    @setPaymentLock(false)
    @progressMessageHide()
    document.body.style.removeProperty('bootpay-modal-open')
    try document.body.classList.remove('bootpay-open')
    catch then ''
    document.getElementById(@windowId).outerHTML = '' if document.getElementById(@windowId)?
    try
      @closeMethodCall() if callClose
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

# 비밀번호 창을 닫는다
  removeVerifyWindow: ->
    @progressMessageHide()
    document.body.style.removeProperty('bootpay-modal-open')
    try document.body.classList.remove('bootpay-open')
    catch then ''
    document.getElementById(@windowId).outerHTML = '' if document.getElementById(@windowId)?

  closePopupWithPaymentWindow: ->
    if confirm "결제창을 닫게 되면 현재 진행중인 결제가 취소됩니다. 정말로 닫을까요?"
      @clearEnvironment(true)
      @removePaymentWindow()

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

  easyCancel: (method) ->
    @methods.easyCancel = method
    @

  easySuccess: (method) ->
    @methods.easySuccess = method
    @

  easyError: (method) ->
    @methods.easyError = method
    @

  setConfirmLock: (lock) ->
    @CONFIRM_LOCK = lock

  setPaymentLock: (lock) ->
    @PAYMENT_LOCK = lock

  isPaymentLock: ->
    @PAYMENT_LOCK

  isConfirmLock: ->
    @CONFIRM_LOCK

# 결제 실행 단계를 로그로 보낸다.
  sendPaymentStepData: (data) ->
    return if !@tk? or !@applicationId? # Transaction key가 없다면 실행할 필요가 없다.
    data.version = @version
    data.tk = @tk
    data.application_id = @applicationId
    if data.e?
      data.msg = try data.e.message
      catch then ''
      data.trace = try data.e.stack
      catch then undefined
    request.post([@analyticsUrl(), "event"].join('/')).set(
      'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
    ).send(
      @encryptParams(data)
    ).then((res) =>
      Logger.debug "BOOTPAY MESSAGE: 결제 이벤트 데이터 정보 전송"
    ).catch((err) =>
      Logger.error "BOOTPAY MESSAGE: 결제 이벤트 데이터 정보 전송실패 #{JSON.stringify(err)}"
    )

# 팝업 watcher를 삭제한다
# 창이 닫힌다면 팝업창도 강제로 닫는다
  clearEnvironment: (isClose = 1) ->
    clearInterval(@popupWatchInstance) if @popupWatchInstance?
    isClose = if isClose? then isClose else 1
    if @popupInstance? and isClose
      @popupInstance.close()
      @popupInstance = undefined

# 팝업 창이 시작될 때 각 이벤트를 binding하고
# 팝업창을 띄우고나서 팝업이 닫히는지 매번확인한다
  startPopupPaymentWindow: (data) ->
    if @isMobileSafari
      window.off('pagehide.bootpayUnload')
      window.on('pagehide.bootpayUnload', =>
        @popupInstance.close() if @popupInstance?
      )
    else
      window.off('beforeunload.bootpayUnload')
      window.on('beforeunload.bootpayUnload', =>
        @popupInstance.close() if @popupInstance?
      )

    document.getElementById(@iframeId).style.display = 'none';
    @clearEnvironment()
    @hideProgressButton()
    @progressMessageShow('팝업창을 닫으면 종료됩니다.', true)
    query = []
    for k, v of data.params
      query.push("#{k}=#{v}") if ['su', 'pa_id'].indexOf(k) > -1
    setTimeout(=>
      @popupInstance.close() if @popupInstance?
      # 플랫폼에서 설정해야할 정보를 가져온다
      platform = try data.params.pe[@platformSymbol()]
      catch then {}
      left = try if  window.screen.width < platform.width then 0 else (window.screen.width - platform.width) / 2
      catch then '100'
      top = try if  window.screen.height < platform.height then 0 else (window.screen.height - platform.height) / 2
      catch then '100'
      spec = if platform? and platform.width? and platform.width > 0 then "width=#{platform.width},height=#{platform.height},top=#{top},left=#{left},scrollbars=yes,toolbar=no, location=no, directories=no, status=no, menubar=no" else ''
      @popupInstance = window.open("#{data.submit_url}?#{query.join('&')}", "bootpay_inner_popup_#{(new Date).getTime()}", spec)
      return window.postMessage(
        JSON.stringify(
          action: 'BootpayError'
          message: '브라우저의 팝업이 차단되어 결제가 중단되었습니다. 브라우저 팝업 허용을 해주세요.'
        )
      , '*') unless @popupInstance?
      # 팝업 창이 닫혔는지 계속해서 찾는다
      @popupWatchInstance = setInterval(=>
        if @popupInstance.closed # 창을 닫은 경우
          clearInterval(@popupWatchInstance) if @popupWatchInstance?
          if @isMobileSafari then window.off('pagehide.bootpayUnload') else window.off('beforeunload.bootpayUnload')
          # IE 인 경우에 팝업이 뜨면 결제가 완료되었는지 데이터를 확인해본다
          if @isIE()
            request.put([@restUrl(), "confirm", "#{data.params.su}.json"].join('/')).set(
              'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
            ).send(
              @encryptParams(
                application_id: @applicationId
                tk: @tk
              )
            ).then((res) =>
              if res.body? and res.body.code is 0
                setTimeout(=>
                  window.postMessage(
                    JSON.stringify(
                      res.body.data
                    )
                  , '*')
                , 300)
              else
                window.postMessage(
                  JSON.stringify(
                    action: 'BootpayCancel'
                    message: '팝업창을 닫았습니다.'
                  )
                , '*')
            ).catch((err) =>
              window.postMessage(
                JSON.stringify(
                  action: 'BootpayCancel'
                  message: "팝업창을 닫았습니다."
                )
              , '*')
            )
          else
            window.postMessage(
              JSON.stringify(
                action: 'BootpayCancel'
                message: '팝업창을 닫았습니다.'
              )
            , '*')
      , 300)
    , 100)

  showPopupEventProgress: ->
    if @isMobileSafari
      window.off('pagehide.bootpayUnload')
      window.on('pagehide.bootpayUnload', =>
        @popupInstance.close() if @popupInstance?
      )
    else
      window.off('beforeunload.bootpayUnload')
      window.on('beforeunload.bootpayUnload', =>
        @popupInstance.close() if @popupInstance?
      )
    @progressMessageShow('팝업창을 닫으면 종료됩니다.', true)
    @popupWatchInstance = setInterval(=>
      if @popupInstance.closed # 창을 닫은 경우
        clearInterval(@popupWatchInstance) if @popupWatchInstance?
        if @isMobileSafari then window.off('pagehide.bootpayUnload') else window.off('beforeunload.bootpayUnload')
        # IE 인 경우에 팝업이 뜨면 결제가 완료되었는지 데이터를 확인해본다
        if @isIE() and @params.tk?
          request.put([@restUrl(), "confirm", "#{@tk}.json"].join('/')).set(
            'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'
          ).send(
            @encryptParams(
              application_id: @applicationId
              method: 'transaction_key'
              tk: @tk
            )
          ).then((res) =>
            if res.body? and res.body.code is 0
              setTimeout(=>
                window.postMessage(
                  JSON.stringify(
                    res.body.data
                  )
                , '*')
              , 300)
            else
              window.postMessage(
                JSON.stringify(
                  action: 'BootpayCancel'
                  message: '팝업창을 닫았습니다.'
                )
              , '*')
          ).catch((err) =>
            window.postMessage(
              JSON.stringify(
                action: 'BootpayCancel'
                message: "팝업창을 닫았습니다."
              )
            , '*')
          )
        else
          window.postMessage(
            JSON.stringify(
              action: 'BootpayCancel'
              message: '팝업창을 닫았습니다.'
            )
          , '*')
    , 300)


  showPopupButton: ->
    alias = try @popupData.params.payment.pm_alias
    catch then ''
    buttonObject = document.getElementById("__bootpay-close-button")
    buttonObject.classList.remove('naverpay-btn')
    # 네이버페이인 경우 네이버페이 색상으로 편집
    if alias is 'npay'
      document.getElementById("__bootpay_close_button_title").innerText = '네이버페이로 결제를 시작합니다'
      buttonObject.innerText = '네이버페이로 결제하기'
      buttonObject.classList.add('naverpay-btn')
    @showProgressButton()
}