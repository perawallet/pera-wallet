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

package com.algorand.android.ui.settings.node

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.banner.domain.usecase.BannersUseCase
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Node
import com.algorand.android.usecase.CoreCacheUseCase
import com.algorand.android.usecase.NodeSettingsUseCase
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class NodeSettingsViewModel @ViewModelInject constructor(
    private val coreCacheUseCase: CoreCacheUseCase,
    private val nodeSettingsUseCase: NodeSettingsUseCase,
    private val bannersUseCase: BannersUseCase
) : BaseViewModel() {

    private val _nodeListLiveData = MutableLiveData<List<Node>>()
    val nodeListLiveData: LiveData<List<Node>> = _nodeListLiveData

    init {
        viewModelScope.launch {
            nodeSettingsUseCase.getAllNodeAsFlow().collectLatest {
                _nodeListLiveData.postValue(it)
            }
        }
    }

    private suspend fun setNodeListToDatabase(nodeList: List<Node>) {
        viewModelScope.launch {
            nodeSettingsUseCase.setNodeListToDatabase(nodeList)
        }
    }

    private fun activateNode(node: Node) {
        nodeSettingsUseCase.activateNewNode(node)
    }

    fun onNodeChanged(activatedNode: Node, onNodeSwitchingFinished: (previousNode: Node) -> Unit) {
        viewModelScope.launch {
            val previousSelectedNode = nodeSettingsUseCase.getActiveNodeOrDefault()
            nodeSettingsUseCase.setSelectedNode(_nodeListLiveData.value, activatedNode).apply {
                coreCacheUseCase.handleNodeChange()
                activateNode(activatedNode)
                setNodeListToDatabase(this)
                onNodeSwitchingFinished.invoke(previousSelectedNode)
            }
        }
    }
}
