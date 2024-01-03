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

package com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper

import javax.inject.Inject

class WalletConnectV2ClientWalletDelegateMapperFacade @Inject constructor(
    private val sessionDeleteMapper: WalletConnectSessionDeleteMapper,
    private val sessionProposalMapper: WalletConnectSessionProposalMapper,
    private val sessionUpdateMapper: WalletConnectSessionUpdateMapper,
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
    private val sessionRequestMapper: WalletConnectSessionRequestMapper,
    private val sessionSettleSuccessMapper: WalletConnectSessionSettleSuccessMapper,
    private val sessionSettleErrorMapper: WalletConnectSessionSettleErrorMapper,
    private val errorMapper: WalletConnectErrorMapper
) : WalletConnectSessionDeleteMapper by sessionDeleteMapper,
    WalletConnectSessionProposalMapper by sessionProposalMapper,
    WalletConnectSessionUpdateMapper by sessionUpdateMapper,
    WalletConnectPeerMetaMapper by peerMetaMapper,
    WalletConnectSessionRequestMapper by sessionRequestMapper,
    WalletConnectSessionSettleSuccessMapper by sessionSettleSuccessMapper,
    WalletConnectSessionSettleErrorMapper by sessionSettleErrorMapper,
    WalletConnectErrorMapper by errorMapper
