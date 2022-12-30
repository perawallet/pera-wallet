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

package com.algorand.android.modules.tracking.discover.detail

import com.algorand.android.modules.tracking.core.BaseEventTracker
import com.algorand.android.modules.tracking.core.PeraEventTracker
import com.algorand.android.modules.tracking.discover.DiscoverEventTrackerConstants.ASSET_IN_PAYLOAD_KEY
import com.algorand.android.modules.tracking.discover.DiscoverEventTrackerConstants.ASSET_OUT_PAYLOAD_KEY
import javax.inject.Inject

// TODO use this class when the swap integration is completed to track buy/sell events
class DiscoverDetailEventTracker @Inject constructor(
    peraEventTracker: PeraEventTracker
) : BaseEventTracker(peraEventTracker) {

    suspend fun logTokenDetailBuyEvent(
        assetIn: Long,
        assetOut: Long
    ) {
        val eventPayload = getEventPayload(
            assetIn = assetIn,
            assetOut = assetOut
        )
        logEvent(TOKEN_BUY_EVENT_KEY, eventPayload)
    }

    suspend fun logTokenDetailSellEvent(
        assetIn: Long,
        assetOut: Long
    ) {
        val eventPayload = getEventPayload(
            assetIn = assetIn,
            assetOut = assetOut
        )
        logEvent(TOKEN_SELL_EVENT_KEY, eventPayload)
    }

    private fun getEventPayload(
        assetIn: Long,
        assetOut: Long
    ): Map<String, Any> {
        return mapOf(
            ASSET_IN_PAYLOAD_KEY to assetIn,
            ASSET_OUT_PAYLOAD_KEY to assetOut
        )
    }

    companion object {
        private const val TOKEN_BUY_EVENT_KEY = "discover_token_detail_buy"
        private const val TOKEN_SELL_EVENT_KEY = "discover_token_detail_sell"
    }
}
