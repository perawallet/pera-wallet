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

package com.algorand.android.modules.dapp.transak.ui.intro

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentTransakIntroBinding
import com.algorand.android.models.AssetAction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.optin.OptInAssetActionBottomSheet.Companion.OPT_IN_RESULT_SUCCESSFUL_KEY
import com.algorand.android.modules.dapp.transak.ui.intro.model.TransakIntroPreview
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class TransakIntroFragment : BaseFragment(R.layout.fragment_transak_intro) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.buy_usdc_with_transak,
        startIconResId = R.drawable.ic_close,
        backgroundColor = R.color.transak,
        titleColor = R.color.white,
        startIconColor = R.color.white,
        startIconClick = ::navBack,
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val transakIntroViewModel by viewModels<TransakIntroViewModel>()
    private val binding by viewBinding(FragmentTransakIntroBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.transak)

    private val transakIntroPreviewCollector: suspend (TransakIntroPreview) -> Unit = { preview ->
        updateUiWithPreview(preview)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        initSavedStateListener()
    }

    private fun initUi() {
        changeStatusBarConfiguration(statusBarConfiguration)
        binding.buyUSDCWithTransakButton.setOnClickListener { onBuyUSDCButtonClick() }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectOnLifecycle(
            transakIntroViewModel.transakIntroPreviewFlow,
            transakIntroPreviewCollector,
        )
    }

    private fun onBuyUSDCButtonClick() {
        transakIntroViewModel.onBuyUSDCButtonClick()
    }

    private fun updateUiWithPreview(preview: TransakIntroPreview) {
        with(preview) {
            navigateEvent?.consume()?.let {
                nav(it)
            }
            optInToAssetEvent?.consume()?.run {
                handleAssetAddition(this)
            }
            showNotAvailableErrorEvent?.consume()?.let {
                showNotAvailableError()
            }
        }
    }

    private fun showNotAvailableError() {
        showGlobalError(getString(R.string.you_can_not_purchase_transak), getString(R.string.not_available))
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.transakIntroFragment) {
            useSavedStateValue<Pair<Boolean, String>>(OPT_IN_RESULT_SUCCESSFUL_KEY) {
                    (optInResultSuccessful, accountAddress) ->
                if (optInResultSuccessful) {
                    transakIntroViewModel.onAssetOptedIn(accountAddress)
                }
            }
        }
    }

    private fun handleAssetAddition(assetAction: AssetAction) {
        nav(
            TransakIntroFragmentDirections
                .actionTransakIntroFragmentToAssetOptInActionNavigation(
                    assetAction = assetAction,
                    shouldWaitForConfirmation = true,
                ),
        )
    }
}
