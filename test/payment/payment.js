document.addEventListener('DOMContentLoaded', function () {
	BootPay.setLogLevel(4);
	BootPay.setMode('development');
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
				cat3: '카3',
			}
		]
	});
	document.getElementsByName('pg')[0].value = 'nicepay';
	document.getElementsByName('method')[0].value = 'card';
});

function doPayment() {
	BootPay.request({
		price: document.getElementsByName('price')[0].value,
		tax_free: document.getElementsByName('tax_free')[0].value,
		application_id: '59a568d3e13f3336c21bf707',
		name: '테스트s 아이템',
		phone: '01000000000',
		order_id: (new Date()).getTime(),
		pg: document.getElementsByName('pg')[0].value,
		method: document.getElementsByName('method')[0].value,
		show_agree_window: 0,
		use_order_id: 1,
		return_url: 'https://dev-app.bootpay.co.kr/test',
		boot_key: 'aqure84',
		items: [
			{
				item_name: '테스트 아이템',
				qty: 1,
				unique: '123',
				price: 1000
			}
		],
		user_info: {
			username: '홍길동',
			email: 'test.bootpay.co.kr@gmail.com',
			addr: '인천광역시 남동구'
		},
		extra: {
			expire_month: '36',
			vbank_result: 1,
			quota: '0,2,3,4,5,6,7,8,9,10,11',
			phone_carrier: 'SKT',
			escrow: 0
		}
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
			console.log("do confirm data: " + JSON.stringify(data));
			this.transactionConfirm(data);
			this.transactionConfirm(data);
		} else {
			var msg = "결제가 승인거절되었습니다.: " + JSON.stringify(data)
			alert(msg);
			console.log(data);
		}
	}).done(function (data) {
		alert("결제가 완료되었습니다.");
		console.log(data);
	}).ready(function (data) {
		console.log(data);
	}).close(function () {
		alert('닫힘!!');
	});
}

function doAllPayment() {
	BootPay.request({
		price: document.getElementsByName('price')[0].value,
		tax_free: document.getElementsByName('tax_free')[0].value,
		application_id: '59a568d3e13f3336c21bf707',
		// methods: ['card', 'bank'],
		name: "테스트's 아이템",
		phone: '01000000000',
		order_id: (new Date()).getTime(),
		show_agree_window: 1,
		items: [
			{
				item_name: '테스트 아이템',
				qty: 1,
				unique: '123',
				price: 1000
			}
		],
		user_info: {
			email: 'test.bootpay.co.kr@gmail.com'
		},
		extra: {
			expire_month: '36'
		}
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
			console.log("do confirm data: " + JSON.stringify(data));
			this.transactionConfirm(data);
		} else {
			var msg = "결제가 승인거절되었습니다.: " + JSON.stringify(data);
			alert(msg);
			console.log(data);
		}
	}).done(function (data) {
		alert("결제가 완료되었습니다.");
		console.log(data);
	}).ready(function (data) {
		console.log(data);
	});
}

function changeMethod(e) {
	switch (e.value) {
		case 'card_rebill':
			document.getElementsByName('price')[0].value = 0;
			break;
		default:
			document.getElementsByName('price')[0].value = 3000;
	}
}