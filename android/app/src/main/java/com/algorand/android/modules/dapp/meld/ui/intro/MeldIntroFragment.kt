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

package com.algorand.android.modules.dapp.meld.ui.intro

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentMeldIntroBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.dapp.meld.ui.accountselection.MeldAccountSelectionFragment
import com.algorand.android.utils.browser.openExternalBrowserApp
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MeldIntroFragment : BaseFragment(R.layout.fragment_meld_intro) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.buy_algo_with_meld,
        startIconResId = R.drawable.ic_close,
        backgroundColor = R.color.meld,
        titleColor = R.color.white,
        startIconColor = R.color.white,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val args by navArgs<MeldIntroFragmentArgs>()
    private val meldIntroViewModel by viewModels<MeldIntroViewModel>()
    private val binding by viewBinding(FragmentMeldIntroBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.meld)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initSavedStateListener()
    }

    private fun initUi() {
        changeStatusBarConfiguration(statusBarConfiguration)
        binding.buyAlgoButton.setOnClickListener { onBuyAlgoButtonClick() }
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.meldIntroFragment) {
            useSavedStateValue<String?>(MeldAccountSelectionFragment.ACCOUNT_SELECTION_RESULT_KEY) {
                navToMeld(it)
            }
        }
    }

    private fun onBuyAlgoButtonClick() {
        meldIntroViewModel.logBuyAlgoTapEvent()
        if (meldIntroViewModel.isMainNet().not()) {
            showGlobalError(getString(R.string.you_can_not_purchase), getString(R.string.not_available))
            return
        }
        if (args.walletAddress == null) {
            navToAccountSelectionFragment()
        } else {
            navToMeld(args.walletAddress)
        }
    }

    private fun navToMeld(publicKey: String?) {
        if (publicKey != null) {
            context?.openExternalBrowserApp(meldIntroViewModel.getMeldUrl(publicKey))
        }
    }

    private fun navToAccountSelectionFragment() {
        nav(MeldIntroFragmentDirections.actionMeldIntroFragmentToMeldAccountSelectionFragment())
    }
}
