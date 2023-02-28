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

package com.algorand.android.modules.walletconnect.client.v1.session.mapper

import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionMetaDTO
import javax.inject.Inject
import org.walletconnect.Session

class WalletConnectSessionConfigMapper @Inject constructor() {

    fun createSessionConfig(sessionMeta: WalletConnectSessionMetaDTO): Session.Config {
        return with(sessionMeta) {
            Session.Config(
                handshakeTopic = topic,
                bridge = bridge,
                key = key,
                version = version.toInt()
            )
        }
    }
}
