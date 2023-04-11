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

package com.algorand.android.modules.dapp.transak

import com.algorand.android.BuildConfig
import com.algorand.android.modules.dapp.transak.domain.model.MainnetTransakSupportedCurrency
import com.algorand.android.modules.dapp.transak.domain.model.TestnetTransakSupportedCurrency
import com.algorand.android.utils.BaseUrlBuilder

class TransakUrlBuilder private constructor(
    isMainnet: Boolean
) : BaseUrlBuilder(if (isMainnet) { PROD_TRANSAK_URL } else { STAGING_TRANSAK_URL }) {

    enum class TransakQuery(override val key: String) : UrlQueryParam {
        API_KEY("apiKey"),
        DEFAULT_CRYPTOCURRENCY("defaultCryptoCurrency"),
        NETWORK("network"),
        CRYPTOCURRENCY_LIST("cryptoCurrencyList"),
        WALLET_ADDRESS("walletAddress"),
    }

    fun addApiKeyQuery(isMainnet: Boolean): TransakUrlBuilder {
        if (isMainnet) {
            addQuery(TransakQuery.API_KEY, BuildConfig.PROD_TRANSAK_API_KEY)
        } else {
            addQuery(TransakQuery.API_KEY, BuildConfig.STAGING_TRANSAK_API_KEY)
        }
        return this
    }

    fun addDefaultCryptoCurrencyQuery(isMainnet: Boolean): TransakUrlBuilder {
        if (isMainnet) {
            addQuery(TransakQuery.DEFAULT_CRYPTOCURRENCY, MainnetTransakSupportedCurrency.USDC.key)
        } else {
            addQuery(TransakQuery.DEFAULT_CRYPTOCURRENCY, TestnetTransakSupportedCurrency.USDC.key)
        }
        return this
    }

    fun addNetworkQuery(): TransakUrlBuilder {
        addQuery(TransakQuery.NETWORK, DEFAULT_NETWORK)
        return this
    }

    fun addCryptoCurrencyListQuery(isMainnet: Boolean): TransakUrlBuilder {
        if (isMainnet) {
            addQuery(
                TransakQuery.CRYPTOCURRENCY_LIST,
                MainnetTransakSupportedCurrency.values().joinToString(separator = COMMA)
            )
        } else {
            addQuery(
                TransakQuery.CRYPTOCURRENCY_LIST,
                TestnetTransakSupportedCurrency.values().joinToString(separator = COMMA)
            )
        }
        return this
    }

    fun addWalletAddressQuery(accountAddress: String?): TransakUrlBuilder {
        accountAddress?.let {
            addQuery(TransakQuery.WALLET_ADDRESS, it)
        }
        return this
    }

    companion object {
        private const val PROD_TRANSAK_URL = "https://global.transak.com/?"
        private const val STAGING_TRANSAK_URL = "https://global-stg.transak.com/?"
        private const val DEFAULT_NETWORK = "algorand"
        private const val COMMA = ","
        fun create(isMainnet: Boolean): TransakUrlBuilder {
            return TransakUrlBuilder(isMainnet)
        }
    }
}
