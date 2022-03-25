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

package com.algorand.android.ui.register.watch

import android.os.Build
import android.os.Bundle
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.view.View
import android.view.ViewTreeObserver
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentRegisterWatchAccountBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCreation
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.QrScanner
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment.Companion.QR_SCAN_RESULT_KEY
import com.algorand.android.utils.analytics.CreationType.WATCH
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getTextFromClipboard
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class RegisterWatchAccountFragment : DaggerBaseFragment(R.layout.fragment_register_watch_account) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackClick
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val copiedMessageCollector: suspend (String?) -> Unit = { copiedMessage ->
        if (copiedMessage.isValidAddress().not()) {
            binding.pasteAddressButton.hide()
        } else {
            setupPasteButton(copiedMessage)
            binding.pasteAddressButton.show()
        }
    }

    private val windowFocusChangeListener = ViewTreeObserver.OnWindowFocusChangeListener { hasFocus ->
        if (hasFocus) getLatestCopiedMessage()
    }

    private val registerWatchAccountViewModel: RegisterWatchAccountViewModel by viewModels()

    private val binding by viewBinding(FragmentRegisterWatchAccountBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            addressCustomInputLayout.setOnTextChangeListener(::onAddressChanges)
            addressCustomInputLayout.setOnEndIconClickListener(::onScanQrClick)
            confirmationButton.setOnClickListener { onNextClick() }
            pasteAddressButton.setOnClickListener { onPasteClick() }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            registerWatchAccountViewModel.copiedMessageFlow.collectLatest(copiedMessageCollector)
        }
    }

    override fun onStart() {
        super.onStart()
        initSavedStateListeners()
    }

    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.addOnWindowFocusChangeListener(windowFocusChangeListener)
        }
        getLatestCopiedMessage()
    }

    private fun onPasteClick() {
        binding.addressCustomInputLayout.text = registerWatchAccountViewModel.getCopiedMessage()
    }

    private fun initSavedStateListeners() {
        startSavedStateListener(R.id.registerWatchAccountFragment) {
            useSavedStateValue<DecodedQrCode>(QR_SCAN_RESULT_KEY) { decodedQrCode ->
                if (!decodedQrCode.address.isNullOrBlank()) {
                    binding.addressCustomInputLayout.text = decodedQrCode.address
                }
            }
        }
    }

    private fun onNextClick() {
        val enteredAddress = binding.addressCustomInputLayout.text
        if (enteredAddress.isValidAddress()) {
            if (registerWatchAccountViewModel.isThereAccountWithAddress(enteredAddress).not()) {
                val newAccount = AccountCreation(Account.create(enteredAddress, Account.Detail.Watch), WATCH)
                navToNameRegistrationFragment(newAccount)
            } else {
                context?.showAlertDialog(getString(R.string.error), getString(R.string.this_account_already_exists))
            }
        } else {
            context?.showAlertDialog(getString(R.string.error), getString(R.string.entered_address_is_not_valid))
        }
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
            RegisterWatchAccountFragmentDirections.actionRegisterWatchAccountInfoFragmentToQrCodeScannerNavigation(
                QrScanner(
                    scanTypes = arrayOf(QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK),
                    titleRes = R.string.scan_an_algorand
                )
            )
        )
    }

    private fun onAddressChanges(text: String) {
        binding.confirmationButton.isEnabled = text.isNotEmpty()
    }

    private fun onBackClick() {
        view?.hideKeyboard()
        navBack()
    }

    private fun getLatestCopiedMessage() {
        val copiedMessage = context?.getTextFromClipboard().toString()
        registerWatchAccountViewModel.setCopiedMessage(copiedMessage)
    }

    private fun setupPasteButton(copiedMessage: String?) {
        val accountTextColor = ContextCompat.getColor(binding.root.context, R.color.secondaryTextColor)
        val accountTextSize = resources.getDimensionPixelSize(R.dimen.text_size_11)
        val spannableString = context?.getXmlStyledString(
            stringResId = R.string.paste_with_account,
            replacementList = listOf("account" to copiedMessage.toShortenedAddress()),
            customAnnotations = listOf(
                "account_color" to ForegroundColorSpan(accountTextColor),
                "account_text_size" to AbsoluteSizeSpan(accountTextSize)
            )
        )
        binding.pasteAddressButton.text = spannableString
    }

    override fun onPause() {
        super.onPause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.removeOnWindowFocusChangeListener(windowFocusChangeListener)
        }
    }
}
