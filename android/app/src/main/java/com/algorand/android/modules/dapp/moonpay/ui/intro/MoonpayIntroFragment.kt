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

package com.algorand.android.modules.dapp.moonpay.ui.intro

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentMoonpayIntroBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.dapp.moonpay.data.remote.model.SignMoonpayUrlResponse
import com.algorand.android.modules.dapp.moonpay.ui.accountselection.MoonpayAccountSelectionFragment
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest

@AndroidEntryPoint
class MoonpayIntroFragment : BaseFragment(R.layout.fragment_moonpay_intro) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.buy_algo_with,
        startIconResId = R.drawable.ic_close,
        backgroundColor = R.color.moonpayBgColor,
        titleColor = R.color.white,
        startIconColor = R.color.white,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val args by navArgs<MoonpayIntroFragmentArgs>()
    private val moonpayIntroViewModel by viewModels<MoonpayIntroViewModel>()
    private val binding by viewBinding(FragmentMoonpayIntroBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.moonpayBgColor)

    private val signMoonpayUrlResponseCollector: suspend (Event<Resource<SignMoonpayUrlResponse>>?) -> Unit = {
        it?.consume()?.use(
            onSuccess = {
                openSignedMoonpayUrl(it.moonpayUrl)
            },
            onFailed = { showGlobalError(it.parse(requireContext())) }
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initSavedStateListener()
        initObservers()
    }

    private fun initUi() {
        changeStatusBarConfiguration(statusBarConfiguration)
        binding.buyAlgoButton.setOnClickListener { onBuyAlgoButtonClick() }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            moonpayIntroViewModel.signMoonpayUrlFlow?.collectLatest {
                openSignedMoonpayUrl(it?.moonpayUrl)
            }
        }
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.moonpayIntroFragment) {
            useSavedStateValue<String?>(MoonpayAccountSelectionFragment.ACCOUNT_SELECTION_RESULT_KEY) {
                signMoonpayUrl(it)
            }
        }
    }

    private fun onBuyAlgoButtonClick() {
        if (moonpayIntroViewModel.isMainNet().not()) {
            showGlobalError(getString(R.string.you_can_not_purchase), getString(R.string.not_available))
            return
        }
        if (args.walletAddress == null) {
            navToAccountSelectionFragment()
        } else {
            signMoonpayUrl(args.walletAddress)
        }
    }

    private fun signMoonpayUrl(publicKey: String?) {
        if (publicKey != null) {
            moonpayIntroViewModel.signMoonpayUrl(publicKey)
        }
    }

    private fun navToAccountSelectionFragment() {
        nav(MoonpayIntroFragmentDirections.actionMoonpayIntroFragmentToMoonpayAccountSelectionFragment())
    }

    private fun openSignedMoonpayUrl(url: String?) {
        if (url != null) {
            navBack()
            context?.openUrl(url)
        }
    }
}
