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

package com.algorand.android.modules.fetchnameservices.data.model

import com.algorand.android.modules.fetchnameservices.data.model.NameServiceSourceResponse.NFDOMAIN
import com.algorand.android.modules.fetchnameservices.data.model.NameServiceSourceResponse.UNKNOWN
import com.algorand.android.modules.fetchnameservices.domain.model.NameServiceSourceDTO
import javax.inject.Inject

class NameServiceSourceDTOMapper @Inject constructor() {

    fun mapToNameServiceSourceDTO(nameServiceSourceResponse: NameServiceSourceResponse?): NameServiceSourceDTO? {
        return when (nameServiceSourceResponse) {
            NFDOMAIN -> NameServiceSourceDTO.NFDOMAIN
            UNKNOWN -> NameServiceSourceDTO.UNKNOWN
            null -> null
        }
    }
}
