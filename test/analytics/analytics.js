document.addEventListener('DOMContentLoaded', function () {
    BootPay.setLogLevel(4);
    BootPay.startTrace({
        items: [
            {
                item_name: '아이템1',
                item_img: 'https://www.bootpay.co.kr/sdklflksjdflkj',
                unique: '1',
                cat1: '카1',
                cat2: '카2',
                cat3: '카3'
            },
            {
                item_name: '아이템2',
                item_img: 'https://www.bootpay.co.kr/sdklflksjdflkj',
                unique: '2',
                cat1: '카1',
                cat2: '카2',
                cat3: '카3'
            }
        ]
    });
});

function doLogin() {
    BootPay.startLoginSession({
        id: document.getElementsByName('id')[0].value,
        username: document.getElementsByName('name')[0].value,
        birth: document.getElementsByName('birth')[0].value,
        phone: document.getElementsByName('phone')[0].value,
        email: document.getElementsByName('email')[0].value,
        gender: document.getElementsByName('gender')[0].value,
        area: document.getElementsByName('area')[0].value
    });
}

function doNotify() {
    BootPay.notify({
        price: '1000',
        name: '파는 아이템',
        items: [
            {
                item_name: '나는 아이템',
                qty: 1,
                unique: '123',
                price: 1000
            }
        ],
        user_info: {
            username: document.getElementsByName('name')[0].value,
            email: document.getElementsByName('email')[0].value,
            addr: document.getElementsByName('area')[0].value,
            phone: document.getElementsByName('phone')[0].value
        },
        method: 'toss',
        order_id: (new Date()).getTime()
    }, function (data) {
        var receiptId = data.receipt_id;
        document.getElementsByName('receipt_id')[0].value = receiptId;
        // 결제 시작 진행
    }, function (data) {
        console.log(data);
        // 서버에서 응답하지 않았으므로 바로 결제 진행
    }, 3000);
}