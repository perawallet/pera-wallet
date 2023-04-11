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

package com.algorand.android.modules.dapp.sardine.ui.intro

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentSardineIntroBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.dapp.sardine.ui.intro.model.SardineIntroPreview
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SardineIntroFragment : BaseFragment(R.layout.fragment_sardine_intro) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.buy_algo_with_sardine,
        startIconResId = R.drawable.ic_close,
        backgroundColor = R.color.sardine,
        titleColor = R.color.white,
        startIconColor = R.color.white,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val sardineIntroViewModel by viewModels<SardineIntroViewModel>()
    private val binding by viewBinding(FragmentSardineIntroBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.sardine)

    private val sardineIntroPreviewCollector: suspend (SardineIntroPreview) -> Unit = { preview ->
        updateUiWithPreview(preview)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        changeStatusBarConfiguration(statusBarConfiguration)
        binding.buyAlgoWithSardineButton.setOnClickListener { onBuyAlgoButtonClicked() }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectOnLifecycle(
            sardineIntroViewModel.sardineIntroPreviewFlow,
            sardineIntroPreviewCollector,
        )
    }

    private fun updateUiWithPreview(preview: SardineIntroPreview) {
        with(preview) {
            navigateEvent?.consume()?.let {
                nav(it)
            }

            showNotAvailableErrorEvent?.consume()?.let {
                showNotAvailableError()
            }
        }
    }

    private fun onBuyAlgoButtonClicked() {
        sardineIntroViewModel.onBuyAlgoButtonClicked()
    }

    private fun showNotAvailableError() {
        showGlobalError(getString(R.string.you_can_not_purchase_sardine), getString(R.string.not_available))
    }
}
