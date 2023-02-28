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

package com.algorand.android.modules.walletconnect.mapper

import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectPeerMetaDTO
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject
import org.walletconnect.Session

class WalletConnectPeerMetaMapper @Inject constructor() {

    fun mapToPeerMeta(
        name: String,
        url: String,
        description: String?,
        icons: List<String>?,
        redirectUrl: String?
    ): WalletConnect.PeerMeta {
        return WalletConnect.PeerMeta(
            name = name,
            url = url,
            description = description,
            icons = icons,
            redirectUrl = redirectUrl
        )
    }

    fun mapToPeerMeta(peerMeta: Session.PeerMeta?): WalletConnect.PeerMeta {
        return WalletConnect.PeerMeta(
            name = peerMeta?.name.orEmpty(),
            url = peerMeta?.url.orEmpty(),
            description = peerMeta?.description,
            icons = peerMeta?.icons,
            redirectUrl = null
        )
    }

    fun mapToPeerMeta(peerMeta: WalletConnectPeerMetaDTO): WalletConnect.PeerMeta {
        return WalletConnect.PeerMeta(
            name = peerMeta.name,
            url = peerMeta.url,
            description = peerMeta.description,
            icons = peerMeta.icons,
            redirectUrl = null
        )
    }
}
