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

import android.app.Activity.RESULT_OK
import android.bluetooth.BluetoothAdapter
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
import com.algorand.android.ui.confirmation.ConfirmationBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.LOCATION_PERMISSION
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.isBluetoothEnabled
import com.algorand.android.utils.isLocationEnabled
import com.algorand.android.utils.isPermissionGranted
import com.algorand.android.utils.navigateSafe
import com.algorand.android.utils.requestLocationRequestFromUser
import com.algorand.android.utils.showEnableBluetoothPopup
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.isFutureTransaction
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectTransactionRequestFragment : DaggerBaseFragment(
    R.layout.fragment_wallet_connect_transaction_request
), LedgerLoadingDialog.Listener, TransactionRequestAction {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentWalletConnectTransactionRequestBinding::bind)
    private val transactionRequestViewModel: WalletConnectTransactionRequestViewModel by viewModels()

    private lateinit var walletConnectNavController: NavController

    private var ledgerLoadingDialog: LedgerLoadingDialog? = null

    private var walletConnectTransaction: WalletConnectTransaction? = null

    private val bleRequestLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
        if (it.resultCode == RESULT_OK) {
            confirmTransaction()
        } else {
            permissionDeniedOnTransaction(R.string.error_bluetooth_message, R.string.error_bluetooth_title)
        }
    }

    private val locationRequestLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) {
        if (it) {
            confirmTransaction()
        } else {
            permissionDeniedOnTransaction(
                R.string.error_location_message,
                R.string.error_permission_title
            )
        }
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
            if (!walletConnectNavController.navigateUp()) {
                rejectRequest()
            }
        }
    }

    private val appPreviewListener = WalletConnectAppPreviewCardView.OnShowMoreClickListener { peerMeta, message ->
        nav(
            WalletConnectRequestNavigationDirections.actionGlobalWalletConnectDappMessageBottomSheet(
                message,
                peerMeta
            )
        )
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
                    startDestination = startDestinationId
                }, startDestinationArgs
            )
        }
    }

    private fun configureScreenStateByDestination() {
        val motionTransaction = binding.transactionRequestMotionLayout.getTransition(R.id.transactionRequestMotionScene)
        walletConnectNavController.addOnDestinationChangedListener { _, destination, _ ->
            when (destination.id) {
                R.id.walletConnectSingleTransactionFragment -> {
                    binding.transactionRequestMotionLayout.transitionToStart()
                    motionTransaction.setEnable(false)
                }
                else -> {
                    motionTransaction.setEnable(true)
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectTransactionRequestFragment) {
            useSavedStateValue<ConfirmationBottomSheetResult>(ConfirmationBottomSheet.RESULT_KEY) { result ->
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
                setOnClickListener { showConfirmationBottomSheet() }
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
                if (isBluetoothNeededToSignTxns(transaction)) {
                    if (isBluetoothEnabled()) signTransactionRequest(transaction)
                } else {
                    signTransactionRequest(transaction)
                }
            }
        }
    }

    private fun onSigningSuccess(result: WalletConnectSignResult.Success) {
        transactionRequestViewModel.processWalletConnectSignResult(result)
    }

    private fun showLedgerWaitingForApprovalBottomSheet(ledgerName: String?) {
        ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog(ledgerName)
        ledgerLoadingDialog?.showWithStateCheck(childFragmentManager)
    }

    private fun arePermissionsTaken(): Boolean {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: return false
        return when {
            context?.isPermissionGranted(LOCATION_PERMISSION) != true -> {
                requestLocationRequestFromUser(locationRequestLauncher)
                false
            }
            bluetoothAdapter.isEnabled.not() -> {
                showEnableBluetoothPopup(bleRequestLauncher)
                false
            }
            context?.isLocationEnabled() != true -> {
                permissionDeniedOnTransaction(R.string.please_ensure, R.string.bluetooth_location_services)
                navBack()
                false
            }
            else -> true
        }
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

//    private fun initTransactionDetails(transaction: WalletConnectTransaction?) {
//        if (transaction == null) return
//        val transactionListItem = WalletConnectTransactionListItem.create(transaction)
//        transactionAdapter.submitList(transactionListItem)
//    }

    private fun checkIfShouldShowFirstRequestBottomSheet() {
        if (transactionRequestViewModel.shouldShowFirstRequestBottomSheet()) {
            showFirstRequestBottomSheet()
        }
    }

    private fun showFirstRequestBottomSheet() {
        val navDirection = MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
            titleAnnotatedString = AnnotatedString(R.string.transaction_request_faq),
            drawableResId = R.drawable.ic_info,
            drawableTintResId = R.color.infoTintColor,
            descriptionAnnotatedString = AnnotatedString(R.string.external_applications_also)
        )
        nav(navDirection)
    }

    private fun handleSignResult(result: WalletConnectSignResult) {
        when (result) {
            WalletConnectSignResult.Loading -> showLoading()
            is WalletConnectSignResult.LedgerWaitingForApproval -> {
                showLedgerWaitingForApprovalBottomSheet(result.ledgerName)
            }
            is WalletConnectSignResult.Success -> onSigningSuccess(result)
            is WalletConnectSignResult.Error -> showSigningError(result)
            is WalletConnectSignResult.TransactionCancelled -> rejectRequest()
            is WalletConnectSignResult.LedgerScanFailed -> showLedgerNotFoundDialog()
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
//
//    private fun showLedgerWaitingForApprovalBottomSheet() {
//        ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog()
//        ledgerLoadingDialog?.showWithStateCheck(childFragmentManager)
//    }

    override fun onLedgerLoadingCancelled() {
        hideLoading()
        transactionRequestViewModel.stopAllResources()
    }

    private fun hideLoading() {
        binding.progressBar.root.hide()
        ledgerLoadingDialog?.dismissAllowingStateLoss()
    }

    private fun showLoading() {
        binding.progressBar.root.show()
    }

    private fun showSigningError(error: WalletConnectSignResult.Error) {
        hideLoading()
        val (title, errorMessage) = error.getMessage(requireContext())
        showGlobalError(errorMessage, title)
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

    private fun navToSuccessfulTransactionDialog() {
        nav(
            HomeNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.your_transaction_is_being_processed),
                drawableResId = R.drawable.ic_info,
                drawableTintResId = R.color.infoTintColor,
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
