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

package com.algorand.android.modules.dapp.transak.ui.intro.mapper

import androidx.navigation.NavDirections
import com.algorand.android.mapper.AssetActionMapper
import com.algorand.android.modules.dapp.transak.getFullTransakUrl
import com.algorand.android.modules.dapp.transak.ui.intro.TransakIntroFragmentDirections
import com.algorand.android.modules.dapp.transak.ui.intro.model.TransakIntroPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class TransakIntroPreviewMapper @Inject constructor(
    private val assetActionMapper: AssetActionMapper
) {

    fun mapToInitialPreview(): TransakIntroPreview {
        return TransakIntroPreview()
    }

    fun mapToAccountSelectedPreview(
        previousState: TransakIntroPreview,
        accountAddress: String?,
        assetsNeedingOptInList: List<Long>?,
        isTransakBrowserAllowed: Boolean,
        isMainNet: Boolean
    ): TransakIntroPreview {
        return if (isTransakBrowserAllowed) {
            if (assetsNeedingOptInList.isNullOrEmpty()) {
                val navDirection = getNextNavigationDirection(accountAddress, isMainNet)
                previousState.copy(
                    navigateEvent = Event(navDirection),
                    optInToAssetEvent = null,
                    showNotAvailableErrorEvent = null
                )
            } else {
                previousState.copy(
                    navigateEvent = null,
                    optInToAssetEvent = Event(
                        assetActionMapper.mapTo(
                            assetId = assetsNeedingOptInList.first(),
                            publicKey = accountAddress,
                            asset = null
                        )
                    ),
                    showNotAvailableErrorEvent = null
                )
            }
        } else {
            previousState.copy(
                navigateEvent = null,
                optInToAssetEvent = null,
                showNotAvailableErrorEvent = Event(Unit)
            )
        }
    }

    fun mapToAssetOptedInPreview(
        previousState: TransakIntroPreview,
        accountAddress: String,
        isMainNet: Boolean
    ): TransakIntroPreview {
        val navDirection = getNextNavigationDirection(accountAddress, isMainNet)
        return previousState.copy(
            navigateEvent = Event(navDirection),
            optInToAssetEvent = null,
            showNotAvailableErrorEvent = null
        )
    }

    private fun getNextNavigationDirection(accountAddress: String?, isMainNet: Boolean): NavDirections {
        return if (accountAddress == null) {
            TransakIntroFragmentDirections.actionTransakIntroFragmentToTransakAccountSelectionFragment()
        } else {
            val url = getFullTransakUrl(accountAddress, isMainNet)
            TransakIntroFragmentDirections.actionTransakIntroFragmentToTransakBrowserFragment(
                url = url
            )
        }
    }
}
