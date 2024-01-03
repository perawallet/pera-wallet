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

package com.algorand.android.modules.asb.createbackup.fileready.ui

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.core.view.doOnLayout
import androidx.core.view.updatePadding
import androidx.fragment.app.viewModels
import com.algorand.android.AsbCreationNavigationDirections
import com.algorand.android.R
import com.algorand.android.databinding.LayoutFileInfoBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.asb.createbackup.storebackupconfirmation.AsbStoreBackupConfirmationBottomSheet.Companion.ASB_STORE_BACKUP_CONFIRMATION_KEY
import com.algorand.android.modules.baseresult.ui.BaseResultFragment
import com.algorand.android.modules.baseresult.ui.BaseResultViewModel
import com.algorand.android.modules.baseresult.ui.adapter.BaseResultAdapter
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.ASB_SUPPORT_URL
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AsbFileReadyFragment : BaseResultFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navToBackupConfirmationBottomSheet
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)
    override val baseResultViewModel: BaseResultViewModel get() = asbFileReadyViewModel

    private val descriptionItemListener = BaseResultAdapter.DescriptionItemListener {
        context?.openUrl(ASB_SUPPORT_URL)
    }

    override val baseResultAdapter = BaseResultAdapter(
        accountItemListener = accountItemListener,
        descriptionItemListener = descriptionItemListener
    )

    private val asbFileReadyViewModel by viewModels<AsbFileReadyViewModel>()
    private val fileInfoViewStubBinding by viewBinding { LayoutFileInfoBinding.bind(inflateFileInfoLayout()) }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            navToBackupConfirmationBottomSheet()
        }
    }

    private val permissionLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
        if (it.resultCode == Activity.RESULT_OK) {
            asbFileReadyViewModel.onBackupLocationSelected(it.data?.data)
        }
    }

    private val formattedBackupFileSizeCollector: suspend (String) -> Unit = { formattedFileSize ->
        fileInfoViewStubBinding.fileSizeTextView.text = formattedFileSize
    }

    private val backupFileNameCollector: suspend (String) -> Unit = { fileName ->
        fileInfoViewStubBinding.fileNameTextView.text = fileName
    }

    private val onFileContentCopyEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run { copFileContentToClipboard(this) }
    }

    private val onBackupFileSavedEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToBackupConfirmationBottomSheet() }
    }

    private val navToFailureScreenEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToBackupFailedFragment() }
    }

    private val launchCreateDocumentIntentEventCollector: suspend (Event<Intent>?) -> Unit = { event ->
        event?.consume()?.run { onSaveBackupFileClick(this) }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        useFragmentResultListenerValue<Boolean>(ASB_STORE_BACKUP_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) onPopSecureBackupFlowUp()
        }
    }

    override fun initUi() {
        super.initUi()
        binding.primaryActionButton.apply {
            setOnClickListener { asbFileReadyViewModel.onSaveBackupFileClick() }
            icon = ContextCompat.getDrawable(context, R.drawable.ic_download)
            setText(R.string.save_backup_file)
            show()
        }
        binding.secondaryActionButton.apply {
            setOnClickListener { navToBackupConfirmationBottomSheet() }
            setText(R.string.done)
            show()
        }
        binding.resultItemRecyclerView.apply {
            fileInfoViewStubBinding.root.doOnLayout {
                val bottomSafeAreaMargin = resources.getDimensionPixelSize(R.dimen.bottom_safe_area_margin)
                val safeBottomPadding = paddingBottom + it.height + bottomSafeAreaMargin
                updatePadding(bottom = safeBottomPadding)
            }
        }
        fileInfoViewStubBinding.fileContentCopyButton.setOnClickListener { asbFileReadyViewModel.onFileContentCopy() }
    }

    override fun initObservers() {
        super.initObservers()
        with(asbFileReadyViewModel.baseResultPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.fileName },
                collection = backupFileNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.formattedFileSize },
                collection = formattedBackupFileSizeCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onFileContentCopyEvent },
                collection = onFileContentCopyEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onBackupFileSavedEvent },
                collection = onBackupFileSavedEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToFailureScreenEvent },
                collection = navToFailureScreenEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.launchCreateDocumentIntentEvent },
                collection = launchCreateDocumentIntentEventCollector
            )
        }
    }

    private fun onSaveBackupFileClick(documentTreeIntent: Intent) {
        permissionLauncher.launch(documentTreeIntent)
    }

    private fun copFileContentToClipboard(fileContent: String) {
        context?.copyToClipboard(textToCopy = fileContent, showToast = false)
        showTopToast(getString(R.string.backup_file_copied_to))
    }

    private fun navToBackupFailedFragment() {
        nav(AsbFileReadyFragmentDirections.actionAsbFileReadyFragmentToAsbFileFailureFragment())
    }

    private fun navToBackupConfirmationBottomSheet() {
        nav(AsbFileReadyFragmentDirections.actionAsbFileReadyFragmentToAsbStoreBackupConfirmationBottomSheet())
    }

    private fun onPopSecureBackupFlowUp() {
        nav(AsbCreationNavigationDirections.actionAsbCreationNavigationPop())
    }

    private fun inflateFileInfoLayout(): View {
        return with(binding.resultViewStub) {
            layoutResource = R.layout.layout_file_info
            inflate()
        }
    }
}
