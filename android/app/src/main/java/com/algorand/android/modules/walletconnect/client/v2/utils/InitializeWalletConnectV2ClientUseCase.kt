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

package com.algorand.android.modules.walletconnect.client.v2.utils

import android.app.Application
import android.util.Log
import com.algorand.android.deviceregistration.domain.usecase.FirebasePushTokenUseCase
import com.algorand.android.modules.walletconnect.client.v2.domain.WalletConnectV2SignClient
import com.algorand.android.utils.walletconnect.peermeta.WalletConnectPeraPeerMeta
import com.walletconnect.android.Core
import com.walletconnect.android.CoreClient
import com.walletconnect.android.relay.ConnectionType
import com.walletconnect.sign.client.Sign
import com.walletconnect.web3.wallet.client.Wallet
import com.walletconnect.web3.wallet.client.Web3Wallet
import javax.inject.Inject

class InitializeWalletConnectV2ClientUseCase @Inject constructor(
    private val signClient: WalletConnectV2SignClient,
    private val firebasePushTokenUseCase: FirebasePushTokenUseCase
) {

    operator fun invoke(application: Application) {
        initializeCoreClient(application)
        registerFirebasePushToken()
        initializeSignClient()
    }

    private fun initializeCoreClient(application: Application) {
        CoreClient.initialize(
            relayServerUrl = getRelayServerUrl(),
            connectionType = ConnectionType.MANUAL,
            application = application,
            metaData = getPeraWalletAppMetaData()
        ) { error ->
            logError(CoreClient::class.simpleName, error.throwable)
        }
    }

    private fun registerFirebasePushToken() {
        val initParams = Wallet.Params.Init(core = CoreClient)

        Web3Wallet.initialize(initParams) { error ->
            logError(Web3Wallet::class.simpleName, error.throwable)
        }

        val firebaseAccessToken = firebasePushTokenUseCase.getPushTokenOrNull()?.data.orEmpty()
        val enableEncrypted: Boolean = false

        Web3Wallet.registerDeviceToken(
            firebaseAccessToken = firebaseAccessToken,
            enableEncrypted = enableEncrypted,
            onSuccess = {
                // No need to do anything here
            },
            onError = { error: Wallet.Model.Error ->
                // No need to do anything here
            }
        )
    }

    private fun initializeSignClient() {
        val initParams = Sign.Params.Init(core = CoreClient)
        signClient.initialize(initParams)
    }

    private fun getPeraWalletAppMetaData(): Core.Model.AppMetaData {
        return with(WalletConnectPeraPeerMeta) {
            Core.Model.AppMetaData(
                name = name,
                description = description.orEmpty(),
                url = url,
                icons = icons.orEmpty(),
                redirect = redirectUrl
            )
        }
    }

    private fun getRelayServerUrl(): String {
        return WalletConnectV2ServerUrlBuilder.create()
            .addProjectId(PROJECT_ID)
            .build()
    }

    private fun logError(className: String?, throwable: Throwable) {
        Log.e(logTag, "$className - ${throwable.printStackTrace()}")
    }

    companion object {
        // TODO Change project id when it is decided
        private const val PROJECT_ID = "d98a4285aff59c9cd463bdd8b7415465"

        private val logTag = InitializeWalletConnectV2ClientUseCase::class.simpleName
    }
}
