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

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Node
import com.algorand.android.modules.firebase.token.FirebaseTokenManager
import com.algorand.android.ui.settings.node.ui.model.NodeSettingsPreview
import com.algorand.android.usecase.NodeSettingsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class NodeSettingsViewModel @Inject constructor(
    private val nodeSettingsUseCase: NodeSettingsUseCase,
    private val firebaseTokenManager: FirebaseTokenManager
) : BaseViewModel() {

    private val _nodeSettingsFlow = MutableStateFlow<NodeSettingsPreview?>(null)
    val nodeSettingsFlow: StateFlow<NodeSettingsPreview?> get() = _nodeSettingsFlow

    init {
        initNodeSettingsPreview()
    }

    private fun initNodeSettingsPreview() {
        viewModelScope.launch(Dispatchers.IO) {
            nodeSettingsUseCase.getNodeSettingsPreviewFlow().collect {
                _nodeSettingsFlow.value = it
            }
        }
    }

    fun onNodeChanged(activatedNode: Node) {
        viewModelScope.launch(Dispatchers.IO) {
            val previousSelectedNode = nodeSettingsUseCase.getActiveNodeOrDefault()
            val updatedNodeList = nodeSettingsUseCase.setSelectedNode(activatedNode)
            nodeSettingsUseCase.setNodeListToDatabase(updatedNodeList)
            firebaseTokenManager.refreshFirebasePushToken(previousSelectedNode)
        }
    }
}
