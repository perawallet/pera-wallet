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

package com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl

import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectClientV2Utils
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionSettleErrorMapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.walletconnect.sign.client.Sign

class WalletConnectSessionSettleErrorMapperImpl(
    private val sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper
) : WalletConnectSessionSettleErrorMapper {

    override fun mapToSessionSettleError(
        settleSessionResponse: Sign.Model.SettledSessionResponse.Error
    ): WalletConnect.Session.Settle.Error {
        return WalletConnect.Session.Settle.Error(
            errorMessage = settleSessionResponse.errorMessage,
            versionIdentifier = WalletConnectClientV2Utils.getWalletConnectV2VersionIdentifier(),
            throwable = null,
            sessionIdentifier = null
        )
    }

    override fun mapToSessionSettleError(
        sessionTopic: String,
        throwable: Throwable
    ): WalletConnect.Session.Settle.Error {
        val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionTopic)
        return WalletConnect.Session.Settle.Error(
            sessionIdentifier = sessionIdentifier,
            throwable = throwable,
            errorMessage = throwable.message,
            versionIdentifier = sessionIdentifier.versionIdentifier
        )
    }
}
