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

package com.algorand.android.ui.send.receiveraccount

import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.databinding.FragmentReceiverAccountSelectionBinding
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TargetUser
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.accountasset.domain.model.AccountAssetDetail
import com.algorand.android.ui.accountselection.AccountSelectionAdapter
import com.algorand.android.ui.send.receiveraccount.ReceiverAccountSelectionQrScannerFragment.Companion.ACCOUNT_ADDRESS_SCAN_RESULT_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getTextFromClipboard
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

// TODO: 18.03.2022 Use BaseAccountSelectionFragment after refactoring TransactionBaseFragment
@AndroidEntryPoint
class ReceiverAccountSelectionFragment : TransactionBaseFragment(R.layout.fragment_receiver_account_selection) {

    private val receiverAccountSelectionViewModel: ReceiverAccountSelectionViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow,
        titleResId = R.string.select_the_receiver_account
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentReceiverAccountSelectionBinding::bind)

    private val accountSelectionListener = object : AccountSelectionAdapter.Listener {
        override fun onAccountItemClick(publicKey: String) {
            receiverAccountSelectionViewModel.fetchToAccountInformation(publicKey)
        }

        override fun onContactItemClick(publicKey: String) {
            receiverAccountSelectionViewModel.fetchToAccountInformation(publicKey)
        }

        override fun onPasteItemClick(publicKey: String) {
            binding.searchView.text = publicKey
        }

        override fun onNftDomainItemClick(accountAddress: String, nftDomain: String, logoUrl: String?) {
            receiverAccountSelectionViewModel.fetchToAccountInformation(accountAddress, nftDomain, logoUrl)
        }
    }

    private val receiverAccountSelectionAdapter = AccountSelectionAdapter(accountSelectionListener)

    private val listCollector: suspend (List<BaseAccountSelectionListItem>?) -> Unit = { accountList ->
        receiverAccountSelectionAdapter.submitList(accountList)
        binding.screenStateView.isVisible = accountList?.isEmpty() == true
    }

    private val toAccountAddressValidationCollector: suspend (Event<Resource<String>>?) -> Unit = {
        it?.consume()?.use(
            onSuccess = { receiverAccountSelectionViewModel.fetchToAccountInformation(it) },
            onFailed = { handleError(it, binding.root) },
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    private val toAccountInformationCollector: suspend (Event<Resource<AccountAssetDetail>>?) -> Unit = {
        it?.consume()?.use(
            onSuccess = { receiverAccountSelectionViewModel.checkToAccountTransactionRequirements(it) },
            onFailed = { handleError(it, binding.root) },
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    private val toAccountTransactionRequirementsCollector: suspend (Event<Resource<TargetUser>>?) -> Unit = {
        it?.consume()?.use(
            onSuccess = ::handleNextNavigation,
            onFailed = { handleError(it, binding.root) },
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    private val windowFocusChangeListener = ViewTreeObserver.OnWindowFocusChangeListener { hasFocus ->
        if (hasFocus) updateLatestCopiedMessage()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    override fun onStart() {
        super.onStart()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.receiverAccountSelectionFragment) {
            useSavedStateValue<String>(ACCOUNT_ADDRESS_SCAN_RESULT_KEY) { accountAddress ->
                binding.searchView.text = accountAddress
            }
        }
    }

    private fun initUi() {
        with(binding) {
            listRecyclerView.adapter = receiverAccountSelectionAdapter
            searchView.setOnTextChanged(::onTextChangeListener)
            searchView.setOnCustomButtonClick(::onScanQrClick)
            nextButton.setOnClickListener { onNextButtonClick() }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            receiverAccountSelectionViewModel.selectableAccountFlow,
            listCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            receiverAccountSelectionViewModel.toAccountAddressValidationFlow,
            toAccountAddressValidationCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            receiverAccountSelectionViewModel.toAccountInformationFlow,
            toAccountInformationCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            receiverAccountSelectionViewModel.toAccountTransactionRequirementsFlow,
            toAccountTransactionRequirementsCollector
        )
    }

    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.addOnWindowFocusChangeListener(windowFocusChangeListener)
        }
        updateLatestCopiedMessage()
    }

    private fun onScanQrClick() {
        nav(
            ReceiverAccountSelectionFragmentDirections
                .actionReceiverAccountSelectionFragmentToReceiverAccountSelectionQrScannerFragment()
        )
    }

    private fun onNextButtonClick() {
        receiverAccountSelectionViewModel.checkIsGivenAddressValid(binding.searchView.text)
    }

    private fun handleNextNavigation(targetUser: TargetUser) {
        val assetTransaction = receiverAccountSelectionViewModel.assetTransaction
        val note = assetTransaction.xnote ?: assetTransaction.note
        val selectedAccountCacheData = receiverAccountSelectionViewModel.getFromAccountCachedData() ?: return
        val selectedAsset = receiverAccountSelectionViewModel.getSelectedAssetInformation() ?: return
        val minBalanceCalculatedAmount = assetTransaction.amount
        nav(
            ReceiverAccountSelectionFragmentDirections
                .actionReceiverAccountSelectionFragmentToAssetTransferPreviewFragment(
                    TransactionData.Send(
                        senderAccountAddress = selectedAccountCacheData.account.address,
                        senderAccountDetail = selectedAccountCacheData.account.detail,
                        senderAccountType = selectedAccountCacheData.account.type,
                        senderAuthAddress = selectedAccountCacheData.authAddress,
                        senderAccountName = selectedAccountCacheData.account.name,
                        isSenderRekeyedToAnotherAccount = selectedAccountCacheData.isRekeyedToAnotherAccount(),
                        minimumBalance = selectedAccountCacheData.getMinBalance(),
                        amount = minBalanceCalculatedAmount,
                        assetInformation = selectedAsset,
                        note = note,
                        targetUser = targetUser
                    )
                )
        )
    }

    private fun onTextChangeListener(charSequence: CharSequence?) {
        view?.let {
            receiverAccountSelectionViewModel.onSearchQueryUpdate(charSequence.toString())
            binding.nextButton.isVisible = charSequence.toString().isValidAddress()
        }
    }

    private fun showProgress() {
        binding.progressBar.root.show()
    }

    private fun hideProgress() {
        binding.progressBar.root.hide()
    }

    private fun updateLatestCopiedMessage() {
        receiverAccountSelectionViewModel.updateCopiedMessage(context?.getTextFromClipboard()?.toString())
    }

    override fun onPause() {
        super.onPause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.removeOnWindowFocusChangeListener(windowFocusChangeListener)
        }
    }
}
