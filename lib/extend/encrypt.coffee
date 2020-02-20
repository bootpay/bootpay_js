import AES from 'crypto-js/aes'
import Base64 from 'crypto-js/enc-base64'

export default {
  encryptParams: (data) ->
    encryptData = AES.encrypt(JSON.stringify(data), @getData('sk'))
    {
      data: encryptData.ciphertext.toString(Base64),
      session_key: "#{encryptData.key.toString(Base64)}###{encryptData.iv.toString(Base64)}"
    }
}