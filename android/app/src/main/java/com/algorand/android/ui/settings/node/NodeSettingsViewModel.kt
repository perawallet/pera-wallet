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

package com.algorand.android.ui.settings.node

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.NodeDao
import com.algorand.android.models.Node
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.network.MobileHeaderInterceptor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class NodeSettingsViewModel @ViewModelInject constructor(
    private val mobileHeaderInterceptor: MobileHeaderInterceptor,
    private val indexerInterceptor: IndexerInterceptor,
    private val algodInterceptor: AlgodInterceptor,
    private val nodeDao: NodeDao
) : BaseViewModel() {

    val nodeListLiveData = MutableLiveData<List<Node>>()

    fun getNodeList() {
        viewModelScope.launch(Dispatchers.IO) {
            val nodeList = nodeDao.getAll()
            withContext(Dispatchers.Main) {
                nodeListLiveData.value = nodeList
            }
        }
    }

    fun setNodeListToDatabase(nodeList: List<Node>) {
        viewModelScope.launch(Dispatchers.IO) {
            nodeDao.updateNodes(nodeList)
        }
    }

    fun activateNode(node: Node) {
        node.activate(indexerInterceptor, mobileHeaderInterceptor, algodInterceptor)
    }
}
