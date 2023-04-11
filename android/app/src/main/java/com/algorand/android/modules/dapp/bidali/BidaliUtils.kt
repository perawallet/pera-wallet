/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.modules.dapp.bidali

import com.algorand.android.BuildConfig
import com.algorand.android.modules.dapp.bidali.domain.model.BidaliAsset

private const val BIDALI_BALANCES_JAVASCRIPT = "window.bidaliProvider.balances = {%s}"
private const val COMMA_SEPARATOR = ", "

const val BIDALI_SUCCESSFUL_TRANSACTION_JAVASCRIPT = "window.bidaliProvider.paymentSent();"
const val BIDALI_FAILED_TRANSACTION_JAVASCRIPT = "window.bidaliProvider.paymentCancelled();"

private fun getBidaliJavaScript(isMainnet: Boolean): String {
    val apiKey = getBidaliAPIKey(isMainnet)
    return "window.bidaliProvider = {\n" +
        "          name: 'Pera Wallet',\n" +
        "          key: '$apiKey',\n" +
        "          paymentCurrencies: [%s],\n" +
        "          balances: {%s},\n" +
        "          onPaymentRequest: (paymentRequest) => {\n" +
        "            var payload = { method: 'onPaymentRequest', data: paymentRequest };\n" +
        "            bidaliWebInterface.onPaymentRequest(JSON.stringify(paymentRequest));\n" +
        "          },\n" +
        "          openUrl: function (url) {\n" +
        "            var payload = { method: 'openUrl', data: { url } };\n" +
        "            bidaliWebInterface.openUrl(JSON.stringify({ url }));\n" +
        "          }\n" +
        "        };\n" +
        "        true;"
}

fun getCompiledBidaliJavascript(currencies: List<BidaliAsset>, isMainnet: Boolean): String {
    val currencyList = currencies.joinToString(separator = COMMA_SEPARATOR) { "'${it.currency.key}'" }
    val currencyBalancesList = currencies.joinToString(separator = COMMA_SEPARATOR) {
        "'${it.currency.key}': '${it.amount}'"
    }
    return String.format(getBidaliJavaScript(isMainnet), currencyList, currencyBalancesList)
}

fun getCompiledUpdatedBalancesJavascript(currencies: List<BidaliAsset>): String {
    val currencyBalancesList =
        currencies.joinToString(separator = COMMA_SEPARATOR) { "'${it.currency.key}': '${it.amount}'" }
    return String.format(BIDALI_BALANCES_JAVASCRIPT, currencyBalancesList)
}

fun getBidaliUrl(isMainnet: Boolean): String {
    return BidaliUrlBuilder.create(isMainnet)
        .addDappSlug()
        .addKeyQuery(isMainnet)
        .build()
}

private fun getBidaliAPIKey(isMainnet: Boolean): String {
    return if (isMainnet) {
        BuildConfig.PROD_BIDALI_API_KEY
    } else {
        BuildConfig.STAGING_BIDALI_API_KEY
    }
}
