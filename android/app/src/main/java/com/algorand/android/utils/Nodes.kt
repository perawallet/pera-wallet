/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.utils

import com.algorand.android.BuildConfig
import com.algorand.android.models.Node

const val CURRENT_DEFAULT_NODE_LIST_VERSION = 28

const val MAINNET_NODE_NAME = "Algorand MainNet Node"
const val TESTNET_NODE_NAME = "TestNet"

val mainNetNode = Node(
    name = MAINNET_NODE_NAME,
    algodAddress = "https://node-mainnet.chain.perawallet.app/",
    algodApiKey = BuildConfig.ALGORAND_API_KEY,
    indexerAddress = "https://indexer-mainnet.chain.perawallet.app/",
    indexerApiKey = BuildConfig.INDEXER_API_KEY,
    isActive = false,
    isAddedDefault = true,
    networkSlug = MAINNET_NETWORK_SLUG,
    mobileAlgorandAddress = BuildConfig.MOBILE_ALGORAND_MAINNET_BASE_URL
)

val testNetNode = Node(
    name = TESTNET_NODE_NAME,
    algodAddress = "https://node-testnet.chain.perawallet.app/",
    algodApiKey = BuildConfig.ALGORAND_API_KEY,
    indexerAddress = "https://indexer-testnet.chain.perawallet.app/",
    indexerApiKey = BuildConfig.INDEXER_API_KEY,
    isActive = false,
    isAddedDefault = true,
    networkSlug = TESTNET_NETWORK_SLUG,
    mobileAlgorandAddress = BuildConfig.MOBILE_ALGORAND_TESTNET_BASE_URL
)
