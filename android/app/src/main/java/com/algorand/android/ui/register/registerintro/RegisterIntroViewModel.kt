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

package com.algorand.android.ui.register.registerintro

import android.content.SharedPreferences
import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import com.algorand.android.R
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.preference.setRegisterSkip

class RegisterIntroViewModel @ViewModelInject constructor(
    private val sharedPref: SharedPreferences,
    @Assisted private val savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val isShowingCloseButton = savedStateHandle.getOrElse(IS_SHOWING_CLOSE_BUTTON_KEY, false)
    private val shouldNavToRegisterWatchAccount = savedStateHandle.getOrElse(
        SHOULD_NAV_TO_REGISTER_WATCH_ACCOUNT, false
    )

    fun setRegisterSkip() {
        sharedPref.setRegisterSkip()
    }

    fun getIsShowingCloseButton(): Boolean {
        return isShowingCloseButton
    }

    // TODO: 1/24/22 Return all UI related fields in a preview object with a use case
    fun getStartIconResId(): Int? {
        return if (isShowingCloseButton) R.drawable.ic_close else null
    }

    fun getShouldNavToRegisterWatchAccount(): Boolean {
        return shouldNavToRegisterWatchAccount
    }

    companion object {
        private const val IS_SHOWING_CLOSE_BUTTON_KEY = "isShowingCloseButton"
        private const val SHOULD_NAV_TO_REGISTER_WATCH_ACCOUNT = "shouldNavToRegisterWatchAccount"
    }
}
