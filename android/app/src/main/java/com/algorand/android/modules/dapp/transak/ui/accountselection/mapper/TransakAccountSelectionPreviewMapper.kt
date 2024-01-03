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

package com.algorand.android.modules.dapp.transak.ui.accountselection.mapper

import com.algorand.android.mapper.AssetActionMapper
import com.algorand.android.modules.dapp.transak.getFullTransakUrl
import com.algorand.android.modules.dapp.transak.ui.accountselection.TransakAccountSelectionFragmentDirections
import com.algorand.android.modules.dapp.transak.ui.accountselection.model.TransakAccountSelectionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class TransakAccountSelectionPreviewMapper @Inject constructor(
    private val assetActionMapper: AssetActionMapper
) {

    fun mapToInitialPreview(): TransakAccountSelectionPreview {
        return TransakAccountSelectionPreview()
    }

    fun mapToAccountSelectedPreview(
        previousState: TransakAccountSelectionPreview,
        accountAddress: String,
        assetsNeedingOptInList: List<Long>,
        isMainnet: Boolean
    ): TransakAccountSelectionPreview {
        return if (assetsNeedingOptInList.isEmpty()) {
            previousState.copy(
                finalizeAccountSelectionEvent = Event(
                    TransakAccountSelectionFragmentDirections
                        .actionTransakAccountSelectionFragmentToTransakBrowserFragment(
                            getFullTransakUrl(accountAddress, isMainnet)
                        )
                )
            )
        } else {
            previousState.copy(
                optInToAssetEvent = Event(
                    assetActionMapper.mapTo(
                        assetId = assetsNeedingOptInList.first(),
                        publicKey = accountAddress,
                        asset = null
                    )
                )
            )
        }
    }

    fun mapToAssetOptedInPreview(
        previousState: TransakAccountSelectionPreview,
        accountAddress: String,
        isMainnet: Boolean
    ): TransakAccountSelectionPreview {
        return previousState.copy(
            finalizeAccountSelectionEvent = Event(
                TransakAccountSelectionFragmentDirections
                    .actionTransakAccountSelectionFragmentToTransakBrowserFragment(
                        getFullTransakUrl(accountAddress, isMainnet)
                    )
            )
        )
    }
}
