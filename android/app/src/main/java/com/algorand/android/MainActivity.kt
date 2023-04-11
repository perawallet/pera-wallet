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

@file:Suppress("TooManyFunctions") // TODO: We should remove this after function count decrease under 25

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

package com.algorand.android

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.annotation.StringRes
import androidx.core.view.forEach
import androidx.lifecycle.Observer
import androidx.lifecycle.coroutineScope
import androidx.navigation.NavDirections
import androidx.navigation.fragment.NavHostFragment
import com.algorand.android.core.TransactionManager
import com.algorand.android.customviews.CoreActionsTabBarView
import com.algorand.android.customviews.LedgerLoadingDialog
import com.algorand.android.customviews.alertview.ui.AlertDialogQueueManager
import com.algorand.android.customviews.alertview.ui.CustomAlertDialog
import com.algorand.android.customviews.customsnackbar.CustomSnackbar
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AlertMetadata
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.AssetOperationResult
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.Node
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.modules.autolockmanager.ui.AutoLockManager
import com.algorand.android.modules.dapp.moonpay.domain.model.MoonpayTransactionStatus
import com.algorand.android.modules.deeplink.DeepLinkParser
import com.algorand.android.modules.deeplink.domain.model.BaseDeepLink
import com.algorand.android.modules.deeplink.domain.model.NotificationGroupType
import com.algorand.android.modules.deeplink.ui.DeeplinkHandler
import com.algorand.android.modules.firebase.token.FirebaseTokenManager
import com.algorand.android.modules.firebase.token.model.FirebaseTokenResult
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewFragment
import com.algorand.android.modules.qrscanning.QrScannerViewModel
import com.algorand.android.modules.walletconnect.connectionrequest.ui.WalletConnectConnectionBottomSheet
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WCSessionRequestResult
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import com.algorand.android.modules.webexport.common.data.model.WebExportQrCode
import com.algorand.android.ui.accountselection.receive.ReceiveAccountSelectionFragment
import com.algorand.android.ui.lockpreference.AutoLockSuggestionManager
import com.algorand.android.usecase.IsAccountLimitExceedUseCase.Companion.MAX_NUMBER_OF_ACCOUNTS
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.logTapReceive
import com.algorand.android.utils.analytics.logTapSend
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getSafeParcelableExtra
import com.algorand.android.utils.inappreview.InAppReviewManager
import com.algorand.android.utils.navigateSafe
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import com.algorand.android.utils.walletconnect.WalletConnectUrlHandler
import com.algorand.android.utils.walletconnect.WalletConnectViewModel
import com.google.firebase.analytics.FirebaseAnalytics
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlin.properties.Delegates

