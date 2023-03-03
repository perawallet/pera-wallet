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

package com.algorand.android.discover.home.ui.mapper

import com.algorand.android.discover.common.ui.model.DappFavoriteElement
import com.algorand.android.discover.home.domain.model.DappFavorite
import javax.inject.Inject

class DiscoverDappFavoritesMapper @Inject constructor() {

    fun mapToDappFavoriteElement(
        dappFavorite: DappFavorite
    ): DappFavoriteElement {
        return DappFavoriteElement(
            name = dappFavorite.name ?: "",
            url = dappFavorite.url ?: ""
        )
    }

    fun mapFromDappFavoriteElement(
        dappFavoriteElement: DappFavoriteElement
    ): DappFavorite {
        return DappFavorite(
            name = dappFavoriteElement.name,
            url = dappFavoriteElement.url,
            logo = null
        )
    }
}
