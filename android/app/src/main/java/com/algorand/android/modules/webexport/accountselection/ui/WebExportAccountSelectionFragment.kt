package com.algorand.android.modules.webexport.accountselection.ui

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.WebExportNavigationDirections
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.databinding.FragmentWebExportAccountSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.webexport.accountselection.ui.adapter.WebExportAccountSelectionAdapter
import com.algorand.android.modules.webexport.accountselection.ui.model.WebExportAccountSelectionPreview
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WebExportAccountSelectionFragment : BaseFragment(R.layout.fragment_web_export_account_selection) {

    val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::handleNavBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    val binding by viewBinding(FragmentWebExportAccountSelectionBinding::bind)

    private val webExportAccountSelectionAdapterListener = object : WebExportAccountSelectionAdapter.Listener {
        override fun onCheckBoxClicked(currentCheckBoxState: TriStatesCheckBox.CheckBoxState) {
            webExportAccountSelectionViewModel.updatePreviewWithCheckBoxClickEvent(currentCheckBoxState)
        }

        override fun onAccountItemClicked(accountAddress: String) {
            webExportAccountSelectionViewModel.updatePreviewWithAccountClicked(accountAddress)
        }
    }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            handleNavBack()
        }
    }

    private val webExportAccountSelectionViewModel: WebExportAccountSelectionViewModel by viewModels()
    private val webExportAccountSelectionAdapter =
        WebExportAccountSelectionAdapter(webExportAccountSelectionAdapterListener)

    private val webExportAccountSelectionPreviewCollector:
        suspend (preview: WebExportAccountSelectionPreview) -> Unit = { updateUiWithPreview(it) }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
        initUi()
        initObservers()
    }

    private fun handleNavBack() {
        nav(WebExportNavigationDirections.actionWebExportNavigationPop())
    }

    private fun initUi() {
        with(binding) {
            accountSelectionRecyclerview.adapter = webExportAccountSelectionAdapter
            continueButton.setOnClickListener { onContinueButtonClicked() }
            closeButton.setOnClickListener {
                handleNavBack()
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            flow = webExportAccountSelectionViewModel.webExportAccountSelectionPreviewFlow,
            collection = webExportAccountSelectionPreviewCollector
        )
    }

    private fun updateUiWithPreview(preview: WebExportAccountSelectionPreview) {
        binding.continueButton.isEnabled = preview.isContinueButtonEnabled
        webExportAccountSelectionAdapter.submitList(preview.listItems)
        binding.successStateGroup.isVisible = preview.isEmptyStateVisible.not() && preview.isLoadingStateVisible.not()
        binding.emptyStateGroup.isVisible = preview.isEmptyStateVisible
    }

    private fun onContinueButtonClicked() {
        val selectedAccountAddressList = webExportAccountSelectionViewModel.getAllSelectedAccountAddressList()
        val qrCodeData = webExportAccountSelectionViewModel.getQRCodeData()
        nav(
                WebExportAccountSelectionFragmentDirections
                    .actionWebExportAccountSelectionFragmentToWebExportDomainNameConfirmationFragment(
                backupId = qrCodeData.backupId,
                encryptionKey = qrCodeData.encryptionKey,
                modificationKey = qrCodeData.modificationKey,
                accountList = selectedAccountAddressList.toTypedArray()
            )
        )
    }
}
