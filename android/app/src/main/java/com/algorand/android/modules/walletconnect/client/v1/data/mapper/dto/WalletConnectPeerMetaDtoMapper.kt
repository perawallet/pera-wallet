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

import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectPeerMetaEntity
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectPeerMetaDto
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject

class WalletConnectPeerMetaDtoMapper @Inject constructor() {

    fun mapToPeerMetaDto(entity: WalletConnectPeerMetaEntity): WalletConnectPeerMetaDto {
        return WalletConnectPeerMetaDto(
            name = entity.name,
            url = entity.url,
            description = entity.description,
            icons = entity.icons
        )
    }

    fun mapToPeerMetaDto(peerMeta: WalletConnect.PeerMeta): WalletConnectPeerMetaDto {
        return WalletConnectPeerMetaDto(
            name = peerMeta.name,
            url = peerMeta.url,
            description = peerMeta.description,
            icons = peerMeta.icons.orEmpty()
        )
    }
}
