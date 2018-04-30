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