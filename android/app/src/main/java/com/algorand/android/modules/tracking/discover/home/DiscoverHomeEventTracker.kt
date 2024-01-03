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

package com.algorand.android.modules.tracking.discover.home

import com.algorand.android.modules.tracking.core.BaseEventTracker
import com.algorand.android.modules.tracking.core.PeraEventTracker
import com.algorand.android.modules.tracking.discover.DiscoverEventTrackerConstants.ASSET_ID_PAYLOAD_KEY
import com.algorand.android.modules.tracking.discover.DiscoverEventTrackerConstants.QUERY_PAYLOAD_KEY
import javax.inject.Inject

class DiscoverHomeEventTracker @Inject constructor(
    peraEventTracker: PeraEventTracker
) : BaseEventTracker(peraEventTracker) {

    suspend fun logQueryEvent(
        query: String,
        assetId: Long
    ) {
        val eventPayload = getEventPayload(
            query = query,
            assetId = assetId
        )
        logEvent(ASSETS_SEARCH_EVENT_KEY, eventPayload)
    }

    private fun getEventPayload(
        query: String,
        assetId: Long
    ): Map<String, Any> {
        return mapOf(
            QUERY_PAYLOAD_KEY to query,
            ASSET_ID_PAYLOAD_KEY to assetId
        )
    }

    companion object {
        private const val ASSETS_SEARCH_EVENT_KEY = "discover_markets_search"
    }
}
