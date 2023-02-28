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

package com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto

import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionMetaEntity
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionMetaDTO
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject

class WalletConnectSessionMetaDTOMapper @Inject constructor() {

    fun mapToSessionMetaDTO(sessionMetaEntity: WalletConnectSessionMetaEntity): WalletConnectSessionMetaDTO {
        return WalletConnectSessionMetaDTO(
            bridge = sessionMetaEntity.bridge,
            key = sessionMetaEntity.key,
            topic = sessionMetaEntity.topic,
            version = sessionMetaEntity.version
        )
    }

    fun mapToSessionMetaDTO(sessionMeta: WalletConnect.Session.Meta.Version1): WalletConnectSessionMetaDTO {
        return WalletConnectSessionMetaDTO(
            bridge = sessionMeta.bridge,
            key = sessionMeta.key,
            topic = sessionMeta.topic,
            version = sessionMeta.version
        )
    }
}
