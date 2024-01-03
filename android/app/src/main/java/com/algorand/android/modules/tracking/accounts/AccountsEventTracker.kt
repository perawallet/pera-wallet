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

package com.algorand.android.modules.tracking.accounts

import com.algorand.android.modules.tracking.moonpay.AccountsFragmentAlgoBuyTapEventTracker
import com.algorand.android.modules.tracking.swap.accounts.AccountsSwapClickEventTracker
import com.algorand.android.modules.tracking.swap.swaptutorial.SwapTutorialLaterClickEventTracker
import com.algorand.android.modules.tracking.swap.swaptutorial.SwapTutorialTrySwapClickEventTracker
import javax.inject.Inject

class AccountsEventTracker @Inject constructor(
    private val accountsAddAccountEventTracker: AccountsAddAccountEventTracker,
    private val accountsQrScanEventTracker: AccountsQrScanEventTracker,
    private val accountsQrConnectEventTracker: AccountsQrConnectEventTracker,
    private val visitGovernanceEventTracker: VisitGovernanceEventTracker,
    private val trySwapClickEventTracker: SwapTutorialTrySwapClickEventTracker,
    private val laterClickEventTracker: SwapTutorialLaterClickEventTracker,
    private val accountsFragmentAlgoBuyTapEventTracker: AccountsFragmentAlgoBuyTapEventTracker,
    private val accountsSwapClickEventTracker: AccountsSwapClickEventTracker
) {

    suspend fun logAddAccountTapEvent() {
        accountsAddAccountEventTracker.logAddAccountTapEvent()
    }

    suspend fun logQrScanTapEvent() {
        accountsQrScanEventTracker.logQrScanEvent()
    }

    suspend fun logAccountsQrConnectEvent() {
        accountsQrConnectEventTracker.logAccountsQrConnectEvent()
    }

    suspend fun logVisitGovernanceEvent() {
        visitGovernanceEventTracker.logVisitGovernanceEvent()
    }

    suspend fun logSwapTutorialTrySwapClickEvent() {
        trySwapClickEventTracker.logSwapTutorialTrySwapClickEvent()
    }

    suspend fun logSwapClickEvent() {
        accountsSwapClickEventTracker.logSwapButtonClickEvent()
    }

    suspend fun logSwapLaterClickEvent() {
        laterClickEventTracker.logSwapLaterClickEvent()
    }

    suspend fun logAccountsFragmentAlgoBuyTapEvent() {
        accountsFragmentAlgoBuyTapEventTracker.logAccountsFragmentAlgoBuyTapEvent()
    }
}
