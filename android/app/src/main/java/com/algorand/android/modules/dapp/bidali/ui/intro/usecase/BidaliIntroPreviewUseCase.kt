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

package com.algorand.android.modules.dapp.bidali.ui.intro.usecase

import androidx.navigation.NavDirections
import com.algorand.android.modules.dapp.bidali.getBidaliUrl
import com.algorand.android.modules.dapp.bidali.ui.intro.BidaliIntroFragmentDirections
import com.algorand.android.modules.dapp.bidali.ui.intro.model.BidaliIntroPreview
import com.algorand.android.usecase.IsOnMainnetUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.isStagingApp
import javax.inject.Inject

class BidaliIntroPreviewUseCase @Inject constructor(
    private val isOnMainnetUseCase: IsOnMainnetUseCase
) {

    fun getInitialStatePreview() = BidaliIntroPreview(
        navigateEvent = null,
        showNotAvailableErrorEvent = null
    )

    fun getNavigateToNextScreenUpdatedPreview(
        previousState: BidaliIntroPreview,
        accountAddress: String?
    ): BidaliIntroPreview {
        return if (isBidaliBrowserAllowed()) {
            previousState.copy(
                navigateEvent = Event(getNextNavigationDirection(accountAddress)),
                showNotAvailableErrorEvent = null
            )
        } else {
            previousState.copy(
                navigateEvent = null,
                showNotAvailableErrorEvent = Event(Unit)
            )
        }
    }

    private fun getNextNavigationDirection(accountAddress: String?): NavDirections {
        return if (accountAddress == null) {
            BidaliIntroFragmentDirections.actionBidaliIntroFragmentToBidaliAccountSelectionFragment()
        } else {
            val isMainnet = isOnMainnetUseCase.invoke()
            val url = getBidaliUrl(isMainnet = isMainnet)
            BidaliIntroFragmentDirections.actionBidaliIntroFragmentToBidaliBrowserFragment(
                url = url,
                accountAddress = accountAddress
            )
        }
    }

    private fun isBidaliBrowserAllowed(): Boolean {
        return isStagingApp() || isOnMainnetUseCase.invoke()
    }
}
