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

import com.algorand.android.models.ArbitraryDataRequestAmountInfo
import com.algorand.android.models.ArbitraryDataRequestDataInfo
import com.algorand.android.models.ArbitraryDataRequestInfo
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.utils.toShortenedAddress
import java.math.BigInteger
import javax.inject.Inject

class ArbitraryDataDetailUiBuilder @Inject constructor() {

    fun buildArbitraryDataDetail(
        arbitraryData: WalletConnectArbitraryData
    ): WalletConnectArbitraryData {
        return arbitraryData
    }

    fun buildArbitraryDataRequestInfo(
        arbitraryData: WalletConnectArbitraryData
    ): ArbitraryDataRequestInfo? {
        with(arbitraryData) {
            return ArbitraryDataRequestInfo(
                fromDisplayedAddress = BaseWalletConnectDisplayedAddress.ShortenedAddress(
                    signerAccount?.address.toShortenedAddress(),
                    signerAccount?.address.orEmpty()
                ),
                fromAccountIconDrawablePreview = signerAccount?.accountIconDrawablePreview,
                toAccountIconDrawablePreview = null,
                toDisplayedAddress = BaseWalletConnectDisplayedAddress.FullAddress(
                    arbitraryData.peerMeta?.name.orEmpty()
                ),
                accountBalance = arbitraryData.signerAlgoBalance?.amount
            )
        }
    }

    fun buildArbitraryDataRequestAmountInfo(
        arbitraryData: WalletConnectArbitraryData
    ): ArbitraryDataRequestAmountInfo {
        return ArbitraryDataRequestAmountInfo(BigInteger.ZERO)
    }

    fun buildArbitraryDataRequestDataInfo(
        arbitraryData: WalletConnectArbitraryData
    ): ArbitraryDataRequestDataInfo? {
        return ArbitraryDataRequestDataInfo(
            data = arbitraryData.message.orEmpty()
        )
    }
}