@AndroidEntryPoint
class MainActivity :
    CoreMainActivity(),
    WalletConnectConnectionBottomSheet.Callback,
    ReceiveAccountSelectionFragment.ReceiveAccountSelectionFragmentListener {

    val mainViewModel: MainViewModel by viewModels()
    private val walletConnectViewModel: WalletConnectViewModel by viewModels()
    private val qrScannerViewModel: QrScannerViewModel by viewModels()

    private var pendingIntent: Intent? = null

    private var ledgerLoadingDialog: LedgerLoadingDialog? = null

    @Inject
    lateinit var transactionManager: TransactionManager

    @Inject
    lateinit var firebaseAnalytics: FirebaseAnalytics

    @Inject
    lateinit var inAppReviewManager: InAppReviewManager

    @Inject
    lateinit var autoLockSuggestionManager: AutoLockSuggestionManager

    @Inject
    lateinit var errorProvider: WalletConnectTransactionErrorProvider

    @Inject
    lateinit var firebaseTokenManager: FirebaseTokenManager

    @Inject
    lateinit var autoLockManager: AutoLockManager

    @Inject
    lateinit var deepLinkParser: DeepLinkParser

    private val isAppUnlocked: Boolean
        get() = autoLockManager.isAppUnlocked

    private val autoLockManagerListener = object : AutoLockManager.AutoLockManagerListener {
        override fun onLock() {
            nav(MainNavigationDirections.actionGlobalLockFragment())
        }

        override fun onUnlock() {
            nav(MainNavigationDirections.actionGlobalLockFragmentPop())
            handleRedirection()
        }
    }

    private val alertViewDialog by lazy { CustomAlertDialog(this) }

    private var isAssetSetupCompleted: Boolean by Delegates.observable(false) { _, oldValue, newValue ->
        if (oldValue != newValue && newValue && isAppUnlocked) {
            handleRedirection()
        }
    }

    private val addAssetResultObserver = Observer<Event<Resource<AssetOperationResult>>> {
        it.consume()?.use(
            onSuccess = { assetOperationResult -> showAssetOperationForegroundNotification(assetOperationResult) },
            onFailed = { error -> showGlobalError(errorMessage = error.parse(this), tag = activityTag) }
        )
    }

    private val assetSetupCompletedObserver = Observer<AccountCacheStatus> {
        isAssetSetupCompleted = it == AccountCacheStatus.DONE
        binding.coreActionsTabBarView.setCoreActionButtonEnabled(it == AccountCacheStatus.DONE)
    }

    private val newNotificationObserver = Observer<Event<NotificationMetadata>> {
        it?.consume()?.let { newNotificationData ->
            if (!isAppUnlocked) {
                return@let
            }
            handleNewNotification(newNotificationData)
        }
    }

    private fun handleNewNotification(newNotificationData: NotificationMetadata) {
        val rawDeepLink = deepLinkParser.parseDeepLink(newNotificationData.url.orEmpty())
        when (val baseDeepLink = BaseDeepLink.create(rawDeepLink)) {
            is BaseDeepLink.NotificationDeepLink -> handleNotificationWithDeepLink(newNotificationData, baseDeepLink)
            else -> showForegroundNotification(newNotificationData)
        }
    }

    private fun handleNotificationWithDeepLink(
        newNotificationData: NotificationMetadata,
        deeplink: BaseDeepLink.NotificationDeepLink
    ) {
        when (deeplink.notificationGroupType) {
            NotificationGroupType.OPT_IN -> handleAssetOptInRequestDeepLink(deeplink.address, deeplink.assetId)
            else -> showForegroundNotification(newNotificationData)
        }
    }

    private fun handleAssetOptInRequestDeepLink(accountAddress: String, assetId: Long) {
        if (!accountDetailUseCase.isThereAnyAccountWithPublicKey(accountAddress)) {
            showGlobalError(getString(R.string.you_cannot_take))
            return
        }

        val assetAction = AssetAction(publicKey = accountAddress, assetId = assetId)
        nav(
            HomeNavigationDirections.actionGlobalAssetAdditionActionNavigation(
                assetAction = assetAction
            )
        )
    }

    private fun handleAssetTransactionDeepLink(accountAddress: String, assetId: Long) {
        if (!accountDetailUseCase.isThereAnyAccountWithPublicKey(accountAddress)) {
            showGlobalError(getString(R.string.you_cannot_take))
            return
        }

        nav(
            HomeNavigationDirections.actionGlobalAssetProfileNavigation(
                assetId = assetId,
                accountAddress = accountAddress
            )
        )
    }

    private val invalidTransactionCauseObserver = Observer<Event<Resource.Error.Local>> { cause ->
        cause.consume()?.let { onInvalidWalletConnectTransacitonReceived(it) }
    }

    private val swapNavigationDirectionCollector: suspend (Event<NavDirections>?) -> Unit = {
        it?.consume()?.let { navDirection -> nav(navDirection) }
    }

    private val walletConnectUrlHandlerListener = object : WalletConnectUrlHandler.Listener {
        override fun onValidWalletConnectUrl(url: String) {
            showProgress()
            walletConnectViewModel.connectToSessionByUrl(url)
        }

        override fun onInvalidWalletConnectUrl(errorResId: Int) {
            qrScannerViewModel.setQrCodeInProgress(false)
            showGlobalError(errorMessage = getString(errorResId), tag = activityTag)
        }
    }

    private val deepLinkHandlerListener = object : DeeplinkHandler.Listener {

        override fun onAssetTransferDeepLink(assetTransaction: AssetTransaction): Boolean {
            return true.also {
                navController.navigateSafe(HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransaction))
            }
        }

        override fun onAccountAddressDeeplink(accountAddress: String, label: String?): Boolean {
            return true.also {
                navController.navigateSafe(
                    HomeNavigationDirections.actionGlobalAccountsAddressScanActionBottomSheet(accountAddress, label)
                )
            }
        }

        override fun onWalletConnectConnectionDeeplink(wcUrl: String): Boolean {
            return true.also {
                handleWalletConnectUrl(wcUrl)
            }
        }

        override fun onAssetTransferWithNotOptInDeepLink(assetId: Long): Boolean {
            return true.also {
                val assetAction = AssetAction(assetId = assetId)
                navController.navigateSafe(
                    HomeNavigationDirections.actionGlobalUnsupportedAddAssetTryLaterBottomSheet(assetAction)
                )
            }
        }

        override fun onMoonpayResultDeepLink(accountAddress: String, txnStatus: String, txnId: String?): Boolean {
            mainViewModel.logMoonpayAlgoBuyCompletedEvent()
            return true.also {
                navController.navigateSafe(
                    HomeNavigationDirections.actionGlobalMoonpayResultNavigation(
                        walletAddress = accountAddress,
                        transactionStatus = MoonpayTransactionStatus.getByValueOrDefault(txnStatus)
                    )
                )
            }
        }

        override fun onWebExportQrCodeDeepLink(webExportQrCode: WebExportQrCode): Boolean {
            return true.also {
                nav(
                    HomeNavigationDirections.actionGlobalWebExportNavigation(
                        backupId = webExportQrCode.backupId,
                        modificationKey = webExportQrCode.modificationKey,
                        encryptionKey = webExportQrCode.encryptionKey
                    )
                )
            }
        }

        override fun onAssetOptInDeepLink(assetAction: AssetAction): Boolean {
            return true.also {
                navController.navigateSafe(
                    HomeNavigationDirections.actionGlobalAddAssetAccountSelectionFragment(assetAction.assetId)
                )
            }
        }

        override fun onNotificationDeepLink(
            accountAddress: String,
            assetId: Long,
            notificationGroupType: NotificationGroupType
        ): Boolean {
            when (notificationGroupType) {
                NotificationGroupType.TRANSACTIONS -> handleAssetTransactionDeepLink(accountAddress, assetId)
                NotificationGroupType.OPT_IN -> handleAssetOptInRequestDeepLink(accountAddress, assetId)
            }
            return true
        }

        override fun onUndefinedDeepLink(undefinedDeeplink: BaseDeepLink.UndefinedDeepLink) {
            // TODO show error after discussing with the team
        }

        override fun onDeepLinkNotHandled(deepLink: BaseDeepLink) {
            // TODO show error after discussing with the team
        }
    }

    private val transactionManagerResultObserver = Observer<Event<TransactionManagerResult>?> {
        it?.consume()?.let { result ->
            when (result) {
                is TransactionManagerResult.Success -> {
                    hideLedgerLoadingDialog()
                    val signedTransactionDetail = result.signedTransactionDetail
                    if (signedTransactionDetail is SignedTransactionDetail.AssetOperation) {
                        mainViewModel.sendAssetOperationSignedTransaction(signedTransactionDetail)
                    }
                }
                is TransactionManagerResult.Error.GlobalWarningError -> {
                    hideLedgerLoadingDialog()
                    val (title, errorMessage) = result.getMessage(this)
                    showGlobalError(title = title, errorMessage = errorMessage, tag = activityTag)
                }
                is TransactionManagerResult.Error.SnackbarError -> {
                    hideLedgerLoadingDialog()
                    CustomSnackbar.Builder()
                        .setTitleTextResId(result.titleResId)
                        .setDescriptionTextResId(result.descriptionResId)
                        .setActionButtonTextResId(result.buttonTextResId)
                        .setActionButtonClickListener {
                            retryLatestAssetAdditionTransaction().also { dismiss() }
                        }
                        .build()
                        .show(binding.root)
                }
                is TransactionManagerResult.LedgerWaitingForApproval -> showLedgerLoadingDialog(result.bluetoothName)
                is TransactionManagerResult.Loading -> showProgress()
                is TransactionManagerResult.LedgerScanFailed -> {
                    hideLedgerLoadingDialog()
                    navigateToConnectionIssueBottomSheet()
                }
                else -> {
                    sendErrorLog("Unhandled else case in transactionManagerResultLiveData")
                }
            }
        }
    }

    private val ledgerLoadingDialogListener = LedgerLoadingDialog.Listener { shouldStopResources ->
        hideLedgerLoadingDialog()
        if (shouldStopResources) {
            transactionManager.manualStopAllResources()
        }
    }

    private val alertDialogQueueManagerListener = object : AlertDialogQueueManager.Listener {
        override fun onDisplayAlertView(alertMetadata: AlertMetadata) {
            alertViewDialog.displayAlertView(alertMetadata)
        }

        override fun onDismissAlertView() {
            alertViewDialog.dismissCurrentAlertView()
        }

        override fun onQueueCompleted() {
            alertViewDialog.cancel()
        }
    }

    private val customAlertDialogListener = object : CustomAlertDialog.Listener {
        override fun onTransactionAlertClick(uri: String) {
            handleDeepLink(uri)
        }

        override fun onAlertViewHidden() {
            alertDialogQueueManager.showNextAlert()
        }

        override fun onAlertViewCancelled() {
            alertDialogQueueManager.removeHeadOfQueue()
        }
    }

    private val activeNodeCollector: suspend (Node?) -> Unit = { activatedNode ->
        checkIfConnectedToTestNetOrBetaNet(activatedNode)
    }

    private val firebaseTokenResultCollector: suspend (FirebaseTokenResult) -> Unit = { firebaseTokenResult ->
        when (firebaseTokenResult) {
            FirebaseTokenResult.TokenLoaded -> onNewNodeActivated()
            FirebaseTokenResult.TokenLoading -> onNewNodeLoading()
        }
    }

    private fun retryLatestAssetAdditionTransaction() {
        mainViewModel.getLatestAddAssetTransaction()?.let { transactionData ->
            sendAssetOperationTransaction(transactionData)
        }
    }

    private val sessionResultFlowCollector: suspend (Event<Resource<WalletConnectSessionProposal>>) -> Unit = { event ->
        event.consume()?.use(
            onSuccess = ::onSessionConnected,
            onFailed = ::onSessionFailed,
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    private fun onSessionConnected(wcSessionRequest: WalletConnectSessionProposal) {
        nav(
            HomeNavigationDirections
                .actionGlobalWalletConnectConnectionNavigation(wcSessionRequest, isBasePeraWebViewFragmentActive())
        )
    }

    private fun onSessionFailed(error: Resource.Error) {
        qrScannerViewModel.setQrCodeInProgress(false)
        val errorMessage = error.parse(this)
        showGlobalError(errorMessage = errorMessage, tag = activityTag)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        mainViewModel.setDeepLinkHandlerListener(deepLinkHandlerListener)
        autoLockManager.setListener(autoLockManagerListener)
        setupCoreActionsTabBarView()

        alertDialogQueueManager.apply {
            setScope(lifecycle.coroutineScope)
            setListener(alertDialogQueueManagerListener)
        }

        alertViewDialog.setListener(customAlertDialogListener)

        initObservers()

        if (savedInstanceState == null) {
            handleDeeplinkAndNotificationNavigation()
        }

        mainViewModel.increseAppOpeningCount()
    }

    override fun onMenuItemClicked(item: MenuItem) {
        when (item.itemId) {
            R.id.accountsFragment -> mainViewModel.logBottomNavAccountsTapEvent()
        }
    }

    private fun showAssetOperationForegroundNotification(assetOperationResult: AssetOperationResult) {
        val safeAssetName = assetOperationResult.assetName.getName(resources)
        val messageDescription = getString(assetOperationResult.resultTitleResId, safeAssetName)
        showAlertSuccess(title = messageDescription, successMessage = null, tag = activityTag)
    }

    override fun onAccountSelected(publicKey: String) {
        val qrCodeTitle = getString(R.string.qr_code)
        nav(HomeNavigationDirections.actionGlobalShowQrNavigation(qrCodeTitle, publicKey))
    }

    private fun initObservers() {
        peraNotificationManager.newNotificationLiveData.observe(this, newNotificationObserver)

        mainViewModel.assetOperationResultLiveData.observe(this, addAssetResultObserver)

        transactionManager.transactionManagerResultLiveData.observe(this, transactionManagerResultObserver)

        mainViewModel.accountBalanceSyncStatus.observe(this, assetSetupCompletedObserver)

        walletConnectViewModel.requestLiveData.observe(this, ::handleWalletConnectTransactionRequest)

        walletConnectViewModel.invalidTransactionCauseLiveData.observe(this, invalidTransactionCauseObserver)

        collectLatestOnLifecycle(
            mainViewModel.swapNavigationResultFlow,
            swapNavigationDirectionCollector
        )

        collectOnLifecycle(
            flow = walletConnectViewModel.sessionResultFlow,
            collection = sessionResultFlowCollector
        )

        walletConnectViewModel.setWalletConnectSessionTimeoutListener(::onWalletConnectSessionTimedOut)

        collectLatestOnLifecycle(
            flow = mainViewModel.activeNodeFlow,
            collection = activeNodeCollector
        )

        collectLatestOnLifecycle(
            flow = firebaseTokenManager.firebaseTokenResultFlow,
            collection = firebaseTokenResultCollector
        )
    }

    private fun navigateToConnectionIssueBottomSheet() {
        nav(HomeNavigationDirections.actionGlobalLedgerConnectionIssueBottomSheet())
    }

    private fun onInvalidWalletConnectTransacitonReceived(error: Resource.Error) {
        val annotatedDescriptionErrorString = AnnotatedString(
            stringResId = R.string.your_walletconnect_request_failed,
            replacementList = listOf("error_message" to error.parse(this).toString())
        )
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.uh_oh_something),
                drawableResId = R.drawable.ic_error,
                drawableTintResId = R.color.error_tint_color,
                descriptionAnnotatedString = annotatedDescriptionErrorString,
                isDraggable = false
            )
        )
    }

    private fun handleWalletConnectTransactionRequest(requestEvent: Event<Resource<WalletConnectTransaction>>?) {
        requestEvent?.consume()?.use(onSuccess = ::onNewWalletConnectTransactionRequest)
    }

    private fun onNewWalletConnectTransactionRequest(transaction: WalletConnectTransaction) {
        if (isAppUnlocked) {
            nav(
                directions = MainNavigationDirections.actionGlobalWalletConnectRequestNavigation(
                    shouldSkipConfirmation = isBasePeraWebViewFragmentActive()
                ),
                onError = { saveWcTransactionToPendingIntent(transaction.requestId) }
            )
        } else {
            saveWcTransactionToPendingIntent(transaction.requestId)
        }
    }

    private fun saveWcTransactionToPendingIntent(transactionRequestId: Long) {
        pendingIntent = Intent().apply {
            putExtra(WC_TRANSACTION_ID_INTENT_KEY, transactionRequestId)
        }
    }

    private fun handleDeeplinkAndNotificationNavigation() {
        intent.getSafeParcelableExtra<Intent?>(DEEPLINK_AND_NAVIGATION_INTENT)?.apply {
            pendingIntent = this
            handlePendingIntent()
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        pendingIntent = intent?.getSafeParcelableExtra(DEEPLINK_AND_NAVIGATION_INTENT)
        handlePendingIntent()
    }

    private fun handlePendingIntent(): Boolean {
        return pendingIntent?.run {
            val canPendingBeHandled = isAssetSetupCompleted && (isAppUnlocked || !mainViewModel.shouldAppLocked())
            if (canPendingBeHandled) {
                if (dataString != null) {
                    handleDeepLink(dataString.orEmpty())
                } else {
                    handlePendingIntentWithExtras(this)
                }
                pendingIntent = null
            }
            canPendingBeHandled
        } ?: false
    }

    private fun handlePendingIntentWithExtras(pendingIntent: Intent) {
        with(pendingIntent) {
            // TODO change your architecture for the bug here. https://issuetracker.google.com/issues/37053389
            // This fixes the problem for now. Be careful when adding more than one parcelable.
            setExtrasClassLoader(com.algorand.android.models.AssetInformation::class.java.classLoader)

            if (getLongExtra(WC_TRANSACTION_ID_INTENT_KEY, -1L) != -1L) {
                nav(HomeNavigationDirections.actionGlobalWalletConnectRequestNavigation())
            } else {
                getStringExtra(DEEPLINK_KEY)?.let { handleDeepLink(it) }
            }
        }
    }

    fun handleDeepLink(uri: String) {
        mainViewModel.handleDeepLink(uri)
    }

    fun handleWalletConnectUrl(walletConnectUrl: String) {
        walletConnectViewModel.handleWalletConnectUrl(
            url = walletConnectUrl,
            listener = walletConnectUrlHandlerListener
        )
    }

    fun isBasePeraWebViewFragmentActive(): Boolean {
        return (supportFragmentManager.findFragmentById(binding.navigationHostFragment.id) as NavHostFragment)
            .childFragmentManager.fragments.first() is BasePeraWebViewFragment
    }

    private fun onIntentHandlingFailed(@StringRes errorMessageResId: Int) {
        showGlobalError(errorMessage = getString(errorMessageResId))
    }

    private fun setupCoreActionsTabBarView() {
        binding.coreActionsTabBarView.setListener(object : CoreActionsTabBarView.Listener {
            override fun onSendClick() {
                firebaseAnalytics.logTapSend()
                nav(HomeNavigationDirections.actionGlobalSendAlgoNavigation(null))
            }

            override fun onReceiveClick() {
                firebaseAnalytics.logTapReceive()
                nav(HomeNavigationDirections.actionGlobalReceiveAccountSelectionFragment())
            }

            override fun onBuySellClick() {
                // TODO refactor with a better name for logging
                mainViewModel.logBottomNavigationBuyAlgoEvent()
                navToBuySellActionsBottomSheet()
            }

            override fun onScanQRClick() {
                navToQRCodeScannerNavigation()
            }

            override fun onCoreActionsClick(isCoreActionsOpen: Boolean) {
                binding.bottomNavigationView.menu.forEach { menuItem ->
                    menuItem.isEnabled = isCoreActionsOpen.not()
                }
                handleBottomBarNavigationForChosenNetwork()
            }

            override fun onSwapClick() {
                mainViewModel.onSwapActionButtonClick()
            }
        })
    }

    private fun handleRedirection() {
        val isPendingIntentHandled = handlePendingIntent()
        if (isPendingIntentHandled) {
            return
        }
        val isInAppReviewStarted = inAppReviewManager.start(this@MainActivity)
        if (isInAppReviewStarted) {
            return
        }
        if (accountManager.isThereAnyRegisteredAccount()) {
            autoLockSuggestionManager.start(this@MainActivity)
        }
    }

    private fun onNewNodeActivated() {
        binding.progressBar.loadingProgressBar.hide()
        mainViewModel.onNewNodeActivated()
    }

    private fun onNewNodeLoading() {
        binding.progressBar.loadingProgressBar.show()
    }

    override fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult) {
        handleSessionConnectionResult(wCSessionRequestResult)
    }

    private fun handleSessionConnectionResult(result: WCSessionRequestResult) {
        with(walletConnectViewModel) {
            when (result) {
                is WCSessionRequestResult.ApproveRequest -> approveSession(result)
                is WCSessionRequestResult.RejectRequest -> rejectSession(result.sessionProposal)
            }
        }
    }

    fun signAddAssetTransaction(assetActionResult: AssetActionResult) {
        if (!assetActionResult.publicKey.isNullOrBlank()) {
            val accountCacheData = accountDetailUseCase.getCachedAccountDetail(
                assetActionResult.publicKey
            )?.data ?: return
            val transactionData = TransactionData.AddAsset(
                senderAccountAddress = accountCacheData.account.address,
                assetInformation = assetActionResult.asset,
                senderAuthAddress = accountCacheData.accountInformation.rekeyAdminAddress,
                isSenderRekeyedToAnotherAccount = accountCacheData.accountInformation.isRekeyed(),
                senderAccountType = accountCacheData.account.type,
                senderAccountDetail = accountCacheData.account.detail
            )
            mainViewModel.setLatestAddAssetTransaction(transactionData)
            sendAssetOperationTransaction(transactionData)
        }
    }

    fun signRemoveAssetTransaction(assetActionResult: AssetActionResult) {
        if (!assetActionResult.publicKey.isNullOrBlank()) {
            val accountCacheData = accountDetailUseCase.getCachedAccountDetail(
                assetActionResult.publicKey
            )?.data ?: return
            val transactionData = TransactionData.RemoveAsset(
                senderAccountAddress = accountCacheData.account.address,
                assetInformation = assetActionResult.asset,
                creatorPublicKey = assetActionResult.asset.creatorPublicKey.orEmpty(),
                senderAuthAddress = accountCacheData.accountInformation.rekeyAdminAddress,
                isSenderRekeyedToAnotherAccount = accountCacheData.accountInformation.isRekeyed(),
                senderAccountType = accountCacheData.account.type,
                senderAccountDetail = accountCacheData.account.detail
            )
            sendAssetOperationTransaction(transactionData)
        }
    }

    private fun sendAssetOperationTransaction(transactionData: TransactionData) {
        transactionManager.setup(lifecycle)
        transactionManager.initSigningTransactions(
            isGroupTransaction = false,
            transactionData
        )
    }

    private fun onWalletConnectSessionTimedOut() {
        navToWalletConnectSessionTimeoutDialog()
    }

    private fun navToWalletConnectSessionTimeoutDialog() {
        hideProgress()
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.connection_failed),
                drawableResId = R.drawable.ic_error,
                drawableTintResId = R.color.error_tint_color,
                descriptionAnnotatedString = AnnotatedString(R.string.we_are_sorry_but_the),
            )
        )
    }

    private fun navToBuySellActionsBottomSheet() {
        nav(HomeNavigationDirections.actionGlobalBuySellActionsBottomSheet())
    }

    private fun navToQRCodeScannerNavigation() {
        nav(HomeNavigationDirections.actionGlobalAccountsQrScannerFragment())
    }

    fun showMaxAccountLimitExceededError() {
        showGlobalError(
            title = getString(R.string.too_many_accounts),
            errorMessage = getString(R.string.looks_like_already_have_accounts, MAX_NUMBER_OF_ACCOUNTS),
            tag = activityTag
        )
    }

    private fun hideLedgerLoadingDialog() {
        hideProgress()
        ledgerLoadingDialog?.dismissAllowingStateLoss()
        ledgerLoadingDialog = null
    }

    private fun showLedgerLoadingDialog(ledgerName: String?) {
        if (ledgerLoadingDialog == null) {
            ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog(ledgerName, ledgerLoadingDialogListener)
            ledgerLoadingDialog?.showWithStateCheck(supportFragmentManager)
        }
    }

    companion object {
        fun newIntentWithDeeplinkOrNavigation(
            context: Context,
            deepLinkIntent: Intent
        ): Intent {
            return Intent(context, MainActivity::class.java).apply {
                putExtra(DEEPLINK_AND_NAVIGATION_INTENT, deepLinkIntent)
            }
        }

        const val DEEPLINK_KEY = "deeplinkKey"
        const val DEEPLINK_AND_NAVIGATION_INTENT = "deeplinknavIntent"
        const val WC_TRANSACTION_ID_INTENT_KEY = "wcTransactionId"
    }
}
