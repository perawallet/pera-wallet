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

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentNodeSettingsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.Node
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.settings.node.ui.model.NodeSettingsPreview
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class NodeSettingsFragment : DaggerBaseFragment(R.layout.fragment_node_settings) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.node_settings,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    private val nodeSettingsPreviewCollector: suspend (value: NodeSettingsPreview?) -> Unit = { preview ->
        if (preview != null) initPreview(preview)
    }

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val nodeSettingsViewModel: NodeSettingsViewModel by viewModels()

    private val binding by viewBinding(FragmentNodeSettingsBinding::bind)

    private var nodeAdapter = NodeAdapter(::onDifferentNodeSelected)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        initObserver()
    }

    private fun initObserver() {
        collectLatestOnLifecycle(
            flow = nodeSettingsViewModel.nodeSettingsFlow,
            collection = nodeSettingsPreviewCollector
        )
    }

    private fun initPreview(nodeSettingsPreview: NodeSettingsPreview) {
        with(nodeSettingsPreview) {
            // TODO: block user back-press event while isLoading is true instead of displaying loading bar.
            binding.loadingLayout.root.isVisible = isLoading
            nodeAdapter.setNewList(nodeList)
        }
    }

    private fun setupRecyclerView() {
        binding.nodeRecyclerView.adapter = nodeAdapter
    }

    private fun onDifferentNodeSelected(activatedNode: Node) {
        nodeSettingsViewModel.onNodeChanged(activatedNode = activatedNode)
    }
}
