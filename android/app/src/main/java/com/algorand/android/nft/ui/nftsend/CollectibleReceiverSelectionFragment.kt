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

package com.algorand.android.nft.ui.nftsend

import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.QrScanner
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.model.CollectibleReceiverSelectionPreview
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class CollectibleReceiverSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close,
        titleResId = R.string.select_account
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val collectibleReceiverSelectionViewModel by viewModels<CollectibleReceiverSelectionViewModel>()

    private val collectibleReceiverSelectionPreviewCollector: suspend (CollectibleReceiverSelectionPreview?) -> Unit = {
        accountAdapter.submitList(it?.accountSelectionItems)
    }

    override val isSearchBarVisible: Boolean = true

    override val onSearchBarCustomButtonClickListener: () -> Unit = {
        nav(
            CollectibleReceiverSelectionFragmentDirections
                .actionCollectibleReceiverSelectionFragmentToQrCodeScannerNavigation(
                    qrScanner = QrScanner(
                        scanTypes = arrayOf(QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK),
                        titleRes = R.string.scan_an_algorand
                    )
                )
        )
    }

    override val onSearchBarTextChangeListener: (String) -> Unit = {
        super.onSearchBarTextChangeListener.invoke(it)
        collectibleReceiverSelectionViewModel.updateSearchingQuery(it)
    }

    override fun onAccountSelected(publicKey: String) {
        setNavigationResult(ACCOUNT_PUBLIC_KEY_KEY, publicKey)
        navBack()
    }

    override fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            collectibleReceiverSelectionViewModel.collectibleReceiverSelectionPreviewFlow.collectLatest(
                collectibleReceiverSelectionPreviewCollector
            )
        }
    }

    override fun onCopiedItemHandled(copiedMessage: String?) {
        collectibleReceiverSelectionViewModel.updateLatestCopiedMessage(copiedMessage)
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListeners()
    }

    private fun initSavedStateListeners() {
        startSavedStateListener(R.id.collectibleReceiverSelectionFragment) {
            useSavedStateValue<DecodedQrCode>(QrCodeScannerFragment.QR_SCAN_RESULT_KEY) { decodedQrCode ->
                if (!decodedQrCode.address.isNullOrBlank()) {
                    updateSearchBarText(decodedQrCode.address)
                }
            }
        }
    }

    companion object {
        const val ACCOUNT_PUBLIC_KEY_KEY = "account_public_key"
    }
}
