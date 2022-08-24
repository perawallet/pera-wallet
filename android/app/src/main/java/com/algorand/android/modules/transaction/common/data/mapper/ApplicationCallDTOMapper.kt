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

import com.algorand.android.modules.transaction.common.data.model.ApplicationCallResponse
import com.algorand.android.modules.transaction.common.domain.model.ApplicationCallDTO
import javax.inject.Inject

class ApplicationCallDTOMapper @Inject constructor(
    private val onCompletionDTOMapper: OnCompletionDTOMapper
) {

    fun mapToApplicationCallDTO(applicationCallResponse: ApplicationCallResponse): ApplicationCallDTO {
        with(applicationCallResponse) {
            return ApplicationCallDTO(
                applicationId = applicationId,
                accounts = accounts,
                foreignApps = foreignApps,
                foreignAssets = foreignAssets,
                onCompletion = onCompletionDTOMapper.mapToOnCompletionDTO(onCompletion)
            )
        }
    }
}
