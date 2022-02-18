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

package com.algorand.android.utils.inappreview

import android.app.Activity
import android.content.SharedPreferences
import com.algorand.android.utils.preference.getAppReviewStartCount
import com.algorand.android.utils.preference.setAppReviewStartCount
import com.google.android.play.core.review.ReviewManagerFactory
import javax.inject.Inject

class InAppReviewManager @Inject constructor(private val sharedPref: SharedPreferences) {

    private var isStarted: Boolean = false
    private var currentStartCount = 0

    init {
        initializeStartCount()
    }

    private fun initializeStartCount() {
        currentStartCount = sharedPref.getAppReviewStartCount()
        if (currentStartCount < APP_REVIEW_TRIGGER_COUNT) {
            currentStartCount++
            sharedPref.setAppReviewStartCount(currentStartCount)
        }
    }

    private fun isTriggerNeeded(): Boolean {
        return currentStartCount >= APP_REVIEW_TRIGGER_COUNT
    }

    fun start(activity: Activity): Boolean {
        if (isStarted) {
            return false
        }
        isStarted = true

        if (isTriggerNeeded()) {
            ReviewManagerFactory.create(activity).run {
                requestReviewFlow().addOnSuccessListener { reviewInfoTask ->
                    launchReviewFlow(activity, reviewInfoTask)
                }
            }
            sharedPref.setAppReviewStartCount(0)
            return true
        } else {
            return false
        }
    }

    companion object {
        private const val APP_REVIEW_TRIGGER_COUNT = 19
    }
}
