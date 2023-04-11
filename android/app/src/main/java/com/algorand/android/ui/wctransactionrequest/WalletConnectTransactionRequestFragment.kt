// TODO: We should remove this after function count decrease under 25
@file:Suppress("TooManyFunctions", "MaxLineLength")
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

package com.algorand.android.ui.wctransactionrequest

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.StringRes
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.NavController
import androidx.navigation.NavDirections
import androidx.navigation.fragment.NavHostFragment
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.WalletConnectRequestNavigationDirections
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.LedgerLoadingDialog
import com.algorand.android.databinding.FragmentWalletConnectTransactionRequestBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ConfirmationBottomSheetParameters
import com.algorand.android.models.ConfirmationBottomSheetResult
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TransactionRequestAction
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.ui.common.walletconnect.WalletConnectAppPreviewCardView
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionRequestFragmentDirections.Companion.actionWalletConnectTransactionRequestFragmentToWalletConnectTransactionFallbackBrowserSelectionNavigation
import com.algorand.android.utils.BaseDoubleButtonBottomSheet.Companion.RESULT_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.isBluetoothEnabled
import com.algorand.android.utils.navigateSafe
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.isFutureTransaction
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectTransactionRequestFragment :
    DaggerBaseFragment(R.layout.fragment_wallet_connect_transaction_request), TransactionRequestAction {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentWalletConnectTransactionRequestBinding::bind)
    private val transactionRequestViewModel: WalletConnectTransactionRequestViewModel by viewModels()

    private lateinit var walletConnectNavController: NavController

    private var ledgerLoadingDialog: LedgerLoadingDialog? = null

    private var walletConnectTransaction: WalletConnectTransaction? = null

    private val signResultObserver = Observer<WalletConnectSignResult> {
        handleSignResult(it)
    }

    private val requestResultObserver = Observer<Event<Resource<AnnotatedString>>> {
        it.consume()?.use(
            onSuccess = { handleSuccessfulTransaction() },
            onFailed = { navBack() }
        )
    }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            if (!walletConnectNavController.navigateUp()) {
                rejectRequest()
            }
        }
    }

    private val appPreviewListener = WalletConnectAppPreviewCardView.OnShowMoreClickListener { peerMeta, message ->
        nav(
            WalletConnectRequestNavigationDirections.actionGlobalWalletConnectDappMessageBottomSheet(
                message = message,
                peerMeta = peerMeta
            )
        )
    }

    private val bleRequestLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
        // Nothing to do
    }

    private val ledgerLoadingDialogListener = LedgerLoadingDialog.Listener { shouldStopResources ->
        hideLoading()
        if (shouldStopResources) {
            transactionRequestViewModel.stopAllResources()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        walletConnectTransaction = transactionRequestViewModel.transaction
        initNavController()
        handleNextNavigation()
        configureScreenStateByDestination()
        transactionRequestViewModel.setupWalletConnectSignManager(viewLifecycleOwner.lifecycle)
        initObservers()
        initUi()
    }

    private fun initNavController() {
        walletConnectNavController = (
            childFragmentManager.findFragmentById(binding.walletConnectNavigationHostFragment.id) as NavHostFragment
            ).navController
    }

    private fun handleNextNavigation() {
        val transactionListItem = transactionRequestViewModel.createTransactionListItems(
            walletConnectTransaction?.transactionList.orEmpty()
        )
        val (startDestinationId, startDestinationArgs) = transactionRequestViewModel
            .handleStartDestinationAndArgs(transactionListItem)

        with(walletConnectNavController) {
            setGraph(
                navInflater.inflate(R.navigation.transaction_request_navigation).apply {
                    setStartDestination(startDestinationId)
                },
                startDestinationArgs
            )
        }
    }

    private fun configureScreenStateByDestination() {
        val motionTransaction = binding.transactionRequestMotionLayout.getTransition(R.id.transactionRequestMotionScene)
        walletConnectNavController.addOnDestinationChangedListener { _, destination, _ ->
            when (destination.id) {
                R.id.walletConnectSingleTransactionFragment -> {
                    binding.transactionRequestMotionLayout.transitionToStart()
                    motionTransaction.isEnabled = false
                }
                else -> {
                    motionTransaction.isEnabled = true
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectTransactionRequestFragment) {
            useSavedStateValue<ConfirmationBottomSheetResult>(RESULT_KEY) { result ->
                if (result.isAccepted) confirmTransaction()
            }
        }
    }

    private fun initObservers() {
        with(transactionRequestViewModel) {
            requestResultLiveData.observe(viewLifecycleOwner, requestResultObserver)
            signResultLiveData.observe(viewLifecycleOwner, signResultObserver)
        }
    }

    private fun initUi() {
        val transaction = transactionRequestViewModel.transaction
        with(binding) {
            declineButton.setOnClickListener { rejectRequest() }
            confirmButton.apply {
                setOnClickListener { onConfirmClick() }
                val transactionCount = walletConnectTransaction?.transactionList?.size ?: 0
                text = resources.getQuantityString(R.plurals.confirm_transactions, transactionCount)
            }
        }
        walletConnectTransaction = transaction
        initAppPreview()
        rejectRequestOnBackPressed()
        checkIfShouldShowFirstRequestBottomSheet()
    }

    private fun confirmTransaction() {
        // TODO Check request id
        with(transactionRequestViewModel) {
            transaction?.let { transaction ->
                val isBluetoothNeeded = transactionRequestViewModel.isBluetoothNeededToSignTxns(transaction)
                if (isBluetoothNeeded) {
                    if (isBluetoothEnabled(bleRequestLauncher)) signTransactionRequest(transaction)
                } else {
                    signTransactionRequest(transaction)
                }
            }
        }
    }

    private fun onSigningSuccess(result: WalletConnectSignResult.Success) {
        transactionRequestViewModel.processWalletConnectSignResult(result)
    }

    private fun showLedgerWaitingForApprovalBottomSheet(
        ledgerName: String?,
        currentTransactionIndex: Int?,
        totalTransactionCount: Int?,
        isTransactionIndicatorVisible: Boolean
    ) {
        if (ledgerLoadingDialog == null) {
            ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog(
                ledgerName = ledgerName,
                listener = ledgerLoadingDialogListener,
                currentTransactionIndex = currentTransactionIndex,
                totalTransactionCount = totalTransactionCount,
                isTransactionIndicatorVisible = isTransactionIndicatorVisible
            )
            ledgerLoadingDialog?.showWithStateCheck(childFragmentManager, ledgerName.orEmpty())
        } else {
            ledgerLoadingDialog?.updateTransactionIndicator(transactionIndex = currentTransactionIndex)
        }
    }

    private fun onConfirmClick() {
        val currentTransaction = transactionRequestViewModel.transaction ?: return
        if (currentTransaction.isFutureTransaction()) {
            showFutureTransactionConfirmationBottomSheet(currentTransaction.requestId)
        } else {
            confirmTransaction()
        }
    }

    private fun showFutureTransactionConfirmationBottomSheet(requestId: Long) {
        val confirmationParams = ConfirmationBottomSheetParameters(
            titleResId = R.string.future_transaction_detected,
            descriptionText = getString(R.string.this_transaction_will_be),
            confirmationIdentifier = requestId
        )
        nav(MainNavigationDirections.actionGlobalConfirmationBottomSheet(confirmationParams))
    }

    private fun checkIfShouldShowFirstRequestBottomSheet() {
        if (transactionRequestViewModel.shouldShowFirstRequestBottomSheet()) {
            showFirstRequestBottomSheet()
        }
    }

    private fun showFirstRequestBottomSheet() {
        val navDirection = MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
            titleAnnotatedString = AnnotatedString(R.string.transaction_request_faq),
            drawableResId = R.drawable.ic_info,
            drawableTintResId = R.color.info_tint_color,
            descriptionAnnotatedString = AnnotatedString(R.string.external_applications_also)
        )
        nav(navDirection)
    }

    private fun handleSignResult(result: WalletConnectSignResult) {
        when (result) {
            WalletConnectSignResult.Loading -> showLoading()
            is WalletConnectSignResult.LedgerWaitingForApproval -> {
                with(result) {
                    showLedgerWaitingForApprovalBottomSheet(
                        ledgerName = ledgerName,
                        currentTransactionIndex = currentTransactionIndex,
                        totalTransactionCount = totalTransactionCount,
                        isTransactionIndicatorVisible = isTransactionIndicatorVisible
                    )
                }
            }
            is WalletConnectSignResult.Success -> onSigningSuccess(result)
            is WalletConnectSignResult.Error -> showSigningError(result)
            is WalletConnectSignResult.TransactionCancelledByLedger -> {
                showSigningError(result.error)
                rejectRequest()
            }
            is WalletConnectSignResult.LedgerScanFailed -> showLedgerNotFoundDialog()
            else -> {
                sendErrorLog("Unhandled else case in WalletConnectTransactionRequestFragment.handleSignResult")
            }
        }
    }

    private fun rejectRequestOnBackPressed() {
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    private fun rejectRequest() {
        transactionRequestViewModel.rejectRequest()
    }

    internal fun permissionDeniedOnTransaction(@StringRes errorResId: Int, @StringRes titleResId: Int) {
        showSigningError(WalletConnectSignResult.Error.Defined(AnnotatedString(errorResId), titleResId))
    }

    private fun initAppPreview() {
        walletConnectTransaction?.run {
            binding.dAppPreviewView.initPeerMeta(session.peerMeta, message, appPreviewListener)
        }
    }

    private fun showLedgerNotFoundDialog() {
        hideLoading()
        navigateToConnectionIssueBottomSheet()
    }

    private fun navigateToConnectionIssueBottomSheet() {
        nav(HomeNavigationDirections.actionGlobalLedgerConnectionIssueBottomSheet())
    }

    private fun hideLoading() {
        binding.progressBar.root.hide()
        ledgerLoadingDialog?.dismissAllowingStateLoss()
        ledgerLoadingDialog = null
    }

    private fun showLoading() {
        binding.progressBar.root.show()
    }

    private fun showSigningError(error: WalletConnectSignResult.Error) {
        hideLoading()
        val (title, errorMessage) = error.getMessage(requireContext())
        showGlobalError(errorMessage = errorMessage, title = title, tag = baseActivityTag)
    }

    override fun onNavigate(navDirections: NavDirections) {
        walletConnectNavController.navigateSafe(navDirections)
    }

    override fun onNavigateBack() {
        walletConnectNavController.navigateUp()
    }

    override fun showButtons() {
        with(binding) {
            confirmButton.show()
            declineButton.show()
        }
    }

    override fun hideButtons() {
        with(binding) {
            confirmButton.hide()
            declineButton.hide()
        }
    }

    override fun motionTransitionToEnd() {
        binding.transactionRequestMotionLayout.transitionToEnd()
    }

    private fun handleSuccessfulTransaction() {
        if (transactionRequestViewModel.shouldSkipConfirmation) {
            navBack()
        } else {
            nav(
                actionWalletConnectTransactionRequestFragmentToWalletConnectTransactionFallbackBrowserSelectionNavigation(
                        browserGroup = transactionRequestViewModel.fallbackBrowserGroupResponse,
                        peerMetaName = transactionRequestViewModel.peerMetaName
                    )
            )
        }
    }
}
