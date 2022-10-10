/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.send.senderaccount

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.databinding.FragmentSenderAccountSelectionBinding
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SenderAccountSelectionPreview
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TargetUser
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.ui.accountselection.AccountSelectionAdapter
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger

@AndroidEntryPoint
class SenderAccountSelectionFragment : TransactionBaseFragment(R.layout.fragment_sender_account_selection) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.select_account,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val senderAccountSelectionViewModel: SenderAccountSelectionViewModel by viewModels()

    private val binding by viewBinding(FragmentSenderAccountSelectionBinding::bind)

    private val listener = object : AccountSelectionAdapter.Listener {
        override fun onAccountItemClick(publicKey: String) {
            senderAccountSelectionViewModel.fetchFromAccountInformation(publicKey)
        }
    }

    private val senderAccountSelectionAdapter = AccountSelectionAdapter(listener)

    private val senderAccountSelectionPreviewCollector: suspend (SenderAccountSelectionPreview) -> Unit = {
        updateUiWithPreview(it)
    }

    override val transactionFragmentListener = object : TransactionFragmentListener {

        override fun onSignTransactionLoading() {
            showProgress()
        }

        override fun onSignTransactionLoadingFinished() {
            hideProgress()
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            when (signedTransactionDetail) {
                is SignedTransactionDetail.Send -> {
                    nav(
                        SenderAccountSelectionFragmentDirections
                            .actionSenderAccountSelectionFragmentToAssetTransferPreviewFragment(signedTransactionDetail)
                    )
                }
                else -> {
                    sendErrorLog("Unhandled else case in SenderAccountSelectionFragment.transactionFragmentListener")
                }
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        showTransactionTipsIfNeed()
        initObservers()
        binding.accountsToSendRecyclerView.adapter = senderAccountSelectionAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            flow = senderAccountSelectionViewModel.senderAccountSelectionPreviewFlow,
            collection = senderAccountSelectionPreviewCollector
        )
    }

    // If user enter Send Algo flow via deeplink or qr code, then we have to check asset transaction params then
    // we should navigate user to proper screen
    private fun handleNextNavigation(accountInformation: AccountInformation) {
        val assetTransaction = senderAccountSelectionViewModel.assetTransaction.copy(
            senderAddress = accountInformation.address
        )
        // TODO: 26.08.2022 Remove all those checks from Fragment, and handle them in usecase, only call events here
        when {
            assetTransaction.assetId == -1L -> {
                SenderAccountSelectionFragmentDirections
                    .actionSenderAccountSelectionFragmentToAssetSelectionFragment(assetTransaction)
            }
            assetTransaction.amount == BigInteger.ZERO -> {
                SenderAccountSelectionFragmentDirections
                    .actionSenderAccountSelectionFragmentToAssetTransferAmountFragment(assetTransaction)
            }
            assetTransaction.receiverUser == null -> {
                SenderAccountSelectionFragmentDirections
                    .actionSenderAccountSelectionFragmentToReceiverAccountSelectionFragment(assetTransaction)
            }
            else -> {
                senderAccountSelectionViewModel.signTransaction(accountInformation.address)
                return
            }
        }.apply { nav(this) }
    }

    private fun signTransaction(assetTransaction: AssetTransaction, senderAddress: String) {
        val note = assetTransaction.xnote ?: assetTransaction.note
        val selectedAccountCacheData = senderAccountSelectionViewModel.getAccountCachedData(senderAddress) ?: return
        val selectedAsset = senderAccountSelectionViewModel.getAssetInformation(senderAddress) ?: return
        val targetUser = TargetUser(
            assetTransaction.receiverUser ?: return,
            assetTransaction.receiverUser.publicKey,
            selectedAccountCacheData
        )
        sendTransaction(
            TransactionData.Send(
                selectedAccountCacheData,
                assetTransaction.amount,
                selectedAsset,
                note,
                targetUser
            )
        )
    }

    private fun updateUiWithPreview(preview: SenderAccountSelectionPreview) {
        with(preview) {
            binding.progressBar.root.isVisible = isLoading
            senderAccountSelectionAdapter.submitList(accountList)
            binding.screenStateView.isVisible = isEmptyStateVisible

            fromAccountInformationSuccessEvent?.consume()?.let { handleNextNavigation(it) }
            fromAccountInformationErrorEvent?.consume()?.let { handleError(it.getAsResourceError(), binding.root) }
            signTransactionSuccessEvent?.consume()?.let {
                signTransaction(
                    senderAddress = it.first,
                    assetTransaction = it.second
                )
            }
            signTransactionErrorEvent?.consume()?.let { showGlobalError(getString(it.second), getString(it.first)) }
        }
    }

    private fun showProgress() {
        binding.progressBar.root.show()
    }

    private fun hideProgress() {
        binding.progressBar.root.hide()
    }

    private fun showTransactionTipsIfNeed() {
        if (senderAccountSelectionViewModel.shouldShowTransactionTips()) {
            nav(
                SenderAccountSelectionFragmentDirections
                    .actionSenderAccountSelectionFragmentToTransactionTipsBottomSheet()
            )
        }
    }
}
