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

package com.algorand.android.modules.pendingintentkeeper.ui

import android.content.Intent
import androidx.lifecycle.DefaultLifecycleObserver
import com.algorand.android.MainActivity.Companion.WC_ARBITRARY_DATA_ID_INTENT_KEY
import com.algorand.android.MainActivity.Companion.WC_TRANSACTION_ID_INTENT_KEY
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PendingIntentKeeper @Inject constructor() : DefaultLifecycleObserver {

    var pendingIntent: Intent? = null
        private set

    fun setPendingIntent(intent: Intent?) {
        val shouldOverrideExistingIntent = shouldOverrideExistingIntent(intent)
        if (shouldOverrideExistingIntent) {
            pendingIntent = intent
        }
    }

    fun clearPendingIntent() {
        pendingIntent = null
    }

    private fun shouldOverrideExistingIntent(intent: Intent?): Boolean {
        val isNewIntentNull = intent == null
        if (isNewIntentNull) return false

        val isExistingIntentNull = pendingIntent == null
        if (isExistingIntentNull) return true

        return hasTransactionIntent(intent) || hasArbitraryDataIntent(intent)
    }

    private fun hasTransactionIntent(intent: Intent?): Boolean {
        val isIntentIntentContainsWCTransactionId = isGivenIntentContainsWCTransactionId(intent)
        if (isIntentIntentContainsWCTransactionId) return true

        val isPendingIntentContainsWCTransactionId = isGivenIntentContainsWCTransactionId(pendingIntent)
        return !isPendingIntentContainsWCTransactionId
    }

    private fun hasArbitraryDataIntent(intent: Intent?): Boolean {
        val isIntentIntentContainsWCArbitraryDataId = isGivenIntentContainsWCArbitraryDataId(intent)
        if (isIntentIntentContainsWCArbitraryDataId) return true

        val isPendingIntentContainsWCArbitraryDataId = isGivenIntentContainsWCArbitraryDataId(pendingIntent)
        return !isPendingIntentContainsWCArbitraryDataId
    }

    private fun isGivenIntentContainsWCTransactionId(intent: Intent?): Boolean {
        return intent?.getLongExtra(WC_TRANSACTION_ID_INTENT_KEY, -1L) != -1L
    }

    private fun isGivenIntentContainsWCArbitraryDataId(intent: Intent?): Boolean {
        return intent?.getLongExtra(WC_ARBITRARY_DATA_ID_INTENT_KEY, -1L) != -1L
    }
}
