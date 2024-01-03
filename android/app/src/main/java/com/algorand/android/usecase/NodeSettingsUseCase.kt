/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.models.Node
import com.algorand.android.modules.firebase.token.FirebaseTokenManager
import com.algorand.android.modules.firebase.token.model.FirebaseTokenResult
import com.algorand.android.repository.NodeRepository
import com.algorand.android.ui.settings.node.ui.mapper.NodeSettingsPreviewMapper
import com.algorand.android.ui.settings.node.ui.model.NodeSettingsPreview
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import com.algorand.android.utils.defaultNodeList
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class NodeSettingsUseCase @Inject constructor(
    private val nodeRepository: NodeRepository,
    private val firebaseTokenManager: FirebaseTokenManager,
    private val nodeSettingsPreviewMapper: NodeSettingsPreviewMapper
) {

    fun getNodeSettingsPreviewFlow(): Flow<NodeSettingsPreview?> {
        return combine(
            nodeRepository.getAllNodesAsFlow(),
            firebaseTokenManager.firebaseTokenResultFlow
        ) { nodeList, firebaseTokenResult ->
            nodeSettingsPreviewMapper.mapToNodeSettingsPreview(
                isLoading = firebaseTokenResult is FirebaseTokenResult.TokenLoading,
                nodeList = nodeList
            )
        }
    }

    suspend fun setNodeListToDatabase(nodeList: List<Node>) {
        nodeRepository.setNodeListToDatabase(nodeList)
    }

    fun getAllNodeAsFlow(): Flow<List<Node>> {
        return nodeRepository.getAllNodesAsFlow()
    }

    suspend fun isSelectedNodeTestnet(): Boolean {
        return getActiveNodeOrDefault().networkSlug == TESTNET_NETWORK_SLUG
    }

    suspend fun setSelectedNode(selectedItem: Node): List<Node> {
        return nodeRepository.getAllNodes().apply {
            forEach { it.isActive = false }
            firstOrNull { it.nodeDatabaseId == selectedItem.nodeDatabaseId }?.apply { isActive = true }
        }
    }

    suspend fun getActiveNodeOrDefault(): Node {
        return nodeRepository.getAllNodes().firstOrNull { it.isActive } ?: defaultNodeList.first()
    }
}
