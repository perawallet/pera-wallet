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

package com.algorand.android.assetsearch.domain.mapper

import com.algorand.android.assetsearch.domain.model.CollectibleSearchDTO
import com.algorand.android.assetsearch.domain.model.CollectibleSearch
import javax.inject.Inject

class CollectibleSearchMapper @Inject constructor() {

    fun mapToCollectibleSearch(collectibleSearchDTO: CollectibleSearchDTO?): CollectibleSearch? {
        if (collectibleSearchDTO == null) return null
        return CollectibleSearch(
            primaryImageUrl = collectibleSearchDTO.primaryImageUrl,
            title = collectibleSearchDTO.title,
        )
    }
}
