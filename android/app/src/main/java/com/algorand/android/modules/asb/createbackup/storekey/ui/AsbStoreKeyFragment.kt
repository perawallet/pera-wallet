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

package com.algorand.android.modules.asb.createbackup.storekey.ui

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAsbStoreKeyBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.asb.createbackup.createbackupconfirmation.ui.AsbCreateBackupConfirmationBottomSheet.Companion.ASB_CREATE_BACKUP_CONFIRMATION_KEY
import com.algorand.android.modules.asb.createbackup.createnewkeyconfirmation.ui.AsbCreateNewKeyConfirmationBottomSheet.Companion.ASB_CREATE_NEW_KEY_CONFIRMATION_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AsbStoreKeyFragment : BaseFragment(R.layout.fragment_asb_store_key) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val asbStoreKeyViewModel by viewModels<AsbStoreKeyViewModel>()

    private val binding by viewBinding(FragmentAsbStoreKeyBinding::bind)

    private val showGlobalErrorEventCollector: suspend (Event<Int>?) -> Unit = { event ->
        event?.consume()?.run { showGlobalError(errorMessage = getString(this)) }
    }

    private val openUrlEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run { context?.openUrl(this) }
    }

    private val navToCreateNewKeyConfirmationEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToCreateNewKeyConfirmationBottomSheet() }
    }

    private val navToCreateBackupConfirmationEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToCreateBackupConfirmationBottomSheet() }
    }

    private val navToBackupReadyEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run {
            asbStoreKeyViewModel.saveBackedUpAccountToLocalStorage()
            navToBackupReadyFragment(this)
        }
    }

    private val createNewKeyButtonVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.createNewKeyButton.isVisible = isVisible == true
    }

    private val mnemonicsCollector: suspend (List<String>?) -> Unit = { mnemonicList ->
        if (!mnemonicList.isNullOrEmpty()) binding.passphraseBoxView.setPassphrases(mnemonicList)
    }

    private val descriptionAnnotatedStringCollector: suspend (AnnotatedString?) -> Unit = { annotatedString ->
        if (annotatedString != null) applyDescriptionTextViewAnnotations(annotatedString)
    }

    private val titleTextResIdCollector: suspend (Int?) -> Unit = { titleResId ->
        if (titleResId != null) binding.titleTextView.setText(titleResId)
    }

    private val onKeyCopiedEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run { copyMnemonicsToClipboard(this) }
    }

    private val navToFailureScreenEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToBackupFailedFragment() }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            with(asbStoreKeyViewModel) {
                createNewKeyButton.setOnClickListener { onCreateNewKeyClicked() }
                storedMyKeyButton.setOnClickListener { onCreateBackupFileClicked() }
                copyToClipboardButton.setOnClickListener { onClipToKeyboardClicked() }
            }
        }
    }

    private fun initObservers() {
        with(asbStoreKeyViewModel.asbStoreKeyPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.titleTextResId },
                collection = titleTextResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.descriptionAnnotatedString },
                collection = descriptionAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.mnemonics },
                collection = mnemonicsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isCreateNewKeyButtonVisible },
                collection = createNewKeyButtonVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navToBackupReadyEvent },
                collection = navToBackupReadyEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navToCreateBackupConfirmationEvent },
                collection = navToCreateBackupConfirmationEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navToCreateNewKeyConfirmationEvent },
                collection = navToCreateNewKeyConfirmationEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.openUrlEvent },
                collection = openUrlEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.showGlobalErrorEvent },
                collection = showGlobalErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.onKeyCopiedEvent },
                collection = onKeyCopiedEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navToFailureScreenEvent },
                collection = navToFailureScreenEventCollector
            )
        }
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        useFragmentResultListenerValue<Boolean>(ASB_CREATE_BACKUP_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) asbStoreKeyViewModel.onBackupFileCreationConfirmed()
        }
        useFragmentResultListenerValue<Boolean>(ASB_CREATE_NEW_KEY_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) asbStoreKeyViewModel.onNewKeyCreationConfirmed()
        }
    }

    private fun applyDescriptionTextViewAnnotations(annotatedString: AnnotatedString) {
        binding.descriptionTextView.apply {
            val linkTextColor = ContextCompat.getColor(context, R.color.positive)
            val clickSpannable = getCustomClickableSpan(
                clickableColor = linkTextColor,
                onClick = { asbStoreKeyViewModel.onDescriptionUrlClick() }
            )
            val modifiedAnnotatedString = annotatedString.copy(
                customAnnotationList = listOf("url_click" to clickSpannable)
            )
            highlightColor = ContextCompat.getColor(context, R.color.transparent)
            movementMethod = LinkMovementMethod.getInstance()
            text = context.getXmlStyledString(modifiedAnnotatedString)
        }
    }

    private fun navToCreateNewKeyConfirmationBottomSheet() {
        nav(AsbStoreKeyFragmentDirections.actionAsbStoreKeyFragmentToAsbCreateNewKeyConfirmationBottomSheet())
    }

    private fun navToCreateBackupConfirmationBottomSheet() {
        nav(AsbStoreKeyFragmentDirections.actionAsbStoreKeyFragmentToAsbCreateBackupConfirmationBottomSheet())
    }

    private fun copyMnemonicsToClipboard(mnemonics: String) {
        context?.copyToClipboard(textToCopy = mnemonics, showToast = false)
        showTopToast(getString(R.string.key_copied_as_text))
    }

    private fun navToBackupReadyFragment(encryptedContent: String) {
        nav(AsbStoreKeyFragmentDirections.actionAsbStoreKeyFragmentToAsbFileReadyFragment(encryptedContent))
    }

    private fun navToBackupFailedFragment() {
        nav(AsbStoreKeyFragmentDirections.actionAsbStoreKeyFragmentToAsbFileFailureFragment())
    }
}
