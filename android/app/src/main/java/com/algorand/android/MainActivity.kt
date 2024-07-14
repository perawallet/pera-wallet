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
import androidx.navigation.NavDirections
import androidx.navigation.fragment.NavHostFragment
import com.algorand.android.HomeNavigationDirections.Companion.actionGlobalDiscoverNavigation
import com.algorand.android.core.TransactionManager
import com.algorand.android.customviews.CoreActionsTabBarView
import com.algorand.android.customviews.LedgerLoadingDialog
import com.algorand.android.customviews.alertview.ui.delegation.AlertDialogDelegation
import com.algorand.android.customviews.alertview.ui.delegation.AlertDialogDelegationImpl
import com.algorand.android.customviews.customsnackbar.CustomSnackbar
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.AssetOperationResult
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.Node
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.models.WalletConnectRequest
import com.algorand.android.models.WalletConnectRequest.WalletConnectArbitraryDataRequest
import com.algorand.android.models.WalletConnectRequest.WalletConnectTransaction
import com.algorand.android.modules.autolockmanager.ui.AutoLockManager
import com.algorand.android.modules.deeplink.DeepLinkParser
import com.algorand.android.modules.deeplink.domain.model.BaseDeepLink
import com.algorand.android.modules.deeplink.domain.model.NotificationGroupType
import com.algorand.android.modules.deeplink.ui.DeeplinkHandler
import com.algorand.android.modules.firebase.token.FirebaseTokenManager
import com.algorand.android.modules.firebase.token.model.FirebaseTokenResult
import com.algorand.android.modules.pendingintentkeeper.ui.PendingIntentKeeper
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewFragment
import com.algorand.android.modules.qrscanning.QrScannerViewModel
import com.algorand.android.modules.walletconnect.connectionrequest.ui.WalletConnectConnectionBottomSheet
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WCSessionRequestResult
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import com.algorand.android.notification.domain.model.NotificationMetadata
import com.algorand.android.ui.accountselection.receive.ReceiveAccountSelectionFragment
import com.algorand.android.ui.lockpreference.AutoLockSuggestionManager
import com.algorand.android.usecase.IsAccountLimitExceedUseCase.Companion.MAX_NUMBER_OF_ACCOUNTS
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.logTapReceive
import com.algorand.android.utils.analytics.logTapSend
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.getSafeParcelableExtra
import com.algorand.android.utils.inappreview.InAppReviewManager
import com.algorand.android.utils.navigateSafe
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.showWithStateCheck
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
    ReceiveAccountSelectionFragment.ReceiveAccountSelectionFragmentListener,
    AlertDialogDelegation by AlertDialogDelegationImpl() {

    val mainViewModel: MainViewModel by viewModels()
    private val walletConnectViewModel: WalletConnectViewModel by viewModels()
    private val qrScannerViewModel: QrScannerViewModel by viewModels()

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
    lateinit var firebaseTokenManager: FirebaseTokenManager

    @Inject
    lateinit var autoLockManager: AutoLockManager

    @Inject
    lateinit var deepLinkParser: DeepLinkParser

    @Inject
    lateinit var pendingIntentKeeper: PendingIntentKeeper

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
        it.consume()?.let { newNotificationData ->
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
            else -> showForegroundNotification(notificationMetadata = newNotificationData, tag = activityTag)
        }
    }

    private fun handleNotificationWithDeepLink(
        newNotificationData: NotificationMetadata,
        deeplink: BaseDeepLink.NotificationDeepLink
    ) {
        when (deeplink.notificationGroupType) {
            NotificationGroupType.OPT_IN -> handleAssetOptInRequestDeepLink(deeplink.address, deeplink.assetId)
            else -> showForegroundNotification(notificationMetadata = newNotificationData, tag = activityTag)
        }
    }

    private fun handleAssetOptInRequestDeepLink(accountAddress: String, assetId: Long) {
        if (!accountDetailUseCase.isThereAnyAccountWithPublicKey(accountAddress)) {
            showGlobalError(errorMessage = getString(R.string.you_cannot_take), tag = activityTag)
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
            showGlobalError(errorMessage = getString(R.string.you_cannot_take), tag = activityTag)
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

    private val walletConnectSessionSettleCollector: suspend (Event<WalletConnectSessionIdentifier>) -> Unit = {
        it.consume()?.let { sessionIdentifier ->
            if (!isBasePeraWebViewFragmentActive()) {
                nav(HomeNavigationDirections.actionGlobalWcConnectionLaunchBackBrowserBottomSheet(sessionIdentifier))
            }
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

    private val alertDialogDelegationListener = AlertDialogDelegationImpl.Listener { deepLinkUri ->
        handleDeepLink(deepLinkUri)
    }

    private val activeNodeCollector: suspend (Node?) -> Unit = { activatedNode ->
        checkIfConnectedToTestNet(activatedNode)
    }

    private val firebaseTokenResultCollector: suspend (FirebaseTokenResult) -> Unit = { firebaseTokenResult ->
        when (firebaseTokenResult) {
            FirebaseTokenResult.TokenLoaded -> onNewNodeActivated()
            // TODO: do not show activity loading while token is loading
            FirebaseTokenResult.TokenLoading -> onNewNodeLoading()

            FirebaseTokenResult.TokenFailed -> onNewTokenFailed()
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
        nav(HomeNavigationDirections.actionGlobalWalletConnectConnectionNavigation(wcSessionRequest))
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

        initObservers()
        registerAlertDialogDelegation(this, alertDialogDelegationListener)

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
        showAlertSuccess(title = messageDescription, description = null, tag = activityTag)
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

        walletConnectViewModel.walletConnectRequestLiveData.observe(this, ::handleWalletConnectRequest)

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
            walletConnectViewModel.sessionSettleFlow,
            walletConnectSessionSettleCollector
        )

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

    private fun handleWalletConnectRequest(requestEvent: Event<Resource<WalletConnectRequest>>?) {
        requestEvent?.consume()?.use(onSuccess = ::onNewWalletConnectRequest)
    }

    private fun onNewWalletConnectRequest(wcRequest: WalletConnectRequest) {
        if (isAppUnlocked) {
            when (wcRequest) {
                is WalletConnectTransaction -> {
                    nav(
                        directions = MainNavigationDirections.actionGlobalWalletConnectTransactionRequestNavigation(
                            shouldSkipConfirmation = isBasePeraWebViewFragmentActive()
                        ),
                        onError = { saveWcTransactionToPendingIntent(wcRequest.requestId) }
                    )
                }

                is WalletConnectArbitraryDataRequest -> {
                    nav(
                        directions = MainNavigationDirections.actionGlobalWalletConnectArbitraryDataRequestNavigation(
                            shouldSkipConfirmation = isBasePeraWebViewFragmentActive()
                        ),
                        onError = { saveWcTransactionToPendingIntent(wcRequest.requestId) }
                    )
                }
            }
        } else {
            saveWcTransactionToPendingIntent(wcRequest.requestId)
        }
    }

    private fun saveWcTransactionToPendingIntent(transactionRequestId: Long) {
        val pendingIntent = Intent().apply {
            putExtra(WC_TRANSACTION_ID_INTENT_KEY, transactionRequestId)
        }
        pendingIntentKeeper.setPendingIntent(pendingIntent)
    }

    private fun saveWcArbitraryDataToPendingIntent(arbitraryDataRequestId: Long) {
        val pendingIntent = Intent().apply {
            putExtra(WC_ARBITRARY_DATA_ID_INTENT_KEY, arbitraryDataRequestId)
        }
        pendingIntentKeeper.setPendingIntent(pendingIntent)
    }

    private fun handleDeeplinkAndNotificationNavigation() {
        intent.getSafeParcelableExtra<Intent?>(DEEPLINK_AND_NAVIGATION_INTENT)?.apply {
            pendingIntentKeeper.setPendingIntent(this)
            handlePendingIntent()
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        val pendingIntent = intent?.getSafeParcelableExtra<Intent?>(DEEPLINK_AND_NAVIGATION_INTENT)
        pendingIntentKeeper.setPendingIntent(pendingIntent)
        handlePendingIntent()
    }

    private fun handlePendingIntent(): Boolean {
        return pendingIntentKeeper.pendingIntent?.run {
            val canPendingIntentBeHandled = isAssetSetupCompleted && (isAppUnlocked || !mainViewModel.shouldAppLocked())
            var isPendingIntentHandled = false
            if (canPendingIntentBeHandled) {
                if (dataString != null) {
                    handleDeepLink(dataString.orEmpty())
                    isPendingIntentHandled = true
                } else {
                   isPendingIntentHandled = handlePendingIntentWithExtras(this)
                }
                pendingIntentKeeper.clearPendingIntent()
            }
            isPendingIntentHandled
        } ?: false
    }

    private fun handlePendingIntentWithExtras(pendingIntent: Intent): Boolean {
        with(pendingIntent) {
            // TODO change your architecture for the bug here. https://issuetracker.google.com/issues/37053389
            // This fixes the problem for now. Be careful when adding more than one parcelable.
            setExtrasClassLoader(com.algorand.android.models.AssetInformation::class.java.classLoader)

            if (getLongExtra(WC_TRANSACTION_ID_INTENT_KEY, -1L) != -1L) {
                nav(HomeNavigationDirections.actionGlobalWalletConnectTransactionRequestNavigation())
            } else if (getLongExtra(WC_ARBITRARY_DATA_ID_INTENT_KEY, -1L) != -1L) {
                nav(HomeNavigationDirections.actionGlobalWalletConnectArbitraryDataRequestNavigation())
            } else {
                getStringExtra(DEEPLINK_KEY)?.let { handleDeepLink(it) } ?: return false
            }
            return true
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
        showGlobalError(errorMessage = getString(errorMessageResId), tag = activityTag)
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
                handleNavigationButtonsForChosenNetwork()
            }

            override fun onSwapClick() {
                mainViewModel.onSwapActionButtonClick()
            }

            override fun onBrowseDappsClick() {
                handleBrowseDappsClick()
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
        hideProgress()
        mainViewModel.onNewNodeActivated()
    }

    private fun onNewNodeLoading() {
        showProgress()
    }

    private fun onNewTokenFailed() {
        hideProgress()
    }

    override fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult) {
        with(walletConnectViewModel) {
            when (wCSessionRequestResult) {
                is WCSessionRequestResult.ApproveRequest -> approveSession(wCSessionRequestResult)
                is WCSessionRequestResult.RejectRequest -> rejectSession(wCSessionRequestResult.sessionProposal)
                is WCSessionRequestResult.RejectScamRequest -> rejectScamSession(wCSessionRequestResult.sessionProposal)
            }
        }
    }

    private fun rejectScamSession(sessionProposal: WalletConnectSessionProposal) {
        walletConnectViewModel.rejectSession(sessionProposal)
        navToWalletConnectSessionScamDialog()
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

    private fun navToWalletConnectSessionScamDialog() {
        hideProgress()
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.malicious_website_blocked),
                drawableResId = R.drawable.ic_error,
                drawableTintResId = R.color.error_tint_color,
                descriptionAnnotatedString = AnnotatedString(R.string.you_attempted_to_connect_malicious_website),
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

    private fun handleBrowseDappsClick() {
        binding.apply {
            coreActionsTabBarView.hideWithAnimation()
            bottomNavigationView.menu.findItem(R.id.discoverNavigation).isChecked = true
            navController.navigateSafe(actionGlobalDiscoverNavigation(BuildConfig.DISCOVER_BROWSE_DAPP_URL))
        }
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
        const val WC_ARBITRARY_DATA_ID_INTENT_KEY = "wcArbitraryDataId"
    }
}
