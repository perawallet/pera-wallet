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

package com.algorand.android.modules.walletconnect.client.v2.data.mapper

import com.algorand.android.modules.walletconnect.client.v2.data.model.WalletConnectV2SessionEntity
import com.algorand.android.modules.walletconnect.client.v2.domain.model.WalletConnectSessionDto
import javax.inject.Inject

class WalletConnectSessionEntityMapper @Inject constructor() {

    fun mapToEntity(dto: WalletConnectSessionDto): WalletConnectV2SessionEntity {
        return WalletConnectV2SessionEntity(
            topic = dto.topic,
            dateTimeStamp = dto.creationDateTimestamp,
            fallbackBrowserGroupResponse = dto.fallbackBrowserGroupResponse
        )
    }
}
