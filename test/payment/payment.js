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

function doPayment() {
    BootPay.request({
        price: '3000',
        application_id: '',
        name: '테스트 아이템',
        phone: '01000000000',
        order_id: (new Date()).getTime(),
        pg: 'danal',
        show_agree_window: 0,
        items: [
            {
                item_name: '테스트 아이템',
                qty: 1,
                unique: '123',
                price: 3000
            }
        ],
        user_info: {
            email: 'test.bootpay.co.kr@gmail.com'
        },
        method: 'card'
    }).error(function (data) {
        var msg = "결제 에러입니다.: " + JSON.stringify(data)
        alert(msg);
        console.log(data);
    }).cancel(function (data) {
        var msg = "결제 취소입니다.: " + JSON.stringify(data)
        alert(msg);
        console.log(data);
    }).confirm(function (data) {
        if (confirm('결제를 정말 승인할까요?')) {
            this.transactionConfirm();
        } else {
            var msg = "결제가 승인거절되었습니다.: " + JSON.stringify(data)
            alert(msg);
            console.log(data);
        }
    }).done(function (data) {
        alert("결제가 완료되었습니다.");
        console.log(data);
    });
};