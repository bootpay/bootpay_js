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