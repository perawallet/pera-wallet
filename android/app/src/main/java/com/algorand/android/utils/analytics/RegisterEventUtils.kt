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

package com.algorand.android.utils.analytics

import androidx.core.os.bundleOf
import com.google.firebase.analytics.FirebaseAnalytics

private const val REGISTER_EVENT_KEY = "register" // event type
private const val REGISTER_ACCOUNT_TYPE_KEY = "type" // param

// TODO use Account.Type if possible instead of CreationType
enum class CreationType(val analyticsValue: String) {
    LEDGER("ledger"),
    RECOVER("recover"),
    CREATE("create"),
    REKEYED("rekeyed"),
    WATCH("watch")
}

fun FirebaseAnalytics.logRegisterEvent(creationType: CreationType?) {
    if (creationType == null) {
        return
    }
    val bundle = bundleOf(REGISTER_ACCOUNT_TYPE_KEY to creationType.analyticsValue)
    logEvent(REGISTER_EVENT_KEY, bundle)
}
