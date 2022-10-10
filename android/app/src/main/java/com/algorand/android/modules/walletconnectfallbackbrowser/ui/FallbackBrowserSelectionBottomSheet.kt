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

package com.algorand.android.modules.walletconnectfallbackbrowser.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetFallbackBrowserSelectionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.adapter.FallbackBrowserItemAdapter
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserListItem
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserSelectionPreview
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.startActivityWithPackageNameIfPossible
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class FallbackBrowserSelectionBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_fallback_browser_selection) {

    private val args: FallbackBrowserSelectionBottomSheetArgs by navArgs()

    private val binding by viewBinding(BottomSheetFallbackBrowserSelectionBinding::bind)

    private val fallbackBrowserSelectionViewModel: FallbackBrowserSelectionViewModel by viewModels()

    private val fallbackBrowserSelectionPreviewCollector: suspend (FallbackBrowserSelectionPreview) -> Unit = {
        updateUiWithPreview(it)
    }

    private val fallbackBrowserListAdapterListener = FallbackBrowserItemAdapter.Listener { browserListItem ->
        if (context?.startActivityWithPackageNameIfPossible(browserListItem.packageName) == true) {
            dismissAllowingStateLoss()
        } else {
            onNoBrowserFound()
        }
    }

    private val fallbackBrowserListAdapter = FallbackBrowserItemAdapter(fallbackBrowserListAdapterListener)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        updatePreviewWithBrowserList()
    }

    private fun initUi() {
        with(binding) {
            customToolbar.apply {
                changeTitle(R.string.select_a_browser)
                configureStartButton(R.drawable.ic_close, ::onCloseButtonClicked)
            }
            browserRecyclerView.adapter = fallbackBrowserListAdapter
            descriptionTextView.text = getString(R.string.we_couldn_t, args.peerMetaName)
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            flow = fallbackBrowserSelectionViewModel.fallbackBrowserSelectionPreviewFlow,
            collection = fallbackBrowserSelectionPreviewCollector
        )
    }

    private fun updateUiWithPreview(preview: FallbackBrowserSelectionPreview) {
        with(preview) {
            fallbackBrowserListAdapter.submitList(fallbackBrowserList)
            noBrowserFoundEvent?.consume()?.let { onNoBrowserFound() }
            singleBrowserFoundEvent?.consume()?.let { onSingleBrowserFound(it) }
        }
    }

    private fun onNoBrowserFound() {
        showConnectedDappInfoBottomSheet(args.peerMetaName)
    }

    private fun showConnectedDappInfoBottomSheet(peerName: String) {
        nav(
            FallbackBrowserSelectionBottomSheetDirections
                .actionFallbackBrowserSelectionBottomSheetToSingleButtonBottomSheet(
                    titleAnnotatedString = AnnotatedString(
                        stringResId = R.string.you_are_connected,
                        replacementList = listOf("peer_name" to peerName)
                    ),
                    descriptionAnnotatedString = AnnotatedString(
                        stringResId = R.string.please_return_to,
                        replacementList = listOf("peer_name" to peerName)
                    ),
                    drawableResId = R.drawable.ic_check_72dp,
                    isResultNeeded = true
                )
        )
    }

    private fun onSingleBrowserFound(fallbackBrowserListItem: FallbackBrowserListItem) {
        nav(
            FallbackBrowserSelectionBottomSheetDirections
                .actionFallbackBrowserSelectionBottomSheetToWalletConnectConnectedSingleBrowserBottomSheet(
                    fallbackBrowserListItem,
                    args.peerMetaName
                )
        )
    }

    private fun updatePreviewWithBrowserList() {
        fallbackBrowserSelectionViewModel.updatePreviewWithBrowserList(context?.packageManager)
    }

    private fun onCloseButtonClicked() {
        dismissAllowingStateLoss()
    }
}
