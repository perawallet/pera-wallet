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

package com.algorand.android.modules.collectibles.listingviewtype.domain.decider

import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType.Companion.DEFAULT_VIEW_TYPE
import javax.inject.Inject

class NFTListingViewTypeDecider @Inject constructor() {

    fun decideNFTListingViewType(ordinal: Int?): NFTListingViewType {
        return when (ordinal) {
            NFTListingViewType.LINEAR_VERTICAL.ordinal -> NFTListingViewType.LINEAR_VERTICAL
            NFTListingViewType.GRID.ordinal -> NFTListingViewType.GRID
            else -> DEFAULT_VIEW_TYPE
        }
    }
}
