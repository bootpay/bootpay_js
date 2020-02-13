import Logger from '../logger'
export default {
  # RestURL 정보
  restUrl: ->
    @urls.restUrl[@mode]
  # 클라이언트 URL 정보
  clientUrl: ->
    @urls.clientUrl[@mode]
  # Analytics URL 정보
  analyticsUrl: ->
    @urls.analyticsUrl[@mode]
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
  # 로그 레벨을 설정한다.
  setLogLevel: (logLevel = 1) -> Logger.setLogLevel logLevel
  # 사용할 환경 mode를 설정한다
  setMode: (mode) -> @mode = mode

  # device Type을 설정한다. 없을 경우 false를 리턴, 있는 경우 true를 리턴
  setDevice: (deviceType) ->
    @deviceType = @ableDeviceTypes[deviceType] if @ableDeviceTypes[deviceType]?
    @ableDeviceTypes[deviceType]?
}