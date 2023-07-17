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
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionUpdateMapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.walletconnect.sign.client.Sign

class WalletConnectSessionUpdateMapperImpl(
    private val sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper
) : WalletConnectSessionUpdateMapper {

    override fun mapToSessionUpdate(
        sessionUpdateResponse: Sign.Model.SessionUpdateResponse
    ): WalletConnect.Session.Update {
        return when (sessionUpdateResponse) {
            is Sign.Model.SessionUpdateResponse.Result -> mapToSessionUpdateSuccess(sessionUpdateResponse)
            is Sign.Model.SessionUpdateResponse.Error -> mapToSessionUpdateError(sessionUpdateResponse)
        }
    }

    private fun mapToSessionUpdateSuccess(
        updateResponse: Sign.Model.SessionUpdateResponse.Result
    ): WalletConnect.Session.Update.Success {
        val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(updateResponse.topic)
        return WalletConnect.Session.Update.Success(
            sessionIdentifier = sessionIdentifier,
            versionIdentifier = sessionIdentifier.versionIdentifier
        )
    }

    private fun mapToSessionUpdateError(
        error: Sign.Model.SessionUpdateResponse.Error
    ): WalletConnect.Session.Update.Error {
        return WalletConnect.Session.Update.Error(
            message = error.errorMessage,
            versionIdentifier = WalletConnectClientV2Utils.getWalletConnectV2VersionIdentifier()
        )
    }
}
