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

package com.algorand.android.modules.webimport.result.ui

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentWebImportResultBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.webimport.result.ui.adapter.WebImportResultAdapter
import com.algorand.android.modules.webimport.result.ui.model.WebImportResultPreview
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WebImportResultFragment : BaseFragment(R.layout.fragment_web_import_result) {
    override val fragmentConfiguration = FragmentConfiguration()

    private val webImportResultViewModel: WebImportResultViewModel by viewModels()

    private val binding by viewBinding(FragmentWebImportResultBinding::bind)

    private val webImportResultAdapter: WebImportResultAdapter =
        WebImportResultAdapter()

    private val webImportResultPreviewCollector:
        suspend (preview: WebImportResultPreview?) -> Unit = { preview ->
        preview?.let {
            webImportResultAdapter.submitList(it.listItems)
            binding.firstButton.text = getString(it.buttonTextRes)
        }
    }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            nav(WebImportResultFragmentDirections.actionWebImportResultFragmentToHomeNavigation())
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            accountListRecyclerview.adapter = webImportResultAdapter
            firstButton.setOnClickListener {
                nav(WebImportResultFragmentDirections.actionWebImportResultFragmentToHomeNavigation())
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            webImportResultViewModel.webImportResultPreviewFlow,
            webImportResultPreviewCollector
        )
    }
}
