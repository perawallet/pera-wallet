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

package com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.di

import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2ProposalIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2RequestIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2SessionMetaMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectErrorMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectPeerMetaMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionDeleteMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionProposalMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionRequestMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionSettleErrorMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionSettleSuccessMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionUpdateMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectErrorMapperImpl
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectPeerMetaMapperImpl
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectSessionDeleteMapperImpl
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectSessionProposalMapperImpl
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectSessionRequestMapperImpl
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectSessionSettleErrorMapperImpl
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectSessionSettleSuccessMapperImpl
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl.WalletConnectSessionUpdateMapperImpl
import com.algorand.android.modules.walletconnect.mapper.WalletConnectExpiryMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDetailMapper
import com.google.gson.Gson
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectWalletDelegateMapperModule {

    @Provides
    @Singleton
    fun provideWalletConnectErrorMapper(): WalletConnectErrorMapper {
        return WalletConnectErrorMapperImpl()
    }

    @Provides
    @Singleton
    fun provideWalletConnectPeerMetaMapper(): WalletConnectPeerMetaMapper {
        return WalletConnectPeerMetaMapperImpl()
    }

    @Provides
    @Singleton
    fun provideWalletConnectSessionDeleteMapper(
        sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper
    ): WalletConnectSessionDeleteMapper {
        return WalletConnectSessionDeleteMapperImpl(
            sessionIdentifierMapper = sessionIdentifierMapper
        )
    }

    @Provides
    @Singleton
    fun provideWalletConnectSessionProposalMapper(
        peerMetaMapper: WalletConnectPeerMetaMapper,
        proposalIdentifierMapper: WalletConnectV2ProposalIdentifierMapper
    ): WalletConnectSessionProposalMapper {
        return WalletConnectSessionProposalMapperImpl(
            peerMetaMapper = peerMetaMapper,
            proposalIdentifierMapper = proposalIdentifierMapper
        )
    }

    @Provides
    @Singleton
    fun provideWalletConnectSessionRequestMapper(
        sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper,
        chainIdentifierDecider: WalletConnectV2ChainIdentifierDecider,
        requestIdentifierMapper: WalletConnectV2RequestIdentifierMapper,
        gson: Gson
    ): WalletConnectSessionRequestMapper {
        return WalletConnectSessionRequestMapperImpl(
            sessionIdentifierMapper = sessionIdentifierMapper,
            chainIdentifierDecider = chainIdentifierDecider,
            requestIdentifierMapper = requestIdentifierMapper,
            gson = gson
        )
    }

    @Provides
    @Singleton
    fun provideWalletConnectSessionSettleErrorMapper(
        sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper
    ): WalletConnectSessionSettleErrorMapper {
        return WalletConnectSessionSettleErrorMapperImpl(
            sessionIdentifierMapper = sessionIdentifierMapper
        )
    }

    @Provides
    @Singleton
    fun provideWalletConnectSessionSettleSuccessMapper(
        sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper,
        sessionDetailMapper: WalletConnectSessionDetailMapper,
        expiryMapper: WalletConnectExpiryMapper,
        sessionMetaMapper: WalletConnectV2SessionMetaMapper
    ): WalletConnectSessionSettleSuccessMapper {
        return WalletConnectSessionSettleSuccessMapperImpl(
            sessionIdentifierMapper = sessionIdentifierMapper,
            sessionDetailMapper = sessionDetailMapper,
            expiryMapper = expiryMapper,
            sessionMetaMapper = sessionMetaMapper
        )
    }

    @Provides
    @Singleton
    fun provideWalletConnectSessionUpdateMapper(
        sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper
    ): WalletConnectSessionUpdateMapper {
        return WalletConnectSessionUpdateMapperImpl(
            sessionIdentifierMapper = sessionIdentifierMapper
        )
    }
}
