/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.wctransactionrequest

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.annotation.StringRes
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.WalletConnectRequestNavigationDirections
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.LedgerLoadingDialog
import com.algorand.android.databinding.FragmentWalletConnectTransactionRequestBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.ConfirmationBottomSheetParameters
import com.algorand.android.models.ConfirmationBottomSheetResult
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.ui.confirmation.ConfirmationBottomSheet
import com.algorand.android.utils.BLE_OPEN_REQUEST_CODE
import com.algorand.android.utils.Event
import com.algorand.android.utils.LOCATION_PERMISSION_REQUEST_CODE
import com.algorand.android.utils.Resource
import com.algorand.android.utils.isBluetoothEnabled
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.getWalletConnectTransactionRequestDirection
import com.algorand.android.utils.walletconnect.isFutureTransaction
import dagger.hilt.android.AndroidEntryPoint
import kotlin.properties.Delegates

@AndroidEntryPoint
class WalletConnectTransactionRequestFragment :
    DaggerBaseFragment(R.layout.fragment_wallet_connect_transaction_request), LedgerLoadingDialog.Listener {

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.unsigned_transactions)

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentWalletConnectTransactionRequestBinding::bind)
    private val transactionRequestViewModel: WalletConnectTransactionRequestViewModel by viewModels()
    private var ledgerLoadingDialog: LedgerLoadingDialog? = null

    private var walletConnectTransaction: WalletConnectTransaction? by Delegates.observable(null) { _, _, txn ->
        initTransactionDetails(txn)
    }

    private val signResultObserver = Observer<WalletConnectSignResult> {
        handleSignResult(it)
    }

    private val requestResultObserver = Observer<Event<Resource<AnnotatedString>>> {
        it.consume()?.use(
            onSuccess = {
                navBack()
                navToSuccessfulTransactionDialog()
            },
            onFailed = { navBack() }
        )
    }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            rejectRequest()
        }
    }

    private val transactionAdapterListener = object : WalletConnectTransactionAdapter.Listener {
        override fun onMultipleTransactionClick(transactionList: List<BaseWalletConnectTransaction>) {
            val txnArray = transactionList.toTypedArray()
            nav(
                WalletConnectTransactionRequestFragmentDirections
                    .actionWalletConnectTransactionRequestFragmentToWalletConnectAtomicTransactionsFragment(
                        txnArray
                    )
            )
        }

        override fun onSingleTransactionClick(transaction: BaseWalletConnectTransaction) {
            val navDirection = getWalletConnectTransactionRequestDirection(transaction) ?: return
            nav(navDirection)
        }

        override fun onShowMoreMessageClick(peerMeta: WalletConnectPeerMeta, message: String) {
            nav(
                WalletConnectRequestNavigationDirections
                    .actionGlobalWalletConnectDappMessageBottomSheet(message, peerMeta)
            )
        }
    }

    private val transactionAdapter = WalletConnectTransactionAdapter(transactionAdapterListener)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        transactionRequestViewModel.setupWalletConnectSignManager(viewLifecycleOwner.lifecycle)
        initObservers()
        initUi()
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectTransactionRequestFragment) {
            useSavedStateValue<ConfirmationBottomSheetResult>(ConfirmationBottomSheet.RESULT_KEY) { result ->
                if (result.isAccepted) confirmTransaction()
            }
        }
    }

    override fun onLedgerLoadingCancelled() {
        hideLoading()
        transactionRequestViewModel.stopAllResources()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
                confirmTransaction()
            } else {
                permissionDeniedOnTransaction(R.string.error_location_message, R.string.error_permission_title)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == BLE_OPEN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                confirmTransaction()
            } else {
                permissionDeniedOnTransaction(R.string.error_bluetooth_message, R.string.error_bluetooth_title)
            }
        }
    }

    private fun confirmTransaction() {
        // TODO Check request id
        with(transactionRequestViewModel) {
            transaction?.let { transaction ->
                if (isBluetoothNeededToSignTxns(transaction)) {
                    if (isBluetoothEnabled()) signTransactionRequest(transaction)
                } else {
                    signTransactionRequest(transaction)
                }
            }
        }
    }

    private fun initObservers() {
        with(transactionRequestViewModel) {
            requestResultLiveData.observe(viewLifecycleOwner, requestResultObserver)
            signResultLiveData.observe(viewLifecycleOwner, signResultObserver)
        }
    }

    internal fun permissionDeniedOnTransaction(@StringRes errorResId: Int, @StringRes titleResId: Int) {
        showSigningError(WalletConnectSignResult.Error.Defined(AnnotatedString(errorResId), titleResId))
    }

    private fun initUi() {
        val transaction = transactionRequestViewModel.transaction
        with(binding) {
            requestsRecyclerView.adapter = transactionAdapter
            declineButton.setOnClickListener { rejectRequest() }
            confirmButton.apply {
                setOnClickListener { showConfirmationBottomSheet() }
                val transactionCount = transaction?.transactionList?.size ?: 0
                text = resources.getQuantityString(R.plurals.confirm_transactions, transactionCount)
            }
        }
        walletConnectTransaction = transaction
        rejectRequestOnBackPressed()
        checkIfShouldShowFirstRequestBottomSheet()
    }

    private fun showConfirmationBottomSheet() {
        val confirmationText = getString(R.string.once_confirmed_the_connected_application)
        transactionRequestViewModel.transaction?.let { transaction ->
            val descriptionText = if (transaction.isFutureTransaction()) {
                StringBuilder(getString(R.string.this_transaction_will_be))
                    .append(" ")
                    .append(confirmationText)
                    .toString()
            } else {
                confirmationText
            }
            val confirmationParams = ConfirmationBottomSheetParameters(
                titleResId = R.string.are_you_sure_question_mark,
                descriptionText = descriptionText,
                confirmationIdentifier = transaction.requestId
            )
            nav(MainNavigationDirections.actionGlobalConfirmationBottomSheet(confirmationParams))
        }
    }

    private fun initTransactionDetails(transaction: WalletConnectTransaction?) {
        if (transaction == null) return
        val transactionListItem = WalletConnectTransactionListItem.create(transaction)
        transactionAdapter.submitList(transactionListItem)
    }

    private fun rejectRequestOnBackPressed() {
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    private fun rejectRequest() {
        transactionRequestViewModel.rejectRequest()
    }

    private fun checkIfShouldShowFirstRequestBottomSheet() {
        if (transactionRequestViewModel.shouldShowFirstRequestBottomSheet()) {
            showFirstRequestBottomSheet()
        }
    }

    private fun showFirstRequestBottomSheet() {
        val navDirection = MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
            titleResId = R.string.warning,
            drawableResId = R.drawable.ic_error_warning,
            buttonTextResId = R.string.got_it,
            descriptionAnnotatedString = AnnotatedString(R.string.the_following_transaction_requests),
            imageBackgroundTintResId = R.color.orange_F0
        )
        nav(navDirection)
    }

    private fun handleSignResult(result: WalletConnectSignResult) {
        when (result) {
            WalletConnectSignResult.Loading -> showLoading()
            WalletConnectSignResult.LedgerWaitingForApproval -> showLedgerWaitingForApprovalBottomSheet()
            is WalletConnectSignResult.Success -> onSigningSuccess(result)
            is WalletConnectSignResult.Error -> showSigningError(result)
            is WalletConnectSignResult.TransactionCancelled -> rejectRequest()
            is WalletConnectSignResult.LedgerScanFailed -> showLedgerNotFoundDialog()
        }
    }

    private fun onSigningSuccess(result: WalletConnectSignResult.Success) {
        transactionRequestViewModel.processWalletConnectSignResult(result)
    }

    private fun showLedgerNotFoundDialog() {
        hideLoading()
        navigateToConnectionIssueBottomSheet()
    }

    private fun navigateToConnectionIssueBottomSheet() {
        nav(
            WalletConnectTransactionRequestFragmentDirections
                .actionWalletConnectTransactionRequestFragmentToLedgerConnectionIssueBottomSheet()
        )
    }

    private fun showLedgerWaitingForApprovalBottomSheet() {
        ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog()
        ledgerLoadingDialog?.showWithStateCheck(childFragmentManager)
    }

    private fun hideLoading() {
        binding.progressBar.loadingProgressBar.visibility = View.GONE
        ledgerLoadingDialog?.dismissAllowingStateLoss()
    }

    private fun showLoading() {
        binding.progressBar.loadingProgressBar.visibility = View.VISIBLE
    }

    private fun showSigningError(error: WalletConnectSignResult.Error) {
        hideLoading()
        val (title, errorMessage) = error.getMessage(requireContext())
        showGlobalError(errorMessage, title)
    }

    private fun navToSuccessfulTransactionDialog() {
        nav(
            HomeNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleResId = R.string.your_transaction_is_being_processed,
                drawableResId = R.drawable.ic_check_sign,
                buttonBackgroundTintResId = R.color.secondaryButtonBackgroundColor,
                buttonTextColorResId = R.color.primaryTextColor,
                buttonTextResId = R.string.close,
                descriptionAnnotatedString = AnnotatedString(
                    R.string.the_transaction_has_been_signed,
                    replacementList = listOf(
                        Pair(
                            "peer_name",
                            walletConnectTransaction?.session?.peerMeta?.name.orEmpty()
                        )
                    )
                )
            )
        )
    }
}
