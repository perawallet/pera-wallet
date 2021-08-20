/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.register.recover

import android.content.SharedPreferences
import android.content.res.ColorStateList
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import androidx.core.content.ContextCompat
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.navGraphViewModels
import com.algorand.algosdk.mobile.Mobile
import com.algorand.android.MainNavigationDirections
import com.algorand.android.MainViewModel
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.PassphraseInput
import com.algorand.android.customviews.PassphraseInputGroup
import com.algorand.android.customviews.PassphraseInputGroup.Companion.WORD_COUNT
import com.algorand.android.customviews.PassphraseWordSuggestor
import com.algorand.android.databinding.FragmentRecoverWithPassphraseBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment.Companion.QR_SCAN_RESULT_KEY
import com.algorand.android.ui.register.LoginNavigationViewModel
import com.algorand.android.ui.register.recover.RecoverOptionsBottomSheet.Companion.RESULT_KEY
import com.algorand.android.ui.register.recover.RecoverWithPassphraseFragmentDirections.Companion.actionGlobalToHomeNavigation
import com.algorand.android.ui.register.recover.RecoverWithPassphraseFragmentDirections.Companion.actionRecoverWithPassphraseFragmentToQrCodeScannerFragment
import com.algorand.android.ui.register.recover.RecoverWithPassphraseFragmentDirections.Companion.actionRecoverWithPassphraseFragmentToRecoverOptionsBottomSheet
import com.algorand.android.utils.KeyboardToggleListener
import com.algorand.android.utils.SingleButtonBottomSheet.Companion.ACCEPT_KEY
import com.algorand.android.utils.addKeyboardToggleListener
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.getTextFromClipboard
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.removeKeyboardToggleListener
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.util.Locale
import javax.inject.Inject
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class RecoverWithPassphraseFragment : DaggerBaseFragment(R.layout.fragment_recover_with_passphrase) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::onBackClick
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    @Inject
    lateinit var sharedPref: SharedPreferences

    @Inject
    lateinit var accountManager: AccountManager

    private val recoverWithPassphraseViewModel: RecoverWithPassphraseViewModel by viewModels()

    private val loginNavigationViewModel: LoginNavigationViewModel by navGraphViewModels(R.id.loginNavigation) {
        defaultViewModelProviderFactory
    }

    private val mainViewModel: MainViewModel by activityViewModels()

    private val binding by viewBinding(FragmentRecoverWithPassphraseBinding::bind)

    private var keyboardToggleListener: KeyboardToggleListener? = null

    private var passphraseInput: PassphraseInput? = null

    private val onKeyboardToggleAction: (shown: Boolean) -> Unit = { keyboardShown ->
        if (keyboardShown && passphraseInput != null) {
            scrollToPassphraseInput(passphraseInput!!)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initSavedStateListener()
        customizeToolbar()
        recoverMnemonicFromViewModel()
        binding.recoverButton.setOnClickListener { onRecoverClick() }
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.recoverWithPassphraseFragment) {
            useSavedStateValue<Boolean>(ACCEPT_KEY) {
                handleNextNavigation()
            }
            useSavedStateValue<DecodedQrCode>(QR_SCAN_RESULT_KEY) { decodedQrCode ->
                if (!decodedQrCode.mnemonic.isNullOrBlank()) {
                    binding.passphraseInputGroup.setMnemonic(decodedQrCode.mnemonic)
                }
            }
            useSavedStateValue<RecoverOptionsBottomSheet.OptionResult>(RESULT_KEY) { optionResult ->
                when (optionResult) {
                    RecoverOptionsBottomSheet.OptionResult.PASTE -> pasteClipboard()
                    RecoverOptionsBottomSheet.OptionResult.SCAN_QR -> navToScanQr()
                }
            }
        }
    }

    private fun navToScanQr() {
        recoverWithPassphraseViewModel.mnemonic = binding.passphraseInputGroup.getMnemonicResponse().mnemonic
        nav(
            actionRecoverWithPassphraseFragmentToQrCodeScannerFragment(
                listOf(QrCodeScannerFragment.ScanReturnType.MNEMONIC_NAVIGATE_BACK).toTypedArray()
            )
        )
    }

    private fun recoverMnemonicFromViewModel() {
        val mnemonic = recoverWithPassphraseViewModel.mnemonic.takeIf { it.isNotEmpty() }
        if (mnemonic != null) {
            binding.passphraseInputGroup.setMnemonic(mnemonic)
        } else {
            binding.passphraseInputGroup.focusTo(0, shouldShowKeyboard = true)
        }
    }

    private fun initObservers() {
        initWordSuggestorListener()

        initInputGroupListener()

        viewLifecycleOwner.lifecycleScope.launch {
            recoverWithPassphraseViewModel.suggestionWordsFlow.collectLatest { (index, suggestedWords) ->
                binding.passphraseWordSuggestor.setSuggestedWords(index, suggestedWords)
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            recoverWithPassphraseViewModel.validationFlow.collectLatest { (index, isValidated) ->
                binding.passphraseInputGroup.setValidation(index, isValidated)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        keyboardToggleListener = addKeyboardToggleListener(binding.root, onKeyboardToggleAction)
    }

    override fun onPause() {
        super.onPause()
        view?.hideKeyboard()
        keyboardToggleListener?.removeKeyboardToggleListener(binding.root)
    }

    private fun customizeToolbar() {
        getAppToolbar()?.apply {

            val optionsButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_icon_tab_button, this, false) as ImageButton

            val optionsTintColor = ContextCompat.getColor(context, R.color.primaryTextColor)

            optionsButton.apply {
                setImageResource(R.drawable.ic_more)
                imageTintList = ColorStateList.valueOf(optionsTintColor)
                setOnClickListener { onOptionsClick() }
                addViewToEndSide(this)
            }
        }
    }

    private fun handleNextNavigation() {
        mainViewModel.addAccount(loginNavigationViewModel.tempAccount, loginNavigationViewModel.creationType)
        nav(actionGlobalToHomeNavigation())
    }

    private fun onBackClick() {
        navBack()
    }

    private fun initWordSuggestorListener() {
        binding.passphraseWordSuggestor.listener = object : PassphraseWordSuggestor.Listener {
            override fun onSuggestedWordSelected(index: Int, word: String) {
                binding.passphraseInputGroup.setSuggestedWord(index, word)
            }
        }
    }

    private fun initInputGroupListener() {
        binding.passphraseInputGroup.listener = object : PassphraseInputGroup.Listener {
            override fun onInputFocus(passphraseInput: PassphraseInput) {
                if (keyboardToggleListener?.isKeyboardShown == true) {
                    scrollToPassphraseInput(passphraseInput)
                } else {
                    this@RecoverWithPassphraseFragment.passphraseInput = passphraseInput
                }
            }

            override fun onNewUpdate(index: Int, word: String) {
                lifecycleScope.launch {
                    recoverWithPassphraseViewModel.newUpdateFlow.emit(Pair(index, word))
                }
            }

            override fun onDoneClick(isAllValidationDone: Boolean) {
                if (isAllValidationDone) {
                    verifyMnemonic()
                }
                view?.hideKeyboard()
            }

            override fun onMnemonicReady(isReady: Boolean) {
                binding.recoverButton.isEnabled = isReady
            }

            override fun onError(errorResId: Int) {
                showGlobalError(getString(errorResId))
            }
        }
    }

    private fun scrollToPassphraseInput(passphraseInput: PassphraseInput) {
        binding.scrollView.smoothScrollTo(0, (passphraseInput.y - passphraseInput.height).toInt())
    }

    private fun navigateToSuccess() {
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleResId = R.string.account_verified,
                drawableResId = R.drawable.ic_check_sign,
                descriptionAnnotatedString = AnnotatedString(R.string.account_verified_message),
                buttonTextResId = R.string.go_to_home,
                isResultNeeded = true
            )
        )
    }

    private fun verifyMnemonic() {
        try {
            val mnemonicResponse = binding.passphraseInputGroup.getMnemonicResponse()
            if (mnemonicResponse is PassphraseInputGroup.MnemonicResponse.Error) {
                showGlobalError(errorMessage = mnemonicResponse.error.toString())
                return
            }
            val privateKey = Mobile.mnemonicToPrivateKey(mnemonicResponse.mnemonic.toLowerCase(Locale.ENGLISH))
            if (privateKey != null) {
                val publicKey = Mobile.generateAddressFromSK(privateKey)
                val sameAccount = accountManager.getAccounts().find { account -> account.address == publicKey }
                if (sameAccount != null &&
                    sameAccount.type != Account.Type.REKEYED &&
                    sameAccount.type != Account.Type.WATCH
                ) {
                    showGlobalError(getString(R.string.this_account_already_exists))
                    return
                }
                val recoveredAccount = Account.create(
                    publicKey, Account.Detail.Standard(privateKey), publicKey.toShortenedAddress()
                )
                loginNavigationViewModel.setTempAccount(recoveredAccount, CreationType.RECOVER)
                navigateToSuccess()
            }
        } catch (exception: Exception) {
            showGlobalError(errorMessage = getString(R.string.your_passphrase_is_invalid_please))
        }
    }

    private fun pasteClipboard() {
        val pastedPassphrase = context?.getTextFromClipboard() ?: ""
        val keywords = pastedPassphrase.split(" ")
        if (keywords.count() == WORD_COUNT) {
            binding.passphraseInputGroup.setMnemonic(pastedPassphrase.toString())
        } else {
            showGlobalError(getString(R.string.the_last_copied_text))
        }
    }

    private fun onOptionsClick() {
        nav(actionRecoverWithPassphraseFragmentToRecoverOptionsBottomSheet())
    }

    private fun onRecoverClick() {
        verifyMnemonic()
    }
}
