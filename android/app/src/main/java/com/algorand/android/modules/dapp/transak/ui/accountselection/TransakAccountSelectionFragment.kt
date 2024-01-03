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

package com.algorand.android.modules.dapp.transak.ui.accountselection

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.AssetAction
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.optin.OptInAssetActionBottomSheet.Companion.OPT_IN_RESULT_SUCCESSFUL_KEY
import com.algorand.android.modules.dapp.transak.ui.accountselection.model.TransakAccountSelectionPreview
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class TransakAccountSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close,
        titleResId = R.string.buy_usdc_with_transak,
        titleColor = R.color.text_main
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val transakAccountSelectionPreviewCollector: suspend (TransakAccountSelectionPreview) -> Unit = { preview ->
        with(preview) {
            optInToAssetEvent?.consume()?.run {
                handleAssetAddition(this)
            }
            finalizeAccountSelectionEvent?.consume()?.run {
                nav(this)
            }
        }
    }

    private val transakAccountSelectionViewModel by viewModels<TransakAccountSelectionViewModel>()

    private val accountItemsCollector: suspend (List<BaseAccountSelectionListItem>) -> Unit = { accountItems ->
        accountAdapter.submitList(accountItems)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initSavedStateListener()
    }

    override fun onAccountSelected(publicKey: String) {
        transakAccountSelectionViewModel.onAccountSelected(publicKey)
    }

    override fun setTitleTextView(textView: TextView) {
        textView.apply {
            setText(R.string.select_account)
            show()
        }
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.apply {
            setText(R.string.choose_an_account_to_proceed)
            show()
        }
    }

    override fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            transakAccountSelectionViewModel.accountItemsFlow,
            accountItemsCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            transakAccountSelectionViewModel.transakAccountSelectionPreviewFlow,
            transakAccountSelectionPreviewCollector
        )
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.transakAccountSelectionFragment) {
            useSavedStateValue<Pair<Boolean, String>>(OPT_IN_RESULT_SUCCESSFUL_KEY) {
                    (optInResultSuccessful, accountAddress) ->
                if (optInResultSuccessful) {
                    transakAccountSelectionViewModel.onAssetOptedIn(accountAddress)
                }
            }
        }
    }

    private fun handleAssetAddition(assetAction: AssetAction) {
        nav(
            TransakAccountSelectionFragmentDirections
                .actionTransakAccountSelectionFragmentToAssetOptInActionNavigation(
                    assetAction = assetAction,
                    shouldWaitForConfirmation = true
                )
        )
    }
}
