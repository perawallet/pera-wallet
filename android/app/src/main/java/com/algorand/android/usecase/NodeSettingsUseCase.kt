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
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.network.MobileHeaderInterceptor
import com.algorand.android.repository.NodeRepository
import com.algorand.android.utils.defaultNodeList
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow

class NodeSettingsUseCase @Inject constructor(
    private val mobileHeaderInterceptor: MobileHeaderInterceptor,
    private val indexerInterceptor: IndexerInterceptor,
    private val algodInterceptor: AlgodInterceptor,
    private val nodeRepository: NodeRepository
) {

    suspend fun setNodeListToDatabase(nodeList: List<Node>) {
        nodeRepository.setNodeListToDatabase(nodeList)
    }

    fun getAllNodeAsFlow(): Flow<List<Node>> {
        return nodeRepository.getAllNodesAsFlow()
    }

    fun setSelectedNode(nodeList: List<Node>?, selectedItem: Node): List<Node> {
        return nodeList?.apply {
            forEach { it.isActive = false }
            firstOrNull { it.nodeDatabaseId == selectedItem.nodeDatabaseId }?.apply { isActive = true }
        }.orEmpty()
    }

    suspend fun getActiveNodeOrDefault(): Node {
        return nodeRepository.getAllNodes().firstOrNull { it.isActive } ?: defaultNodeList.first()
    }

    fun activateNewNode(newNode: Node) {
        newNode.activate(
            indexerInterceptor,
            mobileHeaderInterceptor,
            algodInterceptor
        )
    }
}
