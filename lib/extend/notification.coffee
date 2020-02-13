import Logger from '../logger'
import AES from 'crypto-js/aes'
import Base64 from 'crypto-js/enc-base64'
import request from 'superagent'

export default {
  # 결제 정보를 서버로 전송
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
    @params.delivery_price = data.delivery_price
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
}