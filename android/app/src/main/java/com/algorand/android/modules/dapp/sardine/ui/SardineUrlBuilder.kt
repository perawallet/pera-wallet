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

package com.algorand.android.modules.dapp.sardine.ui

import com.algorand.android.BuildConfig
import com.algorand.android.utils.BaseUrlBuilder

class SardineUrlBuilder private constructor(
    isMainnet: Boolean
) : BaseUrlBuilder(if (isMainnet) { PROD_SARDINE_URL } else { STAGING_SARDINE_URL }) {

    enum class SardineQuery(override val key: String) : UrlQueryParam {
        CLIENT_ID("client_id"),
        FIAT_AMOUNT("fiat_amount"),
        FIAT_CURRENCY("fiat_currency"),
        FIXED_ASSET_TYPE("fixed_asset_type"),
        FIXED_NETWORK("fixed_network"),
        ADDRESS("address"),
    }

    fun addClientIdQuery(isMainnet: Boolean): SardineUrlBuilder {
        if (isMainnet) {
            addQuery(SardineQuery.CLIENT_ID, BuildConfig.SARDINE_API_KEY)
        }
        return this
    }

    fun addFiatAmountQuery(): SardineUrlBuilder {
        addQuery(SardineQuery.FIAT_AMOUNT, DEFAULT_AMOUNT)
        return this
    }

    fun addFiatCurrencyQuery(): SardineUrlBuilder {
        addQuery(SardineQuery.FIAT_CURRENCY, DEFAULT_FIAT)
        return this
    }

    fun addFixedAssetTypeQuery(): SardineUrlBuilder {
        addQuery(SardineQuery.FIXED_ASSET_TYPE, DEFAULT_ASSET_TYPE)
        return this
    }

    fun addFixedNetworkQuery(): SardineUrlBuilder {
        addQuery(SardineQuery.FIXED_NETWORK, DEFAULT_NETWORK)
        return this
    }

    fun addAddressQuery(accountAddress: String?): SardineUrlBuilder {
        accountAddress?.let {
            addQuery(SardineQuery.ADDRESS, it)
        }
        return this
    }

    companion object {
        private const val PROD_SARDINE_URL = "https://crypto.sardine.ai/"
        private const val STAGING_SARDINE_URL = "https://crypto.sandbox.sardine.ai/"
        private const val DEFAULT_NETWORK = "algorand"
        private const val DEFAULT_FIAT = "USD"
        private const val DEFAULT_AMOUNT = "1000"
        private const val DEFAULT_ASSET_TYPE = "ALGO"
        fun create(isMainnet: Boolean): SardineUrlBuilder {
            return SardineUrlBuilder(isMainnet)
        }
    }
}
