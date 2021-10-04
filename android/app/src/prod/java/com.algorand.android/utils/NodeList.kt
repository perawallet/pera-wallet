package com.algorand.android.utils

import com.algorand.android.BuildConfig
import com.algorand.android.models.Node

const val CURRENT_DEFAULT_NODE_LIST_VERSION = 14

val defaultNodeList = listOf(
    Node(
        name = "MainNet",
        algodAddress = "https://node-mainnet.aws.algodev.network/",
        algodApiKey = BuildConfig.ALGORAND_API_KEY,
        indexerAddress = "https://indexer-mainnet.aws.algodev.network/",
        indexerApiKey = BuildConfig.INDEXER_API_KEY,
        isActive = true,
        isAddedDefault = true,
        networkSlug = MAINNET_NETWORK_SLUG
    ),
    Node(
        name = "TestNet",
        algodAddress = "https://node-testnet.aws.algodev.network/",
        algodApiKey = BuildConfig.ALGORAND_API_KEY,
        indexerAddress = "https://indexer-testnet.aws.algodev.network/",
        indexerApiKey = BuildConfig.INDEXER_API_KEY,
        isActive = false,
        isAddedDefault = true,
        networkSlug = TESTNET_NETWORK_SLUG
    )
)
