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

package com.algorand.android.modules.registration.watchaccount.ui

import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentRegisterWatchAccountBinding
import com.algorand.android.models.AccountCreation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.registration.watchaccount.ui.adapter.PasteableWatchAccountAdapter
import com.algorand.android.modules.registration.watchaccount.ui.model.BasePasteableWatchAccountItem
import com.algorand.android.ui.register.watch.RegisterWatchAccountQrScannerFragment.Companion.ACCOUNT_ADDRESS_SCAN_RESULT_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getTextFromClipboard
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RegisterWatchAccountFragment : DaggerBaseFragment(R.layout.fragment_register_watch_account) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackClick
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val windowFocusChangeListener = ViewTreeObserver.OnWindowFocusChangeListener { hasFocus ->
        if (hasFocus) getLatestCopiedMessage()
    }

    private val registerWatchAccountViewModel: RegisterWatchAccountViewModel by viewModels()

    private val binding by viewBinding(FragmentRegisterWatchAccountBinding::bind)

    private val pasteableWatchAccountAdapterListener = object : PasteableWatchAccountAdapter.Listener {

        override fun onAccountAddressClick(accountAddress: String) {
            registerWatchAccountViewModel.onAccountSelected(accountAddress)
            binding.addressCustomInputLayout.text = accountAddress
        }

        override fun onNfDomainClick(nfDomainName: String, nfDomainAddress: String) {
            registerWatchAccountViewModel.onNfDomainSelected(nfDomainName, nfDomainAddress)
            binding.addressCustomInputLayout.text = nfDomainAddress
        }
    }

    private val pasteableWatchAccountAdapter = PasteableWatchAccountAdapter(pasteableWatchAccountAdapterListener)

    private val pasteableAccountsCollector: suspend (List<BasePasteableWatchAccountItem>?) -> Unit = {
        pasteableWatchAccountAdapter.submitList(it)
    }

    private val errorMessageResIdCollector: suspend (Int?) -> Unit = {
        binding.addressCustomInputLayout.error = if (it != null) getString(it) else null
    }

    private val isActionButtonEnabledCollector: suspend (Boolean?) -> Unit = {
        binding.confirmationButton.isEnabled = it == true
    }

    private val showAccountIsNotValidErrorEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run {
            context?.showAlertDialog(
                title = getString(R.string.error),
                message = getString(R.string.entered_address_is_not_valid)
            )
        }
    }

    private val showAccountAlreadyExistErrorEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run {
            context?.showAlertDialog(
                title = getString(R.string.error),
                message = getString(R.string.this_account_already_exists)
            )
        }
    }

    private val navToNameRegistrationEventCollector: suspend (Event<AccountCreation>?) -> Unit = {
        it?.consume()?.run { navToNameRegistrationFragment(this) }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    override fun onStart() {
        super.onStart()
        initSavedStateListeners()
    }

    private fun initSavedStateListeners() {
        startSavedStateListener(R.id.registerWatchAccountFragment) {
            useSavedStateValue<String>(ACCOUNT_ADDRESS_SCAN_RESULT_KEY) { accountAddress ->
                binding.addressCustomInputLayout.text = accountAddress
                registerWatchAccountViewModel.onAccountSelected(accountAddress)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.addOnWindowFocusChangeListener(windowFocusChangeListener)
        }
        getLatestCopiedMessage()
    }

    private fun getLatestCopiedMessage() {
        val copiedMessage = context?.getTextFromClipboard().toString()
        registerWatchAccountViewModel.updateCopiedMessageFlow(copiedMessage)
    }

    override fun onPause() {
        super.onPause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.removeOnWindowFocusChangeListener(windowFocusChangeListener)
        }
    }

    private fun initUi() {
        with(binding) {
            pasteableItemList.adapter = pasteableWatchAccountAdapter
            addressCustomInputLayout.apply {
                text = registerWatchAccountViewModel.queriedAccountAddress
                setOnTextChangeListener(registerWatchAccountViewModel::updateQueryFlow)
                addTrailingIcon(R.drawable.ic_qr_scan, ::onScanQrClick)
                setRawInputTypeText()
                setImeOptionsDone { onNextClick() }
            }
            confirmationButton.setOnClickListener { onNextClick() }
        }
    }

    private fun initObservers() {
        with(registerWatchAccountViewModel.watchAccountRegistrationPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.pasteableAccounts }.distinctUntilChanged(),
                collection = pasteableAccountsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.errorMessageResId }.distinctUntilChanged(),
                collection = errorMessageResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isActionButtonEnabled }.distinctUntilChanged(),
                collection = isActionButtonEnabledCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.showAccountAlreadyExistErrorEvent }.distinctUntilChanged(),
                collection = showAccountAlreadyExistErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.showAccountIsNotValidErrorEvent }.distinctUntilChanged(),
                collection = showAccountIsNotValidErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navToNameRegistrationEvent }.distinctUntilChanged(),
                collection = navToNameRegistrationEventCollector
            )
        }
    }

    private fun onNextClick() {
        registerWatchAccountViewModel.onCreateAccountClick()
    }

    private fun navToNameRegistrationFragment(createdAccount: AccountCreation) {
        nav(
            RegisterWatchAccountFragmentDirections
                .actionRegisterWatchAccountFragmentToWatchAccountNameRegistrationFragment(createdAccount)
        )
    }

    private fun onScanQrClick() {
        view?.hideKeyboard()
        nav(
            RegisterWatchAccountFragmentDirections
                .actionRegisterWatchAccountInfoFragmentToRegisterWatchAccountQrScannerFragment()
        )
    }

    private fun onBackClick() {
        view?.hideKeyboard()
        navBack()
    }
}
