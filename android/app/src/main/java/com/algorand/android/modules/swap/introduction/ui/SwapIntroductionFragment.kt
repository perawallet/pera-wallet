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

package com.algorand.android.modules.swap.introduction.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.NavDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentSwapIntroductionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.openVestigeTermsOfServiceUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.setXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class SwapIntroductionFragment : BaseFragment(R.layout.fragment_swap_introduction) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val swapIntroductionViewModel by viewModels<SwapIntroductionViewModel>()

    private val binding by viewBinding(FragmentSwapIntroductionBinding::bind)

    private val navToSwapAccountSelectionFragmentEvent: suspend (Event<NavDirections>?) -> Unit = {
        it?.consume()?.let { navDirection -> nav(navDirection) }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            introductionTermsOfServiceTextView.setXmlStyledString(
                stringResId = R.string.by_continuing_you_agree_to,
                colorResId = R.color.link_primary,
                onUrlClick = ::onTermsOfServicesClick
            )
            introductionStartSwappingButton.setOnClickListener { swapIntroductionViewModel.onStartSwappingClick() }
            closeButton.setOnClickListener { navBack() }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            swapIntroductionViewModel.swapIntroductionPreviewFlow.map { it?.navigationDirectionEvent },
            navToSwapAccountSelectionFragmentEvent
        )
    }

    private fun onTermsOfServicesClick(url: String) {
        context?.openVestigeTermsOfServiceUrl()
    }
}
