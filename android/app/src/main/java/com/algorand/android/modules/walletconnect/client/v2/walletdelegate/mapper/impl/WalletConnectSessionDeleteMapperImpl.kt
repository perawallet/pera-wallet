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
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionDeleteMapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.walletconnect.sign.client.Sign

class WalletConnectSessionDeleteMapperImpl(
    private val sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper
) : WalletConnectSessionDeleteMapper {

    override fun mapToSessionDelete(deletedSession: Sign.Model.DeletedSession): WalletConnect.Session.Delete {
        return when (deletedSession) {
            is Sign.Model.DeletedSession.Success -> createDeleteSuccess(deletedSession)
            is Sign.Model.DeletedSession.Error -> createDeleteError(deletedSession)
        }
    }

    private fun createDeleteSuccess(success: Sign.Model.DeletedSession.Success): WalletConnect.Session.Delete.Success {
        return WalletConnect.Session.Delete.Success(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(success.topic),
            reason = success.reason,
            versionIdentifier = WalletConnectClientV2Utils.getWalletConnectV2VersionIdentifier()
        )
    }

    private fun createDeleteError(error: Sign.Model.DeletedSession.Error): WalletConnect.Session.Delete.Error {
        return WalletConnect.Session.Delete.Error(
            error = error.error,
            versionIdentifier = WalletConnectClientV2Utils.getWalletConnectV2VersionIdentifier()
        )
    }
}
