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

package com.algorand.android.ui.wcarbitrarydatarequest

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
import com.algorand.android.WalletConnectArbitraryDataRequestNavigationDirections
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.LedgerLoadingDialog
import com.algorand.android.databinding.FragmentWalletConnectArbitraryDataRequestBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ArbitraryDataRequestAction
import com.algorand.android.models.ConfirmationBottomSheetResult
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.WalletConnectRequest.WalletConnectArbitraryDataRequest
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.ui.common.walletconnect.WalletConnectAppPreviewCardView
import com.algorand.android.utils.BaseDoubleButtonBottomSheet.Companion.RESULT_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.isBluetoothEnabled
import com.algorand.android.utils.navigateSafe
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WalletConnectArbitraryDataRequestFragment :
    DaggerBaseFragment(R.layout.fragment_wallet_connect_arbitrary_data_request), ArbitraryDataRequestAction {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentWalletConnectArbitraryDataRequestBinding::bind)
    private val arbitraryDataRequestViewModel: WalletConnectArbitraryDataRequestViewModel by viewModels()

    private lateinit var walletConnectNavController: NavController

    private var ledgerLoadingDialog: LedgerLoadingDialog? = null

    private var arbitraryData: WalletConnectArbitraryDataRequest? = null

    private val signResultObserver = Observer<WalletConnectSignResult> {
        handleSignResult(it)
    }

    private val requestResultObserver = Observer<Event<Resource<AnnotatedString>>> {
        it.consume()?.use(
            onSuccess = { arbitraryDataRequestViewModel.onArbitraryDataConfirmed() },
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
            WalletConnectArbitraryDataRequestNavigationDirections.actionGlobalWalletConnectDappMessageBottomSheet(
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
            arbitraryDataRequestViewModel.stopAllResources()
        }
    }

    private val navToLaunchBackNavigationEventCollector: suspend (
        Event<WalletConnectSessionIdentifier>?
    ) -> Unit = { event ->
        event?.consume()?.run {
            nav(
                WalletConnectArbitraryDataRequestFragmentDirections
                    .actionWalletConnectArbitraryDataRequestFragmentToWcRequestLaunchBackNavigation(
                        this,
                        arbitraryData
                    )
            )
        }
    }

    private val navBackEventCollector: suspend (
        Event<Unit>?
    ) -> Unit = { event ->
        event?.consume()?.let { navBack() }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        arbitraryData = arbitraryDataRequestViewModel.arbitraryData
        initNavController()
        handleNextNavigation()
        configureScreenStateByDestination()
        arbitraryDataRequestViewModel.setupWalletConnectSignManager(viewLifecycleOwner.lifecycle)
        initObservers()
        initUi()
    }

    private fun initNavController() {
        walletConnectNavController = (
                childFragmentManager.findFragmentById(binding.walletConnectNavigationHostFragment.id) as NavHostFragment
                ).navController
    }

    private fun handleNextNavigation() {
        val arbitraryDataListItem = arbitraryDataRequestViewModel.createArbitraryDataListItems(
            arbitraryData?.arbitraryDataList.orEmpty()
        )
        val (startDestinationId, startDestinationArgs) = arbitraryDataRequestViewModel
            .handleStartDestinationAndArgs(arbitraryDataListItem)

        with(walletConnectNavController) {
            setGraph(
                navInflater.inflate(R.navigation.arbitrary_data_request_navigation).apply {
                    setStartDestination(startDestinationId)
                },
                startDestinationArgs
            )
        }
    }

    private fun configureScreenStateByDestination() {
        val motionArbitraryData =
            binding.arbitraryDataRequestMotionLayout.getTransition(R.id.wcRequestMotionScene)
        walletConnectNavController.addOnDestinationChangedListener { _, destination, _ ->
            when (destination.id) {
                R.id.walletConnectSingleArbitraryDataFragment -> {
                    binding.arbitraryDataRequestMotionLayout.transitionToStart()
                    motionArbitraryData.isEnabled = false
                }

                else -> {
                    motionArbitraryData.isEnabled = true
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectArbitraryDataRequestFragment) {
            useSavedStateValue<ConfirmationBottomSheetResult>(RESULT_KEY) { result ->
                if (result.isAccepted) confirmArbitraryData()
            }
        }
    }

    private fun initObservers() {
        with(arbitraryDataRequestViewModel) {
            requestResultLiveData.observe(viewLifecycleOwner, requestResultObserver)
            signResultLiveData.observe(viewLifecycleOwner, signResultObserver)
            with(walletConnectArbitraryDataRequestPreviewFlow) {
                collectLatestOnLifecycle(
                    flow = map { it.navBackEvent },
                    collection = navBackEventCollector
                )
                collectLatestOnLifecycle(
                    flow = map { it.navToLaunchBackNavigationEvent },
                    collection = navToLaunchBackNavigationEventCollector
                )
            }
        }
    }

    private fun initUi() {
        val wcRequest = arbitraryDataRequestViewModel.arbitraryData
        with(binding) {
            declineButton.setOnClickListener { rejectRequest() }
            confirmButton.apply {
                setOnClickListener { onConfirmClick() }
                val arbitraryDataCount = wcRequest?.getListSize() ?: 0
                text = resources.getQuantityString(R.plurals.confirm_transactions, arbitraryDataCount)
            }
        }
        this.arbitraryData = arbitraryData
        initAppPreview()
        rejectRequestOnBackPressed()
        checkIfShouldShowFirstRequestBottomSheet()
    }

    private fun confirmArbitraryData() {
        // TODO Check request id
        with(arbitraryDataRequestViewModel) {
            arbitraryData?.let { arbitraryData ->
                val isBluetoothNeeded = arbitraryDataRequestViewModel.isBluetoothNeededToSignTxns(arbitraryData)
                if (!isBluetoothNeeded || isBluetoothEnabled(bleRequestLauncher)) {
                    signArbitraryDataRequest(arbitraryData)
                }
            }
        }
    }

    private fun onSigningSuccess(result: WalletConnectSignResult.Success) {
        arbitraryDataRequestViewModel.processWalletConnectSignResult(result)
    }

    private fun showLedgerWaitingForApprovalBottomSheet(
        ledgerName: String?,
        currentArbitraryDataIndex: Int?,
        totalArbitraryDataCount: Int?,
        isArbitraryDataIndicatorVisible: Boolean
    ) {
        if (ledgerLoadingDialog == null) {
            ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog(
                ledgerName = ledgerName,
                listener = ledgerLoadingDialogListener,
                currentTransactionIndex = currentArbitraryDataIndex,
                totalTransactionCount = totalArbitraryDataCount,
                isTransactionIndicatorVisible = isArbitraryDataIndicatorVisible
            )
            ledgerLoadingDialog?.showWithStateCheck(childFragmentManager, ledgerName.orEmpty())
        } else {
            ledgerLoadingDialog?.updateTransactionIndicator(transactionIndex = currentArbitraryDataIndex)
        }
    }

    private fun onConfirmClick() {
        arbitraryDataRequestViewModel.arbitraryData ?: return
        confirmArbitraryData()
    }

    private fun checkIfShouldShowFirstRequestBottomSheet() {
        if (arbitraryDataRequestViewModel.shouldShowFirstRequestBottomSheet()) {
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
            is WalletConnectSignResult.Success -> onSigningSuccess(result)
            is WalletConnectSignResult.Error -> showSigningError(result)
            is WalletConnectSignResult.TransactionCancelledByLedger -> {
                showSigningError(result.error)
                rejectRequest()
            }

            is WalletConnectSignResult.LedgerScanFailed -> showLedgerNotFoundDialog()
            else -> {
                sendErrorLog("Unhandled else case in WalletConnectArbitraryDataRequestFragment.handleSignResult")
            }
        }
    }

    private fun rejectRequestOnBackPressed() {
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    private fun rejectRequest() {
        arbitraryDataRequestViewModel.rejectRequest()
    }

    internal fun permissionDeniedOnArbitraryData(@StringRes errorResId: Int, @StringRes titleResId: Int) {
        showSigningError(WalletConnectSignResult.Error.Defined(AnnotatedString(errorResId), titleResId))
    }

    private fun initAppPreview() {
        arbitraryData?.run {
            binding.dAppPreviewView.initPeerMeta(session.peerMeta, "", appPreviewListener)
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
        binding.arbitraryDataRequestMotionLayout.transitionToEnd()
    }
}
