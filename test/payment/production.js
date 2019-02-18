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
	document.getElementsByName('pg')[0].value = 'inicis';
	document.getElementsByName('method')[0].value = 'card';
});

function doPayment() {
	BootPay.request({
		price: document.getElementsByName('price')[0].value,
		application_id: '59a7a368396fa64fc5d4a7db',
		name: '테스트 아이템',
		phone: '01000000000',
		return_url: 'https://dev-app.bootpay.co.kr/test?env=production',
		order_id: (new Date()).getTime(),
		pg: document.getElementsByName('pg')[0].value,
		method: document.getElementsByName('method')[0].value,
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
			username: '홍길동',
			email: 'test.bootpay.co.kr@gmail.com'
		},
		extra: {
			expire_month: '36',
			vbank_result: 1,
			quota: '0,2,3'
		}
	}).ready(function (data) {
		alert('가상계좌 발급완료!');
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
			var msg = "결제가 승인거절되었습니다.: " + JSON.stringify(data)
			alert(msg);
			console.log(data);
		}
	}).done(function (data) {
		alert("결제가 완료되었습니다.");
		console.log(data);
	});
}

function doAllPayment() {
	BootPay.request({
		price: document.getElementsByName('price')[0].value,
		application_id: '59a7a368396fa64fc5d4a7db',
		name: '테스트 아이템',
		phone: '01000000000',
		order_id: (new Date()).getTime(),
		show_agree_window: 1,
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
		}
	}).ready(function (data) {
		alert('가상계좌 발급완료!');
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