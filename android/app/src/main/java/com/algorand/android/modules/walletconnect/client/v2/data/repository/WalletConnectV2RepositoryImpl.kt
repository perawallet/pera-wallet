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

package com.algorand.android.modules.walletconnect.client.v2.data.repository

import com.algorand.android.modules.walletconnect.client.v2.data.cache.WalletConnectV2PairUriLocalCache
import com.algorand.android.modules.walletconnect.client.v2.data.db.WalletConnectV2Dao
import com.algorand.android.modules.walletconnect.client.v2.data.mapper.WalletConnectSessionDtoMapper
import com.algorand.android.modules.walletconnect.client.v2.data.mapper.WalletConnectSessionEntityMapper
import com.algorand.android.modules.walletconnect.client.v2.domain.model.WalletConnectSessionDto
import com.algorand.android.modules.walletconnect.client.v2.domain.model.WalletConnectV2PairUri
import com.algorand.android.modules.walletconnect.client.v2.domain.repository.WalletConnectV2Repository
import com.algorand.android.utils.CacheResult

// Provided by hilt
class WalletConnectV2RepositoryImpl(
    private val walletConnectV2Dao: WalletConnectV2Dao,
    private val sessionDtoMapper: WalletConnectSessionDtoMapper,
    private val sessionEntityMapper: WalletConnectSessionEntityMapper,
    private val pairUriLocalCache: WalletConnectV2PairUriLocalCache
) : WalletConnectV2Repository {

    override suspend fun insertWalletConnectSession(sessionDto: WalletConnectSessionDto) {
        val sessionEntity = sessionEntityMapper.mapToEntity(sessionDto)
        walletConnectV2Dao.insertWalletConnectSession(sessionEntity)
    }

    override suspend fun getSessionById(sessionTopic: String): WalletConnectSessionDto? {
        val sessionEntity = walletConnectV2Dao.getSessionById(sessionTopic) ?: return null
        return sessionDtoMapper.mapToSessionDto(sessionEntity)
    }

    override suspend fun deleteById(sessionTopic: String) {
        walletConnectV2Dao.deleteById(sessionTopic)
    }

    override suspend fun getWCSessionList(): List<WalletConnectSessionDto> {
        return walletConnectV2Dao.getWCSessionList().map { entity ->
            sessionDtoMapper.mapToSessionDto(entity)
        }
    }

    override suspend fun cachePairUri(uri: CacheResult.Success<WalletConnectV2PairUri>) {
        pairUriLocalCache.put(uri)
    }

    override suspend fun getCachedPairUris(): List<CacheResult<WalletConnectV2PairUri>> {
        return pairUriLocalCache.cacheMapFlow.value.values.toList()
    }

    override suspend fun deleteCachedPairUri(uri: WalletConnectV2PairUri) {
        pairUriLocalCache.remove(uri.pairingTopic)
    }
}
