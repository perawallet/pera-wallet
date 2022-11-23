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

package com.algorand.android.modules.swap.accountselection.ui

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.swap.accountselection.ui.model.SwapAccountSelectionPreview
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledString
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class SwapAccountSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val swapAccountSelectionViewModel by viewModels<SwapAccountSelectionViewModel>()

    private val swapAccountSelectionPreviewCollector: suspend (SwapAccountSelectionPreview) -> Unit = { preview ->
        updateSwapAccountSelectionPreview(preview)
    }

    private val navToSwapNavigationEventCollector: suspend (Event<String>?) -> Unit = { navigationEvent ->
        navigationEvent?.consume()?.run {
            nav(SwapAccountSelectionFragmentDirections.actionSwapAccountSelectionFragmentToSwapNavigation(this))
        }
    }

    private val errorEventCollector: suspend (Event<AnnotatedString>?) -> Unit = { errorEvent ->
        errorEvent?.consume()?.run {
            val error = context?.getXmlStyledString(this)
            showGlobalError(error)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setScreenStateView(ScreenState.CustomState(title = R.string.no_account_found))
    }

    override fun setTitleTextView(textView: TextView) {
        textView.apply {
            setText(R.string.select_account)
            show()
        }
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.apply {
            setText(R.string.select_an_account_to_make)
            show()
        }
    }

    override fun onAccountSelected(publicKey: String) {
        swapAccountSelectionViewModel.onAccountSelected(publicKey)
    }

    override fun initObservers() {
        with(swapAccountSelectionViewModel) {
            viewLifecycleOwner.collectLatestOnLifecycle(
                swapAccountSelectionPreviewFlow,
                swapAccountSelectionPreviewCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                swapAccountSelectionPreviewFlow.map { it.navToSwapNavigationEvent }.distinctUntilChanged(),
                navToSwapNavigationEventCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                swapAccountSelectionPreviewFlow.map { it.errorEvent }.distinctUntilChanged(),
                errorEventCollector
            )
        }
    }

    private fun updateSwapAccountSelectionPreview(preview: SwapAccountSelectionPreview) {
        with(preview) {
            if (isLoading) showProgress() else hideProgress()
            accountAdapter.submitList(accountListItems)
            setScreenStateViewVisibility(isEmptyStateVisible)
        }
    }
}
