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

package com.algorand.android.modules.asb.importbackup.enterkey.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.PassphraseWordSuggestor
import com.algorand.android.customviews.passphraseinput.PassphraseInputGroup
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputConfiguration
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputGroupConfiguration
import com.algorand.android.databinding.FragmentAsbKeyEnterBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.backupprotocol.model.BackupProtocolElement
import com.algorand.android.utils.Event
import com.algorand.android.utils.delegation.keyboardvisibility.KeyboardHandlerDelegation
import com.algorand.android.utils.delegation.keyboardvisibility.KeyboardHandlerDelegationImpl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AsbKeyEnterFragment : BaseFragment(R.layout.fragment_asb_key_enter),
    KeyboardHandlerDelegation by KeyboardHandlerDelegationImpl() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAsbKeyEnterBinding::bind)
    private val asbKeyEnterViewModel by viewModels<AsbKeyEnterViewModel>()

    private val screenTitleHeight by lazy { binding.titleTextView.height }

    private val onKeyboardOpenedListener = KeyboardHandlerDelegationImpl.OnKeyboardOpenedListener {
        scrollToFocusedInput()
    }

    private val passphraseInputGroupListener = object : PassphraseInputGroup.Listener {
        override fun onInputFocus(itemOrder: Int, yCoordinate: Int) {
            asbKeyEnterViewModel.onFocusedViewChanged(itemOrder)
            if (isKeyboardVisible) {
                scrollToFocusedInput()
            }
        }

        override fun onFocusedWordChanged(itemOrder: Int, word: String) {
            asbKeyEnterViewModel.onFocusedInputChanged(value = word)
        }

        override fun onDoneClick(itemOrder: Int) {
            view?.hideKeyboard()
            asbKeyEnterViewModel.onNextButtonClick()
        }

        override fun onNextClick(itemOrder: Int) {
            binding.passphraseInputGroup.safeFocusNextItem(itemOrder)
        }

        override fun onClipboardTextPasted(clipboardData: String) {
            asbKeyEnterViewModel.onClipboardTextPasted(clipboardData)
        }
    }

    private val wordSuggestorListener = PassphraseWordSuggestor.Listener { word ->
        asbKeyEnterViewModel.onFocusedInputChanged(value = word)
        binding.passphraseInputGroup.focusNextItem()
    }

    private val restorePassphraseInputGroupEventCollector: suspend (Event<PassphraseInputGroupConfiguration>?) -> Unit =
        { event ->
            event?.consume()?.run { restorePassphraseInputGroup(this) }
        }

    private val globalErrorEventCollector: suspend (Event<Pair<Int, Int>>?) -> Unit = { event ->
        event?.consume()?.let { (titleResId, descriptionResId) ->
            showGlobalError(
                errorMessage = getString(descriptionResId),
                title = getString(titleResId)
            )
        }
    }

    private val unfocusedPassphraseItemCollector: suspend (PassphraseInputConfiguration?) -> Unit = {
        if (it != null) binding.passphraseInputGroup.updatePassphraseInputsConfiguration(it)
    }

    private val focusedPassphraseItemCollector: suspend (PassphraseInputConfiguration?) -> Unit = {
        if (it != null) binding.passphraseInputGroup.updatePassphraseInputsConfiguration(it)
    }

    private val nextButtonStateCollector: suspend (Boolean) -> Unit = { isEnabled ->
        binding.nextButton.isEnabled = isEnabled
    }

    private val suggestedWordsCollector: suspend (List<String>) -> Unit = { suggestedWords ->
        binding.passphraseWordSuggestor.setSuggestedWords(suggestedWords)
    }

    private val navToAccountSelectionFragmentEventCollector: suspend (Event<List<BackupProtocolElement>>?) -> Unit =
        { event ->
            event?.consume()?.run { navToAccountSelection(this) }
        }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        registerKeyboardHandlerDelegation(baseFragment = this, onKeyboardOpenedListener = onKeyboardOpenedListener)
        initObservers()
        initUi()
    }

    private fun initUi() {
        initPassphraseInputGroup(asbKeyEnterViewModel.getInitialPassphraseInputGroupConfiguration())
        with(binding) {
            passphraseInputGroup.setListener(passphraseInputGroupListener)
            passphraseWordSuggestor.listener = wordSuggestorListener
            nextButton.setOnClickListener { asbKeyEnterViewModel.onNextButtonClick() }
        }
    }

    private fun initObservers() {
        with(asbKeyEnterViewModel.asbKeyEnterPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.suggestedWords },
                collection = suggestedWordsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isNextButtonEnabled },
                collection = nextButtonStateCollector
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
                flow = map { it.navToAccountSelectionFragmentEvent },
                collection = navToAccountSelectionFragmentEventCollector
            )
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

    private fun scrollToFocusedInput() {
        with(binding) {
            val focusedInput = passphraseInputGroup.focusedChild ?: return
            val safeScrollYPosition = (focusedInput.y - focusedInput.height + screenTitleHeight).toInt()
            contentScrollView.smoothScrollTo(0, safeScrollYPosition)
        }
    }

    private fun navToAccountSelection(backupProtocolElements: List<BackupProtocolElement>) {
        nav(
            AsbKeyEnterFragmentDirections.actionAsbKeyEnterFragmentToAsbImportAccountSelectionFragment(
                backupProtocolElements.toTypedArray()
            )
        )
    }
}
