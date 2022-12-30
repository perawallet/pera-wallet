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

package com.algorand.android.modules.accountdetail.assets.ui.decider

import com.algorand.android.R
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType.GRID
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType.LINEAR_VERTICAL
import com.algorand.android.utils.nftindicatordrawable.BaseNFTIndicatorDrawable
import com.algorand.android.utils.nftindicatordrawable.OvalNFTIndicatorDrawable
import com.algorand.android.utils.nftindicatordrawable.RectNFTIndicatorDrawable
import javax.inject.Inject

class NFTIndicatorDrawableDecider @Inject constructor() {

    fun decideNFTIndicatorDrawable(
        isOwned: Boolean,
        isHoldingByWatchAccount: Boolean,
        nftListingViewType: NFTListingViewType
    ): BaseNFTIndicatorDrawable? {
        return when (nftListingViewType) {
            LINEAR_VERTICAL -> when {
                isHoldingByWatchAccount -> createOvalWatchAccountIndicator()
                !isOwned -> createOvalOptedInIndicator()
                else -> null
            }
            GRID -> when {
                isHoldingByWatchAccount -> createRectWatchAccountIndicator()
                !isOwned -> createRectOptedInIndicator()
                else -> null
            }
        }
    }

    private fun createOvalWatchAccountIndicator(): BaseNFTIndicatorDrawable {
        return OvalNFTIndicatorDrawable.create(
            drawableResId = R.drawable.ic_eye,
            tintColor = R.color.wallet_1_icon_governor
        )
    }

    private fun createOvalOptedInIndicator(): BaseNFTIndicatorDrawable {
        return OvalNFTIndicatorDrawable.create(
            drawableResId = R.drawable.ic_error,
            tintColor = R.color.negative
        )
    }

    private fun createRectWatchAccountIndicator(): BaseNFTIndicatorDrawable {
        return RectNFTIndicatorDrawable.create(
            drawableResId = R.drawable.ic_eye,
            tintColor = R.color.white
        )
    }

    private fun createRectOptedInIndicator(): BaseNFTIndicatorDrawable {
        return RectNFTIndicatorDrawable.create(
            drawableResId = R.drawable.ic_error,
            tintColor = R.color.white
        )
    }
}
