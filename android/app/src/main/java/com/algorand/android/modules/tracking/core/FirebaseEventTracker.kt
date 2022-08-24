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

package com.algorand.android.modules.tracking.core

import android.os.Bundle
import com.google.firebase.analytics.FirebaseAnalytics

internal class FirebaseEventTracker(
    private val firebaseAnalytics: FirebaseAnalytics
) : PeraEventTracker {

    override suspend fun logEvent(eventName: String) {
        firebaseAnalytics.logEvent(eventName, null)
    }

    override suspend fun logEvent(eventName: String, payloadMap: Map<String, Any>) {
        val payloadBundle = getPayloadBundle(payloadMap)
        firebaseAnalytics.logEvent(eventName, payloadBundle)
    }

    private fun getPayloadBundle(payloadMap: Map<String, Any>): Bundle {
        return Bundle().apply {
            payloadMap.forEach { payload ->
                putString(payload.key, payload.value.toString())
            }
        }
    }
}
