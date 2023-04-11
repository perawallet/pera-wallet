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

package com.algorand.android.modules.dapp.sardine.ui.intro.usecase

import androidx.navigation.NavDirections
import com.algorand.android.modules.dapp.sardine.ui.getFullSardineUrl
import com.algorand.android.modules.dapp.sardine.ui.intro.SardineIntroFragmentDirections
import com.algorand.android.modules.dapp.sardine.ui.intro.model.SardineIntroPreview
import com.algorand.android.usecase.IsOnMainnetUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.isStagingApp
import javax.inject.Inject

class SardineIntroPreviewUseCase @Inject constructor(
    private val isOnMainnetUseCase: IsOnMainnetUseCase
) {

    fun getInitialStatePreview() = SardineIntroPreview(
        navigateEvent = null,
        showNotAvailableErrorEvent = null
    )

    fun getNavigateToNextScreenUpdatedPreview(
        previousState: SardineIntroPreview,
        accountAddress: String?
    ): SardineIntroPreview {
        return if (isSardineBrowserAllowed()) {
            val navDirection = getNextNavigationDirection(accountAddress)
            previousState.copy(
                navigateEvent = Event(navDirection),
                showNotAvailableErrorEvent = null
            )
        } else {
            previousState.copy(
                navigateEvent = null,
                showNotAvailableErrorEvent = Event(Unit)
            )
        }
    }

    private fun isSardineBrowserAllowed(): Boolean {
        return isStagingApp() || isOnMainnetUseCase.invoke()
    }

    private fun getNextNavigationDirection(accountAddress: String?): NavDirections {
        return if (accountAddress == null) {
            SardineIntroFragmentDirections.actionSardineIntroFragmentToSardineAccountSelectionFragment()
        } else {
            val isMainnet = isOnMainnetUseCase.invoke()
            val url = getFullSardineUrl(accountAddress = accountAddress, isMainnet = isMainnet)
            SardineIntroFragmentDirections.actionSardineIntroFragmentToSardineBrowserFragment(url)
        }
    }
}
