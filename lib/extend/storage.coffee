export default {
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

# 모든 캐시를 날린다
# Comment by Gosomi
# Date: 2020-04-03
# @return [Boolean]
  clearCache: ->
    @setData('pe_development', undefined)
    @setData('pe_stage', undefined)
    @setData('pe_production', undefined)
}