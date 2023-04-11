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

package com.algorand.android.ui.register.recover

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.PassphraseWordSuggestor
import com.algorand.android.customviews.passphraseinput.PassphraseInputGroup.Listener
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputConfiguration
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputGroupConfiguration
import com.algorand.android.databinding.FragmentRecoverWithPassphraseBinding
import com.algorand.android.models.AccountCreation
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.register.recover.RecoverOptionsBottomSheet.Companion.RESULT_KEY
import com.algorand.android.ui.register.recover.RecoverWithPassphraseQrScannerFragment.Companion.MNEMONIC_QR_SCAN_RESULT_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.KeyboardToggleListener
import com.algorand.android.utils.addKeyboardToggleListener
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getTextFromClipboard
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.removeKeyboardToggleListener
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RecoverWithPassphraseFragment : DaggerBaseFragment(R.layout.fragment_recover_with_passphrase) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val recoverWithPassphraseViewModel: RecoverWithPassphraseViewModel by viewModels()

    private val binding by viewBinding(FragmentRecoverWithPassphraseBinding::bind)

    private var keyboardToggleListener: KeyboardToggleListener? = null

    private lateinit var accountCreation: AccountCreation

    private val recoverPassphraseTitleHeight by lazy { binding.recoverPassphraseTitle.height }

    private val onKeyboardToggleAction: (Boolean) -> Unit = { keyboardShown ->
        if (keyboardShown) {
            scrollToFocusedInput()
        }
    }

    private val passphraseInputGroupListener = object : Listener {
        override fun onInputFocus(itemOrder: Int, yCoordinate: Int) {
            recoverWithPassphraseViewModel.onFocusedViewChanged(itemOrder)
            if (keyboardToggleListener?.isKeyboardShown == true) {
                scrollToFocusedInput()
            }
        }

        override fun onFocusedWordChanged(itemOrder: Int, word: String) {
            recoverWithPassphraseViewModel.onFocusedInputChanged(value = word)
        }

        override fun onDoneClick(itemOrder: Int) {
            view?.hideKeyboard()
            recoverWithPassphraseViewModel.onRecoverButtonClick()
        }

        override fun onNextClick(itemOrder: Int) {
            binding.passphraseInputGroup.safeFocusNextItem(itemOrder)
        }

        override fun onClipboardTextPasted(clipboardData: String) {
            recoverWithPassphraseViewModel.onClipboardTextPasted(clipboardData)
        }
    }

    private val wordSuggestorListener = PassphraseWordSuggestor.Listener { word ->
        recoverWithPassphraseViewModel.onFocusedInputChanged(value = word)
        binding.passphraseInputGroup.focusNextItem()
    }

    private val suggestedWordsCollector: suspend (List<String>) -> Unit = { suggestedWords ->
        binding.passphraseWordSuggestor.setSuggestedWords(suggestedWords)
    }

    private val recoveryStateCollector: suspend (Boolean) -> Unit = { isEnabled ->
        binding.recoverButton.isEnabled = isEnabled
    }

    private val focusedPassphraseItemCollector: suspend (PassphraseInputConfiguration?) -> Unit = {
        if (it != null) binding.passphraseInputGroup.updatePassphraseInputsConfiguration(it)
    }

    private val unfocusedPassphraseItemCollector: suspend (PassphraseInputConfiguration?) -> Unit = {
        if (it != null) binding.passphraseInputGroup.updatePassphraseInputsConfiguration(it)
    }

    private val globalErrorEventCollector: suspend (Event<Int>?) -> Unit = {
        it?.consume()?.run { showGlobalError(getString(this)) }
    }

    private val restorePassphraseInputGroupEventCollector: suspend (Event<PassphraseInputGroupConfiguration>?) -> Unit =
        {
            it?.consume()?.run { restorePassphraseInputGroup(this) }
        }

    private val accountNotFoundEventCollector: suspend (Event<AnnotatedString>?) -> Unit = {
        it?.consume()?.run { showErrorBottomSheet(this) }
    }

    private val recoverAccountEventCollector: suspend (Event<AccountCreation>?) -> Unit = {
        it?.consume()?.run {
            accountCreation = this
            navigateToSuccess()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        customizeToolbar()
    }

    private fun initUi() {
        initPassphraseInputGroup(recoverWithPassphraseViewModel.getInitialPassphraseInputGroupConfiguration())
        with(binding) {
            passphraseInputGroup.setListener(passphraseInputGroupListener)
            passphraseWordSuggestor.listener = wordSuggestorListener
            recoverButton.setOnClickListener { recoverWithPassphraseViewModel.onRecoverButtonClick() }
        }
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.recoverWithPassphraseFragment) {
            useSavedStateValue<String>(MNEMONIC_QR_SCAN_RESULT_KEY) { mnemonic ->
                recoverWithPassphraseViewModel.onClipboardTextPasted(mnemonic)
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
        nav(
            RecoverWithPassphraseFragmentDirections
                .actionRecoverWithPassphraseFragmentToRecoverWithPassphraseQrScannerFragment()
        )
    }

    private fun initObservers() {
        with(recoverWithPassphraseViewModel.recoverWithPassphrasePreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.suggestedWords },
                collection = suggestedWordsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isRecoveryEnabled },
                collection = recoveryStateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.passphraseInputGroupConfiguration.focusedPassphraseItem },
                collection = focusedPassphraseItemCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.passphraseInputGroupConfiguration.unfocusedPassphraseItem },
                collection = unfocusedPassphraseItemCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onGlobalErrorEvent },
                collection = globalErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onRestorePassphraseInputGroupEvent },
                collection = restorePassphraseInputGroupEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onRecoverAccountEvent },
                collection = recoverAccountEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onAccountNotFoundEvent },
                collection = accountNotFoundEventCollector
            )
        }
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
        keyboardToggleListener = addKeyboardToggleListener(binding.root, onKeyboardToggleAction)
    }

    override fun onPause() {
        super.onPause()
        view?.hideKeyboard()
        keyboardToggleListener?.removeKeyboardToggleListener(binding.root)
    }

    private fun customizeToolbar() {
        getAppToolbar()?.setEndButton(button = IconButton(R.drawable.ic_more, onClick = ::onOptionsClick))
    }

    private fun pasteClipboard() {
        val pastedPassphrase = context?.getTextFromClipboard().toString()
        recoverWithPassphraseViewModel.onClipboardTextPasted(pastedPassphrase)
    }

    private fun navigateToSuccess() {
        nav(
            RecoverWithPassphraseFragmentDirections
                .actionRecoverWithPassphraseFragmentToRecoverAccountNameRegistrationFragment(accountCreation)
        )
    }

    private fun showErrorBottomSheet(descriptionString: AnnotatedString) {
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.wrong_passphrase),
                drawableResId = R.drawable.ic_error,
                drawableTintResId = R.color.error_tint_color,
                descriptionAnnotatedString = descriptionString,
                isResultNeeded = false,
            )
        )
    }

    private fun onOptionsClick() {
        nav(RecoverWithPassphraseFragmentDirections.actionRecoverWithPassphraseFragmentToRecoverOptionsBottomSheet())
    }

    private fun scrollToFocusedInput() {
        with(binding) {
            val focusedInput = passphraseInputGroup.focusedChild
            scrollView.smoothScrollTo(0, (focusedInput.y - focusedInput.height + recoverPassphraseTitleHeight).toInt())
        }
    }

    private fun restorePassphraseInputGroup(passphraseInputGroupConfiguration: PassphraseInputGroupConfiguration) {
        binding.passphraseInputGroup.updatePassphraseInputsConfiguration(
            passphraseInputConfigurationList = passphraseInputGroupConfiguration.passphraseInputConfigurationList
        )
    }

    private fun initPassphraseInputGroup(passphraseInputGroupConfiguration: PassphraseInputGroupConfiguration) {
        binding.passphraseInputGroup.initPassphraseInputGroup(
            passphraseInputConfigurationList = passphraseInputGroupConfiguration.passphraseInputConfigurationList
        )
    }
}
