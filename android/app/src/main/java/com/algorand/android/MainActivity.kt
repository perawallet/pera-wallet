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

package com.algorand.android

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import com.algorand.android.HomeNavigationDirections.Companion.actionGlobalAssetDetailFragment
import com.algorand.android.HomeNavigationDirections.Companion.actionGlobalAssetSelectionBottomSheet
import com.algorand.android.core.TransactionManager
import com.algorand.android.customviews.ForegroundNotificationView
import com.algorand.android.customviews.SendReceiveTabBarView
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Node
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.NotificationType
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.models.WCSessionRequestResult
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.ui.common.AssetActionBottomSheet
import com.algorand.android.ui.common.assetselector.AssetSelectionBottomSheet
import com.algorand.android.ui.lockpreference.AutoLockSuggestionManager
import com.algorand.android.ui.wcconnection.WalletConnectConnectionBottomSheet
import com.algorand.android.utils.DEEPLINK_AND_NAVIGATION_INTENT
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.logTapReceive
import com.algorand.android.utils.analytics.logTapSend
import com.algorand.android.utils.handleIntent
import com.algorand.android.utils.inappreview.InAppReviewManager
import com.algorand.android.utils.isNotificationCanBeShown
import com.algorand.android.utils.preference.isPasswordChosen
import com.algorand.android.utils.walletconnect.WalletConnectManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
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
    AssetActionBottomSheet.AddAssetConfirmationPopupListener,
    WalletConnectConnectionBottomSheet.Callback {

    val mainViewModel: MainViewModel by viewModels()
    private val walletConnectViewModel: WalletConnectViewModel by viewModels()

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

    var isAppUnlocked: Boolean by Delegates.observable(false, { _, oldValue, newValue ->
        if (oldValue != newValue && newValue && isAssetSetupCompleted) {
            handleRedirection()
        }
    })

    private var isAssetSetupCompleted: Boolean by Delegates.observable(false, { _, oldValue, newValue ->
        if (oldValue != newValue && newValue && isAppUnlocked) {
            handleRedirection()
        }
    })

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

    private fun onNewSessionEvent(sessionEvent: Event<Resource<WalletConnectSession>>) {
        sessionEvent.consume()?.use(
            onSuccess = { onSessionConnected(it) },
            onFailed = ::onSessionFailed,
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    private fun onSessionConnected(wcSessionRequest: WalletConnectSession) {
        nav(HomeNavigationDirections.actionGlobalWalletConnectConnectionBottomSheet(wcSessionRequest))
    }

    private fun onSessionFailed(error: Resource.Error) {
        val errorMessage = error.parse(this)
        showGlobalError(errorMessage)
    }

    private fun handleAssetSupportRequest(notificationMetadata: NotificationMetadata) {
        val assetInformation = notificationMetadata.getAssetDescription().convertToAssetInformation()
        AssetActionBottomSheet.show(
            supportFragmentManager,
            assetInformation.assetId,
            AssetActionBottomSheet.Type.UNSUPPORTED_NOTIFICATION_REQUEST,
            accountPublicKey = notificationMetadata.receiverPublicKey,
            asset = assetInformation
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        mainViewModel.setupAutoLockManager(lifecycle)
        binding.toolbar.setNodeStatus(indexerInterceptor.currentActiveNode)
        setupSendRequestTabBarView()
        setupWalletConnectManager()

        binding.foregroundNotificationView.apply {
            setListener(this@MainActivity)
            accounts = accountManager.getAccounts()
        }

        initObservers()

        if (savedInstanceState == null) {
            handleDeeplinkAndNotificationNavigation()
        }
    }

    override fun onResume() {
        super.onResume()
        if (accountManager.isThereAnyRegisteredAccount()) {
            mainViewModel.activateBlockPolling()
        }
    }

    override fun onPause() {
        super.onPause()
        mainViewModel.stopBlockPolling()
    }

    override fun onPopupConfirmation(
        type: AssetActionBottomSheet.Type,
        popupAsset: AssetInformation,
        publicKey: String?
    ) {
        if (type == AssetActionBottomSheet.Type.UNSUPPORTED_NOTIFICATION_REQUEST && !publicKey.isNullOrBlank()) {
            val accountCacheData = accountCacheManager.getCacheData(publicKey) ?: return
            transactionManager.setup(lifecycle)
            transactionManager.signTransaction(TransactionData.AddAsset(accountCacheData, popupAsset))
        }
    }

    override fun onNotificationClick(publicKeyToActivate: String?, assetIdToActivate: Long?) {
        if (publicKeyToActivate != null && assetIdToActivate != null) {
            val accountCacheData = accountCacheManager.getCacheData(publicKeyToActivate)
            val assetInformation = accountCacheManager.getAssetInformation(publicKeyToActivate, assetIdToActivate)
            if (accountCacheData != null && assetInformation != null) {
                nav(actionGlobalAssetDetailFragment(assetInformation, accountCacheData.account.address))
            }
        }
    }

    private fun initObservers() {
        algorandNotificationManager.newNotificationLiveData.observe(this, newNotificationObserver)

        accountManager.isFirebaseTokenChanged.observe(this, Observer {
            if (it.consume() != null) {
                mainViewModel.registerDevice()
            }
        })

        lifecycleScope.launch {
            // Drop 1 added to get any list changes.
            accountManager.accounts.drop(1).collect { accounts ->
                mainViewModel.refreshAccountBalances()
                mainViewModel.registerDevice()
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
                }
            }
        })

        mainViewModel.autoLockLiveData.observe(this, autoLockManagerObserver)

        mainViewModel.accountBalanceSyncStatus.observe(this, assetSetupCompletedObserver)

        walletConnectViewModel.requestLiveData.observe(this, ::handleWalletConnectTransactionRequest)

        lifecycleScope.launch {
            walletConnectViewModel.sessionResultFlow.collectLatest(::onNewSessionEvent)
        }
    }

    private fun setupWalletConnectManager() {
        lifecycle.addObserver(walletConnectManager)
    }

    private fun handleWalletConnectTransactionRequest(requestEvent: Event<Resource<WalletConnectTransaction>>?) {
        requestEvent?.consume()?.use(
            onSuccess = ::onNewWalletConnectTransactionRequest
        )
    }

    private fun onNewWalletConnectTransactionRequest(transaction: WalletConnectTransaction) {
        nav(HomeNavigationDirections.actionGlobalWalletConnectRequestNavigation(transaction))
    }

    private fun handleDeeplinkAndNotificationNavigation() {
        intent.getParcelableExtra<Intent?>(DEEPLINK_AND_NAVIGATION_INTENT)?.apply {
            pendingIntent = this
            handlePendingIntent()
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        pendingIntent = intent?.getParcelableExtra(DEEPLINK_AND_NAVIGATION_INTENT)
        handlePendingIntent()
    }

    private fun handlePendingIntent(): Boolean {
        pendingIntent?.apply {
            if (isAssetSetupCompleted && isAppUnlocked) {
                val handled = navController.handleIntent(
                    this,
                    accountCacheManager,
                    supportFragmentManager,
                    ::handleWalletConnectDeepLink
                )
                pendingIntent = null
                return handled
            }
        }
        return false
    }

    private fun handleWalletConnectDeepLink(walletConnectUrl: String) {
        val hasValidAccountForWalletConnect = accountCacheManager.getAccountCacheWithSpecificAsset(
            AssetInformation.ALGORAND_ID,
            listOf(Account.Type.WATCH)
        ).isNotEmpty()
        if (hasValidAccountForWalletConnect) {
            showProgress()
            walletConnectViewModel.connectToSessionByUrl(walletConnectUrl)
        } else {
            showGlobalError(getString(R.string.you_do_not_have_any))
        }
    }

    private fun setupSendRequestTabBarView() {
        binding.sendReceiveTabBarView.setListener(object : SendReceiveTabBarView.Listener {
            override fun onSendClick() {
                firebaseAnalytics.logTapSend()
                nav(actionGlobalAssetSelectionBottomSheet(flowType = AssetSelectionBottomSheet.FlowType.SEND))
            }

            override fun onRequestClick() {
                firebaseAnalytics.logTapReceive()
                nav(actionGlobalAssetSelectionBottomSheet(flowType = AssetSelectionBottomSheet.FlowType.REQUEST))
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

    fun onNewNodeActivated(activatedNode: Node) {
        mainViewModel.registerDevice()
        mainViewModel.getVerifiedAssets()
        mainViewModel.resetBlockPolling()
        binding.toolbar.setNodeStatus(activatedNode)
        checkIfConnectedToTestNet()
    }

    override fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult) {
        handleSessionConnectionResult(wCSessionRequestResult)
    }

    private fun handleSessionConnectionResult(result: WCSessionRequestResult) {
        with(walletConnectViewModel) {
            when (result) {
                is WCSessionRequestResult.ApproveRequest -> approveSession(result)
                is WCSessionRequestResult.RejectRequest -> rejectSession(result.session)
            }
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
    }
}
