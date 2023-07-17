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

package com.algorand.android.modules.walletconnect.client.v2.data.di

import android.content.Context
import androidx.room.Room
import com.algorand.android.modules.walletconnect.client.v2.data.cache.WalletConnectV2PairUriLocalCache
import com.algorand.android.modules.walletconnect.client.v2.data.db.WalletConnectV2ClientDatabase
import com.algorand.android.modules.walletconnect.client.v2.data.db.WalletConnectV2ClientDatabase.Companion.DATABASE_NAME
import com.algorand.android.modules.walletconnect.client.v2.data.db.WalletConnectV2Dao
import com.algorand.android.modules.walletconnect.client.v2.data.mapper.WalletConnectSessionDtoMapper
import com.algorand.android.modules.walletconnect.client.v2.data.mapper.WalletConnectSessionEntityMapper
import com.algorand.android.modules.walletconnect.client.v2.data.repository.WalletConnectV2RepositoryImpl
import com.algorand.android.modules.walletconnect.client.v2.domain.repository.WalletConnectV2Repository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV2RepositoryModule {

    @Singleton
    @Provides
    fun provideDatabase(@ApplicationContext appContext: Context): WalletConnectV2ClientDatabase {
        return Room
            .databaseBuilder(appContext, WalletConnectV2ClientDatabase::class.java, DATABASE_NAME)
            .fallbackToDestructiveMigration()
            .build()
    }

    @Singleton
    @Provides
    fun provideWalletConnectV2Dao(database: WalletConnectV2ClientDatabase): WalletConnectV2Dao {
        return database.getWalletConnectDao()
    }

    @Provides
    @Singleton
    @Named(WalletConnectV2Repository.INJECTION_NAME)
    fun provideWalletConnectRepository(
        walletConnectV2Dao: WalletConnectV2Dao,
        sessionDtoMapper: WalletConnectSessionDtoMapper,
        entityMapper: WalletConnectSessionEntityMapper,
        pairUriLocalCache: WalletConnectV2PairUriLocalCache
    ): WalletConnectV2Repository {
        return WalletConnectV2RepositoryImpl(
            walletConnectV2Dao = walletConnectV2Dao,
            sessionDtoMapper = sessionDtoMapper,
            sessionEntityMapper = entityMapper,
            pairUriLocalCache = pairUriLocalCache
        )
    }
}
