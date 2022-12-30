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

package com.algorand.android.nft.domain.decider

import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType.GRID
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType.LINEAR_VERTICAL
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import javax.inject.Inject

class BaseCollectibleListItemItemTypeDecider @Inject constructor() {

    fun decideSimpleNFTViewType(nftListingViewType: NFTListingViewType): BaseCollectibleListItem.ItemType {
        return when (nftListingViewType) {
            LINEAR_VERTICAL -> BaseCollectibleListItem.ItemType.LINEAR_VERTICAL_SIMPLE_NFT_ITEM
            GRID -> BaseCollectibleListItem.ItemType.GRID_SIMPLE_NFT_ITEM
        }
    }

    fun decideSimplePendingNFTViewType(nftListingViewType: NFTListingViewType): BaseCollectibleListItem.ItemType {
        return when (nftListingViewType) {
            LINEAR_VERTICAL -> BaseCollectibleListItem.ItemType.LINEAR_VERTICAL_SIMPLE_PENDING_ITEM
            GRID -> BaseCollectibleListItem.ItemType.GRID_SIMPLE_PENDING_ITEM
        }
    }
}
