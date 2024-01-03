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

package com.algorand.android.modules.transaction.common.data.mapper

import com.algorand.android.modules.transaction.common.data.model.AssetConfigurationResponse
import com.algorand.android.modules.transaction.common.domain.model.AssetConfigurationDTO
import javax.inject.Inject

class AssetConfigurationDTOMapper @Inject constructor() {

    fun mapToAssetConfigurationDTO(assetConfigurationResponse: AssetConfigurationResponse): AssetConfigurationDTO {
        with(assetConfigurationResponse) {
            return AssetConfigurationDTO(
                assetId = assetId,
                creator = params?.creator,
                decimals = params?.decimals,
                defaultFrozen = params?.defaultFrozen,
                metadataHash = params?.metadataHash,
                name = params?.name,
                nameB64 = params?.nameB64,
                maxSupply = params?.maxSupply,
                unitName = params?.unitName,
                unitNameB64 = params?.unitNameB64,
                url = params?.url,
                urlB64 = params?.urlB64
            )
        }
    }
}
