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

import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse
import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse.CLEAR_STATE
import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse.CLOSE_OUT
import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse.DELETE_APPLICATION
import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse.NO_OP
import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse.OPT_IN
import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse.UNKNOWN
import com.algorand.android.modules.transaction.common.data.model.OnCompletionResponse.UPDATE_APPLICATION
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO
import javax.inject.Inject

class OnCompletionDTOMapper @Inject constructor() {

    fun mapToOnCompletionDTO(onCompletionResponse: OnCompletionResponse?): OnCompletionDTO {
        return when (onCompletionResponse) {
            OPT_IN -> OnCompletionDTO.OPT_IN
            NO_OP -> OnCompletionDTO.NO_OP
            CLOSE_OUT -> OnCompletionDTO.CLOSE_OUT
            CLEAR_STATE -> OnCompletionDTO.CLEAR_STATE
            UPDATE_APPLICATION -> OnCompletionDTO.UPDATE_APPLICATION
            DELETE_APPLICATION -> OnCompletionDTO.DELETE_APPLICATION
            UNKNOWN, null -> OnCompletionDTO.UNKNOWN
        }
    }
}
