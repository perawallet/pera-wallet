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

package com.algorand.android.modules.asb.createbackup.intro.ui

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAlgorandSecureBackupIntroBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.inapppin.pin.ui.InAppPinFragment.Companion.IN_APP_PIN_CONFIRMATION_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AsbIntroFragment : BaseFragment(R.layout.fragment_algorand_secure_backup_intro) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAlgorandSecureBackupIntroBinding::bind)

    private val asbIntroViewModel by viewModels<AsbIntroViewModel>()

    private val navToAccountSelectionScreenEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToAlgorandSecureBackupAccountSelectionFragment() }
    }

    private val navToEnterPinScreenEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToAlgorandSecureBackupPinFragment() }
    }

    private val openUrlEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run { openGivenUrl(this) }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        useFragmentResultListenerValue<Boolean>(IN_APP_PIN_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) {
                navToAlgorandSecureBackupAccountSelectionFragment()
            }
        }
    }

    private fun initUi() {
        binding.startButton.setOnClickListener { asbIntroViewModel.onStartClick() }
        setupSecondInstructionListItem()
    }

    private fun setupSecondInstructionListItem() {
        binding.secondInstructionListItem.apply {
            val linkTextColor = ContextCompat.getColor(context, R.color.positive)
            val learnMoreClickSpannable = getCustomClickableSpan(
                clickableColor = linkTextColor,
                onClick = { asbIntroViewModel.onLearnMoreClick() }
            )
            val termAndConditionsString = AnnotatedString(
                stringResId = R.string.record_or_save_your_12,
                customAnnotationList = listOf(
                    "learn_more_click" to learnMoreClickSpannable
                )
            )
            val highlightColor = ContextCompat.getColor(context, R.color.transparent)
            val linkMovementMethod = LinkMovementMethod.getInstance()

            setDescriptionHighlightColor(highlightColor)
            setDescriptionMovementMethod(linkMovementMethod)
            setDescriptionText(context.getXmlStyledString(termAndConditionsString))
        }
    }

    private fun initObservers() {
        with(asbIntroViewModel.asbIntroPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.openUrlEvent },
                collection = openUrlEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToEnterPinScreenEvent },
                collection = navToEnterPinScreenEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToAccountSelectionScreenEvent },
                collection = navToAccountSelectionScreenEventCollector
            )
        }
    }

    private fun navToAlgorandSecureBackupPinFragment() {
        nav(AsbIntroFragmentDirections.actionAsbIntroFragmentToInAppPinNavigation())
    }

    private fun navToAlgorandSecureBackupAccountSelectionFragment() {
        nav(AsbIntroFragmentDirections.actionAsbIntroFragmentToAsbCreationAccountSelectionFragment())
    }

    private fun openGivenUrl(url: String) {
        context?.openUrl(url)
    }
}
