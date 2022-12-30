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

package com.algorand.android.modules.tracking.discover.dapp

import com.algorand.android.modules.tracking.core.BaseEventTracker
import com.algorand.android.modules.tracking.core.PeraEventTracker
import com.algorand.android.modules.tracking.discover.DiscoverEventTrackerConstants.DAPP_NAME_PAYLOAD_KEY
import com.algorand.android.modules.tracking.discover.DiscoverEventTrackerConstants.DAPP_URL_PAYLOAD_KEY
import javax.inject.Inject

class DiscoverDappEventTracker @Inject constructor(
    peraEventTracker: PeraEventTracker
) : BaseEventTracker(peraEventTracker) {

    suspend fun logDappVisitEvent(
        dappTitle: String,
        dappUrl: String
    ) {
        val eventPayload = getEventPayload(
            dappTitle = dappTitle,
            dappUrl = dappUrl
        )
        logEvent(DAPP_VISIT_EVENT_KEY, eventPayload)
    }

    private fun getEventPayload(
        dappTitle: String,
        dappUrl: String
    ): Map<String, Any> {
        return mapOf(
            DAPP_NAME_PAYLOAD_KEY to dappTitle,
            DAPP_URL_PAYLOAD_KEY to dappUrl
        )
    }

    companion object {
        private const val DAPP_VISIT_EVENT_KEY = "discover_dapps_visit_pages"
    }
}
