# Bootpay JS

## Change Log

### 3.0.4 ( Stable )
#### 기능 변경
- Angular Universal 컴파일시 localStorage 에러 수정
- 안드로이드 (9.0 파이) 팝업 정책 변경으로 우회코드 추가

### 3.0.3
#### 기능 변경
- 부트페이 관련 이벤트를 호출시 Binding하도록 변경 

### 3.0.2 
#### 새로운기능
- 네이버페이 주문형 결제 정보 추가 params
- third party API 옵션 기능 추가

### 3.0.1
#### 복합기능
- use_order_id: 1 과 같은 1, 0의 값을 직관적으로 true, false도 함께 허용
#### 새로운 기능
- 네이버페이 주문형 요청 추가
- 페이앱 결제 완료 후 창 닫기 옵션 추가
- 결제 완료 후 완료 버튼 노출 추가

### 3.0.0 
#### 새로운 기능
- 앞으로 새로 제공될 결제 방식(기존 PG 결제 이외의)에 대한 업데이트 이루어졌습니다.
- REST API로 결제 승인이 가능합니다. 좀 더 정밀한 결제 검증이 가능해졌습니다. ( Docs에서 사용법을 업데이트 중 )
- 일부 PG에서 iFrame이 안되는 문제가 있어서 Mobile Safari를 대응하기 위해 POPUP 결제창 로직이 추가 되었습니다. 일부 PG사의 결제 수단은 POPUP으로 동일한 로직으로 결제가 진행됩니다.
#### 버그 수정내역
- 팝업 결제 일 경우 iOS Safari는 사용자의 개입이 필요한 Direct Interactive 버튼 추가 ( 버튼이 없으면 팝업 차단 되어 있는 경우 팝업이 뜨지 않음 )
- 결제창 CSS 수정 ( 버튼 색상을 부트페이 메인 컬러로 통일 )
- iOS 인앱에서 iFrame으로 결제창을 띄울 경우 탭 위치가 올바르지 않는 문제 수정 ( Bug Fixed )
- Progress Position 모바일 일 경우 약간 위로 수정
- Popup 결제 시작 Trigger 요청시 POST -> GET 방식으로 변경 ( 아이폰 인앱 대응 )
- 타 Framework에서 postMessage 사용시 json parsing 에러 안나도록 Filter 추가
- iFrame iOS에서 Scroll 버그 수정 ( 일부 PG에서 스크롤이 자연스럽게 내려가지 않는 문제 해결 )

### 2.1.1
- 가맹점에서 order_id를 PK로 PG사로 전송기능 ( KCP만 가능 - 차후 다른 가맹점도 업데이트 예정 - use_order_id: 1로 설정하면 사용 가능 )

### 2.1.0
- IE에서 transactionConfirm 함수가 두번 호출되는 문제가 있습니다. ConfirmLock을 통해 한번만 호출되도록 수정하였습니다. ( Bug Fixed )
- escrow 결제 여부를 선택하는 부분이 extra에서 보낼 수 있도록 업데이트 되었습니다. ( 기능추가 )
- 일부 모바일 카드 결제에서 iFrame에서 앱카드 및 ISP가 호출안되는 문제가 있어서 Form 방식 결제를 할 수 있도록 변경이 되었습니다. 요청시 결제 리턴 결과를 받을 return_url params를 보내서 승인 전 데이터를 받을 URL을 설정할 수 있습니다. ( 기능추가 )
- 통계 데이터를 결제 특정 이벤트에 보내지 않는 버그를 수정하였습니다. ( Bug Fixed )

### 2.0.20
- 결제를 팝업으로 띄워서 요청할 때 팝업과 팝업 Opener의 도메인이 서로 다른 경우 결제 UUID와 접속 UUID를 동기화하는 함수 추가 ( IE에서는 Cross Site postMessage 정책 때문에 해당 기능이 작동하지 않습니다. )

## 부트페이 결제 요청 JS SDK
코드 한줄로 구현하는 Bootpay JS 모듈입니다. 개발 언어는 coffeescript로 되어 있으며, jQuery 의존성이 있는 1.x.x버전은 Private Git 저장소로 관리중이며, jQuery의존성이 없는 2.x.x는 GitHub에 오픈소스로 개발되었습니다.
2.x.x는 Webpack으로 컴파일 되며, webpack-dev-server를 통해 테스트 서버로 결제를 테스트 할 수도 있습니다.

## NPM URL
NPM으로 다운 받을 수 있는 경로는 다음과 같습니다.
https://www.npmjs.com/package/bootpay-js

## 연동 방법
### 1. CDN으로 Javascript 호출하기
```html
<script src="https://cdn.bootpay.co.kr/js/bootpay-3.0.4.min.js" type="application/javascript"></script>
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
    "bootpay-js": "^3.0.4"
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
    require(["https://cdn.bootpay.co.kr/js/bootpay-3.0.4.min.js"], function(BootPay) {
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
            username: '구매자성함',
            addr: '(고객의 거주지역)'
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
