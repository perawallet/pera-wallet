/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.utils

import android.content.SharedPreferences
import com.algorand.android.database.NodeDao
import com.algorand.android.models.Node
import com.algorand.android.utils.preference.getDefaultNodeListVersion
import com.algorand.android.utils.preference.setNodeListVersion

const val TESTNET_NETWORK_SLUG = "testnet"
const val BETANET_NETWORK_SLUG = "betanet"
const val MAINNET_NETWORK_SLUG = "mainnet"

suspend fun findAllNodes(
    sharedPref: SharedPreferences,
    nodeDao: NodeDao
): List<Node> {
    val allNodesAvailable = nodeDao.getAll()
    val currentVersion = sharedPref.getDefaultNodeListVersion()
    return if (currentVersion < CURRENT_DEFAULT_NODE_LIST_VERSION || allNodesAvailable.isEmpty()) {
        initNewDefaultListWithCustomNodes(sharedPref, CURRENT_DEFAULT_NODE_LIST_VERSION, defaultNodeList, nodeDao)
    } else {
        allNodesAvailable
    }
}

private suspend fun initNewDefaultListWithCustomNodes(
    sharedPreferences: SharedPreferences,
    version: Int,
    newDefaultNodeList: List<Node>,
    nodeDao: NodeDao
): List<Node> {
    sharedPreferences.setNodeListVersion(version)
    val allAvailableHealthyNodes = mutableListOf<Node>()
    allAvailableHealthyNodes.addAll(newDefaultNodeList)
    nodeDao.deleteAllThenInsertNodes(allAvailableHealthyNodes)
    return allAvailableHealthyNodes
}
