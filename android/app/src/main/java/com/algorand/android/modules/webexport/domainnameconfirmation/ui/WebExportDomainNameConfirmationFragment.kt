/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.webexport.domainnameconfirmation.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentWebExportDomainNameConfirmationBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.webexport.pinentry.ui.WebExportPasswordFragment.Companion.WEB_EXPORT_PASSWORD_RESULT_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.KeyboardToggleListener
import com.algorand.android.utils.addKeyboardToggleListener
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WebExportDomainNameConfirmationFragment : BaseFragment(R.layout.fragment_web_export_domain_name_confirmation) {

    val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private var keyboardToggleListener: KeyboardToggleListener? = null

    private val onKeyboardToggleAction: (shown: Boolean) -> Unit = { keyboardShown ->
        if (keyboardShown) {
            binding.scrollView.smoothScrollTo(
                0,
                (binding.enterUrlInputLayout.y - resources.getDimension(R.dimen.webexport_bottom_padding)).toInt()
            )
        }
    }

    val binding by viewBinding(FragmentWebExportDomainNameConfirmationBinding::bind)

    private val webExportDomainNameConfirmationViewModel: WebExportDomainNameConfirmationViewModel by viewModels()

    private val continueButtonStateCollector: suspend (Boolean) -> Unit = { isContinueButtonEnabled ->
        binding.continueButton.isEnabled = isContinueButtonEnabled
    }

    private val navigateToShowAuthenticationEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run { navToShowAuthentication() }
    }

    private val navigateToAccountConfirmationEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run { navToAccountConfirmation() }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    override fun onResume() {
        super.onResume()
        initDialogSavedStateListener()
        keyboardToggleListener = addKeyboardToggleListener(binding.root, onKeyboardToggleAction)
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.webExportDomainNameConfirmationFragment) {
            useSavedStateValue<Boolean>(WEB_EXPORT_PASSWORD_RESULT_KEY) {
                webExportDomainNameConfirmationViewModel.handlePasswordEntryResult(isPasscodeVerified = it)
            }
        }
    }

    private fun initUi() {
        with(binding) {
            enterUrlInputLayout.setInputTypeText()
            enterUrlInputLayout.setImeOptionsDone {
                webExportDomainNameConfirmationViewModel.onNavigationToNextFragmentClicked()
            }
            enterUrlInputLayout.setOnTextChangeListener {
                webExportDomainNameConfirmationViewModel.updatePreviewWithUrlInput(binding.enterUrlInputLayout.text)
            }
            continueButton.setOnClickListener {
                webExportDomainNameConfirmationViewModel.onNavigationToNextFragmentClicked()
            }
        }
    }

    private fun initObservers() {
        with(webExportDomainNameConfirmationViewModel.webExportDomainNameConfirmationPreviewFlow) {
            viewLifecycleOwner.collectLatestOnLifecycle(
                map { it.isContinueButtonEnabled }.distinctUntilChanged(),
                continueButtonStateCollector
            )

            viewLifecycleOwner.collectOnLifecycle(
                map { it.navigateToAccountConfirmationEvent }.distinctUntilChanged(),
                navigateToAccountConfirmationEventCollector
            )

            viewLifecycleOwner.collectOnLifecycle(
                map { it.navigateToShowAuthenticationEvent }.distinctUntilChanged(),
                navigateToShowAuthenticationEventCollector
            )
        }
    }

    private fun navToAccountConfirmation() {
        with(webExportDomainNameConfirmationViewModel.webExportDomainNameConfirmationPreviewFlow.value) {
            nav(
                WebExportDomainNameConfirmationFragmentDirections
                    .actionWebExportDomainNameConfirmationFragmentToWebExportAccountConfirmationFragment(
                        backupId = backupId,
                        encryptionKey = encryptionKey,
                        modificationKey = modificationKey,
                        accountList = accountList.toTypedArray()
                    )
            )
        }
    }

    private fun navToShowAuthentication() {
        with(webExportDomainNameConfirmationViewModel.webExportDomainNameConfirmationPreviewFlow.value) {
            nav(
                WebExportDomainNameConfirmationFragmentDirections
                    .actionWebExportDomainNameConfirmationFragmentToWebExportPasswordFragment(
                        backupId = backupId,
                        encryptionKey = encryptionKey,
                        modificationKey = modificationKey,
                        accountList = accountList.toTypedArray()
                    )
            )
        }
    }
}
