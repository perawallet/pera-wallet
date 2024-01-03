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
import com.algorand.android.utils.BaseUrlBuilder

class BidaliUrlBuilder private constructor(
    isMainnet: Boolean
) : BaseUrlBuilder(if (isMainnet) { PROD_BIDALI_API_URL } else { STAGING_BIDALI_API_URL }) {

    enum class BidaliQuery(override val key: String) : UrlQueryParam {
        KEY("key"),
        DAPP("dapp"),
    }

    fun addDappSlug(): BidaliUrlBuilder {
        addUrlSlug(BidaliQuery.DAPP.key)
        return this
    }

    fun addKeyQuery(isMainnet: Boolean): BidaliUrlBuilder {
        if (isMainnet) {
            addQuery(BidaliQuery.KEY, BuildConfig.PROD_BIDALI_API_KEY)
        } else {
            addQuery(BidaliQuery.KEY, BuildConfig.STAGING_BIDALI_API_KEY)
        }
        return this
    }

    companion object {
        private const val PROD_BIDALI_API_URL = "https://commerce.bidali.com/"
        private const val STAGING_BIDALI_API_URL = "https://commerce.staging.bidali.com/"
        fun create(isMainnet: Boolean): BidaliUrlBuilder {
            return BidaliUrlBuilder(isMainnet)
        }
    }
}
