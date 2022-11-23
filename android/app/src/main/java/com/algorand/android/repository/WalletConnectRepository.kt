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

package com.algorand.android.repository

import com.algorand.android.database.WalletConnectDao
import com.algorand.android.deviceregistration.domain.repository.FirebasePushTokenRepository
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.WalletConnectSessionAccountEntity
import com.algorand.android.models.WalletConnectSessionByAccountsAddress
import com.algorand.android.models.WalletConnectSessionEntity
import com.algorand.android.models.WalletConnectSessionSubscriptionBody
import com.algorand.android.models.WalletConnectSessionWithAccountsAddresses
import com.algorand.android.network.MobileAlgorandApi
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.Flow

class WalletConnectRepository @Inject constructor(
    private val walletConnectDao: WalletConnectDao,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val mobileAlgorandApi: MobileAlgorandApi,
    @Named(FirebasePushTokenRepository.FIREBASE_PUSH_TOKEN_REPOSITORY_INJECTION_NAME)
    private val firebasePushTokenRepository: FirebasePushTokenRepository
) {

    suspend fun getAllDisconnectedSessions(): List<WalletConnectSessionEntity> {
        return walletConnectDao.getAllDisconnectedWCSessions()
    }

    suspend fun getSessionById(sessionId: Long): WalletConnectSessionEntity? {
        return walletConnectDao.getSessionById(sessionId)
    }

    suspend fun deleteSessionById(sessionId: Long) {
        walletConnectDao.deleteById(sessionId)
    }

    suspend fun setAllSessionsDisconnected() {
        walletConnectDao.setAllSessionsDisconnected()
    }

    suspend fun setSessionDisconnected(sessionId: Long) {
        walletConnectDao.setSessionDisconnected(sessionId)
    }

    suspend fun insertConnectedWalletConnectSession(
        wcSessionEntity: WalletConnectSessionEntity,
        wcSessionAccountList: List<WalletConnectSessionAccountEntity>
    ) {
        walletConnectDao.insertWalletConnectSessionAndHistory(
            wcSessionEntity = wcSessionEntity,
            wcSessionAccountList = wcSessionAccountList
        )
    }

    suspend fun subscribeWalletConnectSession(
        wcSessionEntity: WalletConnectSessionEntity
    ) {
        mobileAlgorandApi.subscribeWalletConnectSession(
            WalletConnectSessionSubscriptionBody(
                device = deviceIdUseCase.getSelectedNodeDeviceId() ?: "",
                bridgeUrl = wcSessionEntity.wcSession.bridge,
                topicId = wcSessionEntity.wcSession.topic,
                dappName = wcSessionEntity.peerMeta.name,
                pushToken = firebasePushTokenRepository.getPushTokenOrNull()?.data ?: ""
            )
        )
    }

    suspend fun setConnectedSession(session: WalletConnectSessionEntity) {
        walletConnectDao.setSessionConnected(session.id)
    }

    suspend fun getWCSessionList(): List<WalletConnectSessionEntity> {
        return walletConnectDao.getWCSessionList()
    }

    suspend fun getWCSessionListByAccountAddress(accountAddress: String): List<WalletConnectSessionByAccountsAddress>? {
        return walletConnectDao.getWCSessionListByAccountAddress(accountAddress)
    }

    suspend fun getConnectedAccountsOfSession(sessionId: Long): List<WalletConnectSessionAccountEntity>? {
        return walletConnectDao.getConnectedAccountsOfSession(sessionId)
    }

    fun getAllWalletConnectSessionWithAccountAddresses(): Flow<List<WalletConnectSessionWithAccountsAddresses>?> {
        return walletConnectDao.getAllWalletConnectSessionWithAccountAddresses()
    }

    suspend fun deleteWalletConnectAccountBySession(sessionId: Long, accountAddress: String) {
        return walletConnectDao.deleteWalletConnectAccountBySession(sessionId, accountAddress)
    }
}
