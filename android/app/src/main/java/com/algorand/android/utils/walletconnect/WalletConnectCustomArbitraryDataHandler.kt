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

package com.algorand.android.utils.walletconnect

import com.algorand.android.models.Account
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.WalletConnectRequest.WalletConnectArbitraryDataRequest
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.ui.mapper.WalletConnectArbitraryDataMapper
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.walletconnect.WalletConnectRequestResult.Error
import com.algorand.android.utils.walletconnect.WalletConnectRequestResult.Success
import javax.inject.Inject

class WalletConnectCustomArbitraryDataHandler @Inject constructor(
    private val walletConnectArbitraryDataMapper: WalletConnectArbitraryDataMapper,
    private val errorProvider: WalletConnectErrorProvider,
    private val accountCacheManager: AccountCacheManager,
) {

    @SuppressWarnings("ReturnCount", "LongMethod")
    suspend fun handleArbitraryData(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        session: WalletConnect.SessionDetail,
        payloadList: List<*>,
        onResult: suspend (WalletConnectRequestResult) -> Unit
    ) {
        try {
            val wcArbitraryDataList = walletConnectArbitraryDataMapper.parseArbitraryDataPayload(payloadList)

            if (wcArbitraryDataList == null) {
                onResult(
                    Error(
                        sessionIdentifier,
                        requestIdentifier,
                        errorProvider.getUnableToParseArbitraryDataError()
                    )
                )
                return
            }

            if (wcArbitraryDataList.size > MAX_ARBITRARY_DATA_COUNT) {
                val error = errorProvider.getMaxArbitraryDataLimitError(MAX_ARBITRARY_DATA_COUNT)
                onResult(Error(sessionIdentifier, requestIdentifier, error))
                return
            }

            val walletConnectArbitraryDataList = wcArbitraryDataList.mapNotNull {
                walletConnectArbitraryDataMapper.createWalletConnectArbitraryData(session.peerMeta, it)
            }

            val requestId = requestIdentifier.getIdentifier()
            val version = sessionIdentifier.versionIdentifier
            val walletConnectSession = walletConnectArbitraryDataMapper.mapToWalletConnectSession(session)

            val result = WalletConnectArbitraryDataRequest(
                requestId = requestId,
                arbitraryDataList = walletConnectArbitraryDataList,
                session = walletConnectSession,
                versionIdentifier = version
            )

            onResult(Success(result))
        } catch (exception: Exception) {
            onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getUnableToParseArbitraryDataError()))
        }
    }

    private fun areSignersValid(
        arbitraryDataList: List<WalletConnectArbitraryData>
    ): Boolean {
        return arbitraryDataList.all { arbitraryData ->
            val signerPublicKey = arbitraryData.signerAccount?.address
            accountCacheManager.getCacheData(signerPublicKey)?.account?.type != Account.Type.LEDGER
        }
    }

    companion object {
        const val MAX_ARBITRARY_DATA_COUNT = 1000
    }
}
