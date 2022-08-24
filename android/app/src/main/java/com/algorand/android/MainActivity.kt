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
import androidx.core.view.forEach
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import com.algorand.android.core.TransactionManager
import com.algorand.android.customviews.CoreActionsTabBarView
import com.algorand.android.customviews.ForegroundNotificationView
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.Node
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.NotificationType
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.models.WCSessionRequestResult
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.modules.dapp.moonpay.domain.model.MoonpayTransactionStatus
import com.algorand.android.modules.deeplink.domain.model.BaseDeepLink
import com.algorand.android.modules.deeplink.ui.DeeplinkHandler
import com.algorand.android.modules.qrscanning.QrScannerViewModel
import com.algorand.android.tutorialdialog.util.showCopyAccountAddressTutorialDialog
import com.algorand.android.ui.accountselection.receive.ReceiveAccountSelectionFragment
import com.algorand.android.ui.assetaction.UnsupportedAssetNotificationRequestActionBottomSheet
import com.algorand.android.ui.lockpreference.AutoLockSuggestionManager
import com.algorand.android.ui.wcconnection.WalletConnectConnectionBottomSheet
import com.algorand.android.utils.DEEPLINK_AND_NAVIGATION_INTENT
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.WC_TRANSACTION_ID_INTENT_KEY
import com.algorand.android.utils.analytics.logTapReceive
import com.algorand.android.utils.analytics.logTapSend
import com.algorand.android.utils.handleIntentWithBundle
import com.algorand.android.utils.inappreview.InAppReviewManager
import com.algorand.android.utils.isNotificationCanBeShown
import com.algorand.android.utils.navigateSafe
import com.algorand.android.utils.preference.isPasswordChosen
import com.algorand.android.utils.walletconnect.WalletConnectManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import com.algorand.android.utils.walletconnect.WalletConnectUrlHandler
import com.algorand.android.utils.walletconnect.WalletConnectViewModel
import com.google.firebase.analytics.FirebaseAnalytics
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlin.properties.Delegates
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch

