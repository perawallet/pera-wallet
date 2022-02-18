package com.algorand.android.utils

import com.algorand.android.BuildConfig
import com.algorand.android.models.Node

const val CURRENT_DEFAULT_NODE_LIST_VERSION = 16

val defaultNodeList = listOf(
    Node(
        name = "MainNet",
        algodAddress = "https://node-mainnet.chain.perawallet.app/",
        algodApiKey = BuildConfig.ALGORAND_API_KEY,
        indexerAddress = "https://indexer-mainnet.chain.perawallet.app/",
        indexerApiKey = BuildConfig.INDEXER_API_KEY,
        isActive = true,
        isAddedDefault = true,
        networkSlug = MAINNET_NETWORK_SLUG,
        mobileAlgorandAddress = "https://api.perawallet.app/v1/"
    ),
    Node(
        name = "TestNet",
        algodAddress = "https://node-testnet.chain.perawallet.app/",
        algodApiKey = BuildConfig.ALGORAND_API_KEY,
        indexerAddress = "https://indexer-testnet.chain.perawallet.app/",
        indexerApiKey = BuildConfig.INDEXER_API_KEY,
        isActive = false,
        isAddedDefault = true,
        networkSlug = TESTNET_NETWORK_SLUG,
        mobileAlgorandAddress = "https://api.perawallet.app/v1/"
    )
)
