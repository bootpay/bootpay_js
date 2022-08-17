import BootPay from 'bootpay-js'

import Router from 'next/router'

import * as ROUTES from '~/constants/routes'

import paymentVerify from './paymentVerify'

import type {

    BootPayCancelResponse,

    BootPayConfirmResponse,

    BootPayDefaultResponse,

    BootPayDoneResponse,

    BootPayErrorResponse,

    BootPayReadyResponse,

} from './types'

import { PaymentFormValues } from '../../../types'

import paymentCancel from './paymentCancel'

import getPaymentForm from './getPaymentInfo'

async function paymentOnRequest(formValues: PaymentFormValues): Promise<void> {

    const paymentDetailsInfo = getPaymentForm(formValues)

    console.log('bootPay Start')

    console.log('BootPay : ', BootPay)

    console.log('paymentDetailsInfo : ', paymentDetailsInfo)

    BootPay.request(paymentDetailsInfo)

        .error(async function (data: BootPayErrorResponse) {

            //결제 진행시 에러가 발생하면 수행됩니다.

            console.log('error', data)

            await handleBootPayOnError(data)

        })

        .cancel(async function (data: BootPayCancelResponse) {

            //결제가 취소되면 수행됩니다.

            await handleBootPayOnCancel(data)

        })

        .ready(function (data: BootPayReadyResponse) {

            // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.

            console.log('ready', data)

        })

        .confirm(async function (data: BootPayConfirmResponse) {

            //결제가 실행되기 전에 수행되며, 주로 재고를 확인하는 로직이 들어갑니다.

            //주의 - 카드 수기결제일 경우 이 부분이 실행되지 않습니다.

            await handleBootPayOnConfirm(data)

        })

        .close(function (data: BootPayDefaultResponse) {

            // 결제창이 닫힐때 수행됩니다. (성공,실패,취소에 상관없이 모두 수행됨)

            console.log('close', data)

        })

        .done(async function (data: BootPayDoneResponse) {

            //결제가 정상적으로 완료되면 수행됩니다

            //비즈니스 로직을 수행하기 전에 결제 유효성 검증을 하시길 추천합니다.

            console.log('결제 성공')

            await handleBootPayOnDone(data, formValues)

        })

}

async function handleBootPayOnError(data: BootPayErrorResponse) {

    // code -13001

    if (data.code === -13001) {

        alert(data.message + '\n' + '은행 마감시간 확인 후 다시 시도해 주세요')

        Router.reload()

    }

    //console.log('error', data);

}

async function handleBootPayOnCancel(data: BootPayCancelResponse) {

    await paymentCancel(data.receipt_id)

    alert('결제가 취소되었습니다.')

    //console.log('cancel', data);

}

async function handleBootPayOnConfirm(data: BootPayConfirmResponse) {

    //console.log('confirm', data);

    const enable = true // 재고 수량 관리 로직 혹은 다른 처리

    if (enable) {

        BootPay.transactionConfirm(data) // 조건이 맞으면 승인 처리를 한다.

    } else {

        BootPay.removePaymentWindow() // 조건이 맞지 않으면 결제 창을 닫고 결제를 승인하지 않는다.

    }

}

async function handleBootPayOnDone(
    data: BootPayDoneResponse,
    formValues: PaymentFormValues,
): Promise<void> {

    // verify payment as bootpay recommended

    const {

        isValid,

        errorMessage,

        redirectUrlParam,

        receiptUrl,

    } = await paymentVerify(data, formValues)

    if (!isValid) {

        // cancel payment if its not valid

        await paymentCancel(data.receipt_id)

        alert('결제가 취소되었습니다.' + '\n' + errorMessage)

        Router.reload()

        return

    }

    alert('결제가 완료되었습니다.')

    Router.replace(
        `${ ROUTES.ARTWORK_PAYMENT_SUCCESS }/?id=${ redirectUrlParam }&receipt_url=${ receiptUrl }`,
    )

}

export default paymentOnRequest