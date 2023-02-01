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

package com.algorand.android.modules.collectibles.profile.ui.mapper

import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.collectibles.detail.base.ui.model.BaseCollectibleMediaItem
import com.algorand.android.modules.collectibles.detail.base.ui.model.CollectibleTraitItem
import com.algorand.android.modules.collectibles.profile.ui.model.CollectibleProfilePreview
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class CollectibleProfilePreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToCollectibleProfilePreview(
        isLoadingVisible: Boolean,
        asaStatusPreview: AsaStatusPreview?,
        nftName: AssetName,
        collectionNameOfNFT: String?,
        mediaListOfNFT: List<BaseCollectibleMediaItem>,
        traitListOfNFT: List<CollectibleTraitItem>?,
        nftDescription: String?,
        creatorAccountAddressOfNFT: AccountDisplayName,
        nftId: Long,
        formattedTotalSupply: String,
        peraExplorerUrl: String,
        isPureNFT: Boolean,
        primaryWarningResId: Int?,
        secondaryWarningResId: Int?,
        accountAddress: String
    ): CollectibleProfilePreview {
        return CollectibleProfilePreview(
            isLoadingVisible = isLoadingVisible,
            nftName = nftName,
            collectionNameOfNFT = collectionNameOfNFT,
            mediaListOfNFT = mediaListOfNFT,
            traitListOfNFT = traitListOfNFT,
            nftDescription = nftDescription,
            creatorAccountAddressOfNFT = creatorAccountAddressOfNFT,
            nftId = nftId,
            formattedTotalSupply = formattedTotalSupply,
            peraExplorerUrl = peraExplorerUrl,
            isPureNFT = isPureNFT,
            primaryWarningResId = primaryWarningResId,
            secondaryWarningResId = secondaryWarningResId,
            collectibleStatusPreview = asaStatusPreview,
            accountAddress = accountAddress
        )
    }
}
