# Bootpay JS

## 부트페이 결제 요청 JS SDK
코드 한줄로 구현하는 Bootpay JS 모듈입니다. 개발 언어는 coffeescript로 되어 있으며, jQuery 의존성이 있는 1.x.x버전은 Private Git 저장소로 관리중이며, jQuery의존성이 없는 2.x.x는 GitHub에 오픈소스로 개발되었습니다.
2.x.x는 Webpack으로 컴파일 되며, webpack-dev-server를 통해 테스트 서버로 결제를 테스트 할 수도 있습니다.

## NPM URL
NPM으로 다운 받을 수 있는 경로는 다음과 같습니다.
https://www.npmjs.com/package/bootpay-js

## 연동 방법
### 1. CDN으로 Javascript 호출하기
```html
<script src="https://cdn.bootpay.co.kr/js/bootpay-2.0.12.min.js" type="application/javascript"></script>
```

### 2. npm으로 설치하기
```shell
npm install bootpay-js
```
설치 한 후에
``` javascript
var BootPay = require('bootpay-js');
```
형태로 사용이 가능합니다.

### 3. Webpack Package 사용
```json
{
  "dependencies": {
    //...
    "bootpay-js": "^2.0.12"
    //...
  }
}
```

```coffeescript
import BootPay from 'bootpay-js'
```

### 4. Require JS 사용
```html
<script type="text/javascript">
    //jQuery 수정 버전을 로드한다.
    require(["https://cdn.bootpay.co.kr/js/bootpay-2.0.12.min.js"], function(BootPay) {
        BootPay.request({
            // anyThing Data
        });
    });
</script>
```

