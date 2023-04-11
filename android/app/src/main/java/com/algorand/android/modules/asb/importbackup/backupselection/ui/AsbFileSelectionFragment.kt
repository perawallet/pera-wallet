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

package com.algorand.android.modules.asb.importbackup.backupselection.ui

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.perafileuploadview.PeraFileUploadView
import com.algorand.android.customviews.perafileuploadview.model.FileUploadState
import com.algorand.android.databinding.FragmentAsbFileSelectionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.asb.util.AlgorandSecureBackupUtils
import com.algorand.android.utils.Event
import com.algorand.android.utils.emptyString
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AsbFileSelectionFragment : BaseFragment(R.layout.fragment_asb_file_selection) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAsbFileSelectionBinding::bind)

    private val asbFileSelectionViewModel by viewModels<AsbFileSelectionViewModel>()

    private val fileSelectorLauncher = registerForActivityResult(StartActivityForResult()) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            asbFileSelectionViewModel.onFileSelected(result.data?.data)
        }
    }

    private val fileUploadViewListener = object : PeraFileUploadView.Listener {
        override fun onUploadCancel() {
            asbFileSelectionViewModel.onUploadCancelClick()
        }

        override fun onReplaceFile() {
            asbFileSelectionViewModel.onReplaceFileClick()
        }

        override fun onSelectFile() {
            asbFileSelectionViewModel.onSelectFileClick()
        }
    }

    private val pasteButtonVisibilityCollector: suspend (Boolean) -> Unit = { isVisible ->
        binding.pasteBackupFileButton.isVisible = isVisible
    }

    private val nextButtonEnableCollector: suspend (Boolean) -> Unit = { isEnabled ->
        binding.nextButton.isEnabled = isEnabled
    }

    private val fileUploadStateCollector: suspend (FileUploadState) -> Unit = { fileUploadState ->
        binding.fileUploadView.updateUploadState(fileUploadState)
    }

    private val openFileSelectorEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { launchFileSelectorIntent() }
    }

    private val showGlobalErrorEventCollector: suspend (
        Event<Pair<AnnotatedString, AnnotatedString?>>?
    ) -> Unit = { event ->
        event?.consume()?.let { (titleAnnotatedString, descriptionAnnotatedString) ->
            showGlobalErrorMessage(titleAnnotatedString, descriptionAnnotatedString)
        }
    }

    private val navToAsbEnterKeyFragmentEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run { navToAsbEnterKeyFragment(this) }
    }

    private val showGlobalSuccessEventCollector: suspend (Event<Int>?) -> Unit = { event ->
        event?.consume()?.run { showAlertSuccess(title = getString(this), tag = baseActivityTag) }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    private fun initUi() {
        with(binding) {
            fileUploadView.setListener(fileUploadViewListener)
            nextButton.setOnClickListener { asbFileSelectionViewModel.onNextButtonClick() }
            pasteBackupFileButton.setOnClickListener { asbFileSelectionViewModel.onPasteButtonClick() }
        }
    }

    private fun initObservers() {
        with(asbFileSelectionViewModel.asbFileSelectionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.fileUploadState },
                collection = fileUploadStateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isNextButtonEnabled },
                collection = nextButtonEnableCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isPasteButtonVisible },
                collection = pasteButtonVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.openFileSelectorEvent },
                collection = openFileSelectorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.showGlobalErrorEvent },
                collection = showGlobalErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToAsbEnterKeyFragmentEvent },
                collection = navToAsbEnterKeyFragmentEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.showGlobalSuccessEvent },
                collection = showGlobalSuccessEventCollector
            )
        }
    }

    private fun launchFileSelectorIntent() {
        val openDocumentIntent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "*/*"
            addCategory(Intent.CATEGORY_OPENABLE)
            putExtra(Intent.EXTRA_MIME_TYPES, AlgorandSecureBackupUtils.IMPORT_BACKUP_FILE_MIME_TYPES)
        }
        fileSelectorLauncher.launch(openDocumentIntent)
    }

    private fun navToAsbEnterKeyFragment(cipherText: String) {
        nav(AsbFileSelectionFragmentDirections.actionAsbFileSelectionFragmentToAsbKeyEnterFragment(cipherText))
    }

    private fun showGlobalErrorMessage(
        titleAnnotatedString: AnnotatedString,
        descriptionAnnotatedString: AnnotatedString?
    ) {
        val safeTitle = context?.getXmlStyledString(titleAnnotatedString).toString()

        val safeDescription = if (descriptionAnnotatedString != null) {
            context?.getXmlStyledString(descriptionAnnotatedString).toString()
        } else {
            emptyString()
        }
        showGlobalError(title = safeTitle, errorMessage = safeDescription)
    }
}
