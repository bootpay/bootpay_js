import Logger from '../logger'
import AES from 'crypto-js/aes'
import Base64 from 'crypto-js/enc-base64'
import request from 'superagent'

export default {
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
      Logger.warn "BOOTPAY MESSAGE: #{if res.body? then res.body.message else ''} - Application ID가 제대로 되었는지 확인해주세요." if res.status isnt 200 or res.body.status isnt 200
    ).catch((err) =>
      Logger.warn "BOOTPAY MESSAGE: #{if err.body? then err.body.message else ''} - Application ID가 제대로 되었는지 확인해주세요."
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
}