@AndroidEntryPoint
class MainActivity : CoreMainActivity(),
    ForegroundNotificationView.ForegroundNotificationViewListener,
    UnsupportedAssetNotificationRequestActionBottomSheet.RequestAssetConfirmationListener,
    WalletConnectConnectionBottomSheet.Callback,
    ReceiveAccountSelectionFragment.ReceiveAccountSelectionFragmentListener {

    val mainViewModel: MainViewModel by viewModels()
    private val walletConnectViewModel: WalletConnectViewModel by viewModels()
    private val qrScannerViewModel: QrScannerViewModel by viewModels()

    private var pendingIntent: Intent? = null

    @Inject
    lateinit var transactionManager: TransactionManager

    @Inject
    lateinit var firebaseAnalytics: FirebaseAnalytics

    @Inject
    lateinit var inAppReviewManager: InAppReviewManager

    @Inject
    lateinit var autoLockSuggestionManager: AutoLockSuggestionManager

    @Inject
    lateinit var walletConnectManager: WalletConnectManager

    @Inject
    lateinit var errorProvider: WalletConnectTransactionErrorProvider

    var isAppUnlocked: Boolean by Delegates.observable(false) { _, oldValue, newValue ->
        if (oldValue != newValue && newValue && isAssetSetupCompleted) {
            handleRedirection()
        }
    }

    private var isAssetSetupCompleted: Boolean by Delegates.observable(false) { _, oldValue, newValue ->
        if (oldValue != newValue && newValue && isAppUnlocked) {
            handleRedirection()
        }
    }

    private val addAssetResultObserver = Observer<Event<Resource<String?>>> {
        it.consume()?.use(
            onSuccess = { assetName -> showAssetAdditionForegroundNotification(assetName) }
        )
    }

    private val assetSetupCompletedObserver = Observer<AccountCacheStatus> {
        isAssetSetupCompleted = it == AccountCacheStatus.DONE
    }

    private val autoLockManagerObserver = Observer<Event<Any>> {
        it.consume()?.let {
            if (accountManager.isThereAnyRegisteredAccount() && isAppUnlocked && sharedPref.isPasswordChosen()) {
                isAppUnlocked = false
                nav(MainNavigationDirections.actionGlobalLockFragment())
            }
        }
    }

    private val newNotificationObserver = Observer<Event<NotificationMetadata>> {
        it?.consume()?.let { newNotificationData ->
            with(newNotificationData) {
                val notificationType = getNotificationType()
                if (navController.isNotificationCanBeShown(notificationType, isAppUnlocked).not()) {
                    return@let
                }
                when (notificationType) {
                    NotificationType.ASSET_SUPPORT_REQUEST -> handleAssetSupportRequest(this)
                    else -> binding.foregroundNotificationView.addNotification(this)
                }
            }
        }
    }

    private val shouldShowAccountAddressCopyTutorialDialogCollector: suspend (Boolean) -> Unit = { shouldShow ->
        if (shouldShow) showCopyAccountAddressTutorialDialog()
    }

    private val invalidTransactionCauseObserver = Observer<Event<Resource.Error.Local>> { cause ->
        cause.consume()?.let { onInvalidWalletConnectTransacitonReceived(it) }
    }

    private val walletConnectUrlHandlerListener = object : WalletConnectUrlHandler.Listener {
        override fun onValidWalletConnectUrl(url: String) {
            showProgress()
            walletConnectViewModel.connectToSessionByUrl(url)
        }

        override fun onInvalidWalletConnectUrl(errorResId: Int) {
            qrScannerViewModel.setQrCodeInProgress(false)
            showGlobalError(getString(errorResId))
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
            return true.also { handleWalletConnectUrl(wcUrl) }
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

        override fun onAssetOptInDeepLink(assetAction: AssetAction): Boolean {
            return true.also {
                navController.navigateSafe(
                    HomeNavigationDirections.actionGlobalAddAssetAccountSelectionFragment(assetAction.assetId)
                )
            }
        }

        override fun onUndefinedDeepLink(undefinedDeeplink: BaseDeepLink.UndefinedDeepLink) {
            // TODO show error after discussing with the team
        }

        override fun onDeepLinkNotHandled(deepLink: BaseDeepLink) {
            // TODO show error after discussing with the team
        }
    }

    private fun onNewSessionEvent(sessionEvent: Event<Resource<WalletConnectSession>>) {
        sessionEvent.consume()?.use(
            onSuccess = ::onSessionConnected,
            onFailed = ::onSessionFailed,
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    private fun onSessionConnected(wcSessionRequest: WalletConnectSession) {
        nav(HomeNavigationDirections.actionGlobalWalletConnectConnectionBottomSheet(wcSessionRequest))
    }

    private fun onSessionFailed(error: Resource.Error) {
        qrScannerViewModel.setQrCodeInProgress(false)
        val errorMessage = error.parse(this)
        showGlobalError(errorMessage)
    }

    private fun handleAssetSupportRequest(notificationMetadata: NotificationMetadata) {
        val assetInformation = notificationMetadata.getAssetDescription().convertToAssetInformation()
        val assetAction = AssetAction(
            assetId = assetInformation.assetId,
            publicKey = notificationMetadata.receiverPublicKey,
            asset = assetInformation
        )
        nav(HomeNavigationDirections.actionGlobalUnsupportedAssetNotificationRequestActionBottomSheet(assetAction))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        with(mainViewModel) {
            setupAutoLockManager(lifecycle)
            setDeepLinkHandlerListener(deepLinkHandlerListener)
        }
        setupCoreActionsTabBarView()
        setupWalletConnectManager()

        binding.foregroundNotificationView.apply {
            setListener(this@MainActivity)
            accounts = accountManager.getAccounts()
        }

        initObservers()

        if (savedInstanceState == null) {
            handleDeeplinkAndNotificationNavigation()
        }

        mainViewModel.checkAccountAddressCopyTutorialDialogState()
    }

    override fun onMenuItemClicked(item: MenuItem) {
        when (item.itemId) {
            R.id.algoPriceFragment -> {
                mainViewModel.logBottomNavAlgoPriceTapEvent()
            }
            R.id.accountsFragment -> {
                mainViewModel.logBottomNavAccountsTapEvent()
            }
        }
    }

    override fun onNotificationClick(publicKeyToActivate: String?, assetIdToActivate: Long?) {
        if (publicKeyToActivate != null && assetIdToActivate != null) {
            val accountCacheData = accountCacheManager.getCacheData(publicKeyToActivate)
            val assetInformation = accountCacheManager.getAssetInformation(publicKeyToActivate, assetIdToActivate)
            if (accountCacheData != null && assetInformation != null) {
                nav(
                    HomeNavigationDirections
                        .actionGlobalAssetDetailFragment(assetInformation.assetId, accountCacheData.account.address)
                )
            }
        }
    }

    // TODO Use new notification view when ForegroundNotification and SlidingTopErrorView are refactored
    private fun showAssetAdditionForegroundNotification(assetName: String?) {
        val safeAssetName = assetName ?: getString(R.string.asset)
        val messageDescription = getString(R.string.asset_successfully_added_formatted, safeAssetName)
        val metadata = NotificationMetadata(
            alertMessage = messageDescription,
            notificationType = NotificationType.BROADCAST
        )
        showForegroundNotification(metadata)
    }

    override fun onAccountSelected(publicKey: String) {
        val qrCodeTitle = getString(R.string.qr_code)
        nav(HomeNavigationDirections.actionGlobalShowQrBottomSheet(qrCodeTitle, publicKey))
    }

    private fun initObservers() {
        peraNotificationManager.newNotificationLiveData.observe(this, newNotificationObserver)

        mainViewModel.addAssetResultLiveData.observe(this, addAssetResultObserver)

        lifecycleScope.launch {
            // Drop 1 added to get any list changes.
            accountManager.accounts.drop(1).collect { accounts ->
                mainViewModel.refreshFirebasePushToken(null)
                binding.foregroundNotificationView.accounts = accounts
            }
        }

        contactsDao.getAllLiveData().observe(this, Observer { contactList ->
            binding.foregroundNotificationView.contacts = contactList
        })

        transactionManager.transactionManagerResultLiveData.observe(this, Observer {
            it?.consume()?.let { result ->
                when (result) {
                    is TransactionManagerResult.Success -> {
                        val signedTransactionDetail = result.signedTransactionDetail
                        if (signedTransactionDetail is SignedTransactionDetail.AssetOperation) {
                            mainViewModel.sendSignedTransaction(
                                signedTransactionDetail.signedTransactionData,
                                signedTransactionDetail.assetInformation,
                                signedTransactionDetail.accountCacheData.account.address
                            )
                        }
                    }
                    is TransactionManagerResult.Error -> {
                        val (title, errorMessage) = result.getMessage(this)
                        showGlobalError(title = title, errorMessage = errorMessage)
                    }
                    is TransactionManagerResult.LedgerScanFailed -> navigateToConnectionIssueBottomSheet()
                }
            }
        })

        mainViewModel.autoLockLiveData.observe(this, autoLockManagerObserver)

        mainViewModel.accountBalanceSyncStatus.observe(this, assetSetupCompletedObserver)

        walletConnectViewModel.requestLiveData.observe(this, ::handleWalletConnectTransactionRequest)

        walletConnectViewModel.invalidTransactionCauseLiveData.observe(this, invalidTransactionCauseObserver)

        lifecycleScope.launch {
            walletConnectViewModel.sessionResultFlow.collectLatest(::onNewSessionEvent)
        }

        walletConnectViewModel.setWalletConnectSessionTimeoutListener(::onWalletConnectSessionTimedOut)

        lifecycleScope.launchWhenResumed {
            mainViewModel.shouldShowAccountAddressCopyTutorialDialogFlow
                .collectLatest(shouldShowAccountAddressCopyTutorialDialogCollector)
        }
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

    private fun setupWalletConnectManager() {
        lifecycle.addObserver(walletConnectManager)
    }

    private fun handleWalletConnectTransactionRequest(requestEvent: Event<Resource<WalletConnectTransaction>>?) {
        requestEvent?.consume()?.use(onSuccess = ::onNewWalletConnectTransactionRequest)
    }

    private fun onNewWalletConnectTransactionRequest(transaction: WalletConnectTransaction) {
        if (isAppUnlocked) {
            nav(
                directions = MainNavigationDirections.actionGlobalWalletConnectRequestNavigation(),
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
        intent.getParcelableExtra<Intent?>(DEEPLINK_AND_NAVIGATION_INTENT)?.apply {
            pendingIntent = this
            handlePendingIntent()
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        mainViewModel.checkLockState()
        pendingIntent = intent?.getParcelableExtra(DEEPLINK_AND_NAVIGATION_INTENT)
        handlePendingIntent()
    }

    private fun handlePendingIntent(): Boolean {
        return pendingIntent?.run {
            val canPendingBeHandled = isAssetSetupCompleted && isAppUnlocked
            if (canPendingBeHandled) {
                if (dataString != null) {
                    mainViewModel.handleDeepLink(dataString.orEmpty())
                } else {
                    navController.handleIntentWithBundle(this, accountCacheManager)
                }
                pendingIntent = null
            }
            canPendingBeHandled
        } ?: false
    }

    fun handleWalletConnectUrl(walletConnectUrl: String) {
        walletConnectViewModel.handleWalletConnectUrl(walletConnectUrl, walletConnectUrlHandlerListener)
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

            override fun onBuyAlgoClick() {
                mainViewModel.logBottomNavigationBuyAlgoEvent()
                navToMoonpayIntroFragment()
            }

            override fun onScanQRClick() {
                navToQRCodeScannerNavigation()
            }

            override fun onCoreActionsClick(isCoreActionsOpen: Boolean) {
                binding.bottomNavigationView.menu.forEach { menuItem -> menuItem.isEnabled = isCoreActionsOpen.not() }
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

    fun onNewNodeActivated(previousNode: Node, activatedNode: Node) {
        mainViewModel.refreshFirebasePushToken(previousNode)
        mainViewModel.resetBlockPolling()
        checkIfConnectedToTestNet()
    }

    override fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult) {
        handleSessionConnectionResult(wCSessionRequestResult)
    }

    private fun handleSessionConnectionResult(result: WCSessionRequestResult) {
        with(walletConnectViewModel) {
            when (result) {
                is WCSessionRequestResult.ApproveRequest -> {
                    approveSession(result)
                    showConnectedDappInfoBottomSheet(result.wcSessionRequest.peerMeta.name)
                }
                is WCSessionRequestResult.RejectRequest -> rejectSession(result.session)
            }
        }
    }

    private fun showConnectedDappInfoBottomSheet(pearName: String) {
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(
                    stringResId = R.string.you_are_connected,
                    replacementList = listOf("peer_name" to pearName)
                ),
                descriptionAnnotatedString = AnnotatedString(
                    stringResId = R.string.please_return_to,
                    replacementList = listOf("peer_name" to pearName)
                ),
                drawableResId = R.drawable.ic_check_72dp,
                isResultNeeded = true
            )
        )
    }

    override fun onUnsupportedAssetRequest(assetActionResult: AssetActionResult) {
        signAddAssetTransaction(assetActionResult)
    }

    fun signAddAssetTransaction(assetActionResult: AssetActionResult) {
        if (!assetActionResult.publicKey.isNullOrBlank()) {
            val accountCacheData = accountCacheManager.getCacheData(assetActionResult.publicKey) ?: return
            transactionManager.setup(lifecycle)
            transactionManager.initSigningTransactions(
                isGroupTransaction = false,
                TransactionData.AddAsset(accountCacheData, assetActionResult.asset)
            )
        }
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

    private fun navToMoonpayIntroFragment() {
        nav(HomeNavigationDirections.actionGlobalMoonpayNavigation())
    }

    private fun navToQRCodeScannerNavigation() {
        nav(HomeNavigationDirections.actionGlobalAccountsQrScannerFragment())
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
    }
}
