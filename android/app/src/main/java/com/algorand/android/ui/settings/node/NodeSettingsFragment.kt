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

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentNodeSettingsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.Node
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class NodeSettingsFragment : DaggerBaseFragment(R.layout.fragment_node_settings) {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val nodeListObserver = Observer<List<Node>> { nodeList ->
        nodeAdapter?.setNodeList(nodeList)
    }

    // </editor-fold>

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.node_settings,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val nodeSettingsViewModel: NodeSettingsViewModel by viewModels()

    private val binding by viewBinding(FragmentNodeSettingsBinding::bind)

    private var nodeAdapter: NodeAdapter? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        initObserver()
        nodeSettingsViewModel.getNodeList()
    }

    private fun initObserver() {
        nodeSettingsViewModel.nodeListLiveData.observe(viewLifecycleOwner, nodeListObserver)
    }

    private fun setupRecyclerView() {
        nodeAdapter = NodeAdapter(::onListChanged)
        binding.nodeRecyclerView.adapter = nodeAdapter
    }

    private fun onListChanged(activatedNode: Node, newNodeList: List<Node>) {
        accountCacheManager.removeCachedData()
        nodeSettingsViewModel.activateNode(activatedNode)
        nodeSettingsViewModel.setNodeListToDatabase(newNodeList)
        (activity as? MainActivity)?.onNewNodeActivated(activatedNode)
    }
}