## 부트페이로 결제 연동하기 전에
* Bootpay Admin (https://admin.bootpay.co.kr) 로 간 후 먼저 회원가입을 해주세요.
* Bootpay Docs (https://docs.bootpay.co.kr) 로 가셔서 연동전 필요한 준비를 해주세요.

## 부트페이 JS 결제창 띄우기
```javascript
BootPay.request({
        price: 3000, // 결제할 금액
        application_id: '(부트페이 관리자에서 Web용 Application ID 입력해주세요.)',
        name: '(판매할 아이템이름)', // 아이템 이름,
        phone: '(구매자 전화번호 ex) 01000000000)',
        order_id: '(이 결제를 식별할 수 있는 고유 주문 번호)',
        pg: '(결제창을 띄우려는 PG 회사명 ex) kcp, danal)',
        method: '(결제수단 정보 ex) card, phone, vbank, bank)',
        show_agree_window: 0, // 결제 동의창 띄우기 여부 1 - 띄움, 0 - 띄우지 않음
        items: [ // 결제하려는 모든 아이템 정보 ( 통계 데이터로 쓰이므로 입력해주시면 좋습니다. 입력하지 않아도 결제는 가능합니다.)
            {
                item_name: '(판매된 아이템 명)',
                qty: 1, // 판매한 아이템의 수량
                unique: '(아이템을 식별할 수 있는 unique key)', 
                price: 3000 // 아이템 하나의 단가
            }
        ],
        user_info: { // 구매한 고객정보 ( 통계 혹은 PG사에서 요구하는 고객 정보 )
            email: '(이메일)',
            phone: '(고객의 휴대폰 정보)',
            gender: '(고객의 성별)',
            birth: '(고객의 생년월일)',
            area: '(고객의 거주지역)'
        }
    }).error(function (data) { 
        // 결제가 실패했을 때 호출되는 함수입니다.
        var msg = "결제 에러입니다.: " + JSON.stringify(data);
        alert(msg);
        console.log(data);
    }).cancel(function (data) {
        // 결제창에서 결제 진행을 하다가 취소버튼을 눌렀을때 호출되는 함수입니다.
        var msg = "결제 취소입니다.: " + JSON.stringify(data);
        alert(msg);
        console.log(data);
    }).confirm(function (data) {
        // 결제가 진행되고 나서 승인 이전에 호출되는 함수입니다.
        // 일부 결제는 이 함수가 호출되지 않을 수 있습니다. ex) 가상계좌 및 카드 수기결제는 호출되지 않습니다.        
        // 만약 이 함수를 정의하지 않으면 바로 결제 승인이 일어납니다.
        if (confirm('결제를 정말 승인할까요?')) {
            console.log("do confirm data: " + JSON.stringify(data));
            // 이 함수를 반드시 실행해야 결제가 완전히 끝납니다.
            // 부트페이로 서버로 결제를 승인함을 보내는 함수입니다.
            this.transactionConfirm(data);
        } else {
            var msg = "결제가 승인거절되었습니다.: " + JSON.stringify(data);
            alert(msg);
            console.log(data);
        }
    }).done(function (data) {
        // 결제가 모두 완료되었을 때 호출되는 함수입니다.
        alert("결제가 완료되었습니다.");
        console.log(data);
    }).ready(function (data) {
        // 가상계좌 번호가 체번(발급) 되었을 때 호출되는 함수입니다.
        console.log(data);
    });
```

## 각 결제 수단별 결제 진행 순서
### 카드(card), 휴대폰 소액결제 (phone), 계좌이체 (bank), 간편결제 (카카오 혹은 페이코)
대부분의 결제는 진행 순서가 동일합니다.
```
<결제 요청> -> <결제창이 띄워짐> -> <confirm  함수 실행 혹은 바로 결제 승인> -> < 부트페이 서버에서 결제 승인 >
```
### 가상계좌(vbank)
가상계좌는 계좌번호 발급 이후 입금 되어야 결제가 완전히 끝나는 특수한 결제 방법입니다.
```
<결제 요청> -> <결제창이 띄워짐> -> < ready 함수 호출 및 가상계좌 발급 > -> < 입금 후 부트페이 서버로 결제 정보가 옴 > -> < 부트페이 관리자에서 설정한 FeedbackURL로 가맹점 서버로 결제 데이터 전송 >
```

## 부트페이 통계 이용하기
부트페이로 데이터를 보내주시면 1시간 단위, 1일 단위, 1주일 단위, 1달 단위의 데이터를 분석하여 접속 통계 및 결제 통계를 보실 수 있습니다.
자세한 통계 내용은 https://admin.bootpay.co.kr 로 가셔서 테스트 계정으로 로그인 후 확인하실 수 있습니다.

### 특정 페이지 접근시 통계 데이터 전달
통계를 집계하길 원하는 페이지에 접근했을 때 부트페이로 데이터를 보내 통계를 낼 수 있습니다.
특정 아이템을 판매하는 페이지에 대한 분석 및 어떤 Referer를 통해 페이지를 진입했는지 여부를 통계 데이터로 뽑아내 줍니다.
```javascript
// DocumentContentLoaded 이벤트 호출 후에  페이지 정보를 전송하는 것을 추천합니다.
document.addEventListener('DOMContentLoaded', function () {
    // 부트페이로 페이지 정보를 전송하는 함수입니다.
    // 이 함수를 호출하지 않으면 페이지에 대한 정보를 수집하지 않습니다.
    BootPay.startTrace({
        // 현재 페이지에서 판매하는 아이템 정보 ( 상품이 여러개일 수 있으므로 Array로 보내주세요. )
        items: [
            {
                item_name: '( 아이템 명 )',
                item_img: '( 이미지 URL 경로 )',
                unique: '( 아이템 고유 키 )',
                cat1: '( 카테고리 상위 1 )',
                cat2: '( 카테고리 중위 2 )',
                cat3: '( 카테고리 하위 3 )'
            },
            {
                item_name: '( 아이템 명 )',
                item_img: '( 이미지 URL 경로 )',
                unique: '( 아이템 고유 키 )',
                cat1: '( 카테고리 상위 1 )',
                cat2: '( 카테고리 중위 2 )',
                cat3: '( 카테고리 하위 3 )'
            }
        ]
    });
});
```

### 로그인한 회원 정보 전달
어떤 사용자가 로그인을 했는지 로그인 한 후 어떤 아이템을 구매했는지 추적할 수 있습니다.
그러기 위해서는 로그인 한 정보를 부트페이로 전송하여 데이터 분석을 할 수 있습니다. ( 정보는 통계용으로만 쓰이고 60일 후 모두 폐기 됩니다. )
```javascript
// 로그인 한 이후 호출되는 함수
// 로그인 정보를 부트페이로 전송
function LoginAfterCallFunction() {
    // 로그인 정보를 보내고 부트페이에서 로그인 세션을 받아 데이터를 추적한다.
    BootPay.startLoginSession({
        id: '(회원 아이디)',
        username: '(회원 이름)',
        birth: '(회원 생년월일)',
        phone: '(회원 전화번호)',
        email: '(회원 이메일)',
        gender: '(회원 성별 1 - 남자, 0 - 여자)',
        area: '(회원 거주 지역)'
    });
}
```
