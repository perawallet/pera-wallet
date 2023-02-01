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

package com.algorand.android.modules.fetchnameservices.data.mapper

import com.algorand.android.modules.fetchnameservices.data.model.NameServiceResultResponse
import com.algorand.android.modules.fetchnameservices.data.model.NameServiceSourceDTOMapper
import com.algorand.android.modules.fetchnameservices.domain.model.NameServiceDTO
import javax.inject.Inject

class NameServicesDTOMapper @Inject constructor(
    private val nameServiceSourceDTOMapper: NameServiceSourceDTOMapper
) {

    fun mapToNameServicesDTO(nameServiceResultResponse: NameServiceResultResponse): NameServiceDTO {
        return with(nameServiceResultResponse) {
            NameServiceDTO(
                accountAddress = address.orEmpty(),
                nameServiceName = nameResponse?.name,
                nameServiceSource = nameServiceSourceDTOMapper.mapToNameServiceSourceDTO(nameResponse?.source),
                nameServiceUri = nameResponse?.imageUri
            )
        }
    }
}
