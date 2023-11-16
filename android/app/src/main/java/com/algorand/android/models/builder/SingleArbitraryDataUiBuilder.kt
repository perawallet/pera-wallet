/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models.builder

import com.algorand.android.R
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.WalletConnectArbitraryDataShortDetail
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.utils.ALGO_DECIMALS
import javax.inject.Inject

class SingleArbitraryDataUiBuilder @Inject constructor(
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider
) {

    fun buildToolbarTitleRes(): Int {
        return R.string.arbitrary_data
    }

    fun buildArbitraryDataMessage(
        arbitraryData: WalletConnectArbitraryData
    ): String {
        return arbitraryData.message.orEmpty()
    }

    fun buildArbitraryDataShortDetail(
        arbitraryData: WalletConnectArbitraryData

    ): WalletConnectArbitraryDataShortDetail {
        return with(arbitraryData) {
            WalletConnectArbitraryDataShortDetail(
                accountIconDrawablePreview = signerAccount?.accountIconDrawablePreview,
                accountName = signerAccount?.name,
                accountBalance = signerAlgoBalance?.amount,
                decimal = ALGO_DECIMALS,
                fee = 0L
            )
        }
    }
}
