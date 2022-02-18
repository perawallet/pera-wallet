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

package com.algorand.android.ui.accounts

import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.MainActivity
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentAccountsBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.QrScanner
import com.algorand.android.models.ScreenState
import com.algorand.android.models.TabButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accountoptions.HomeAccountOptionsBottomSheet
import com.algorand.android.ui.accountoptions.HomeAccountOptionsBottomSheet.Companion.DESTINATION_RESULT
import com.algorand.android.ui.accountoptions.HomeAccountOptionsBottomSheet.HomeAccountOptionsResult.AddAccount
import com.algorand.android.ui.common.listhelper.AccountAdapter
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountsFragment : DaggerBaseFragment(R.layout.fragment_accounts) {

    /**
     * TODO
     * - init error state
     */

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val toolbarConfiguration = ToolbarConfiguration(
        showNodeStatus = true,
        startIconResId = R.drawable.ic_notification,
        startIconClick = ::navigateToNotifications
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    private val binding by viewBinding(FragmentAccountsBinding::bind)

    private val accountsViewModel: AccountsViewModel by viewModels()

    private val accountsEmptyState by lazy {
        ScreenState.CustomState(
            icon = R.drawable.ic_menu_wallet,
            title = R.string.create_an_account,
            description = R.string.you_need_to_create,
            buttonText = R.string.create_new_account
        )
    }

    private var accountAdapter: AccountAdapter =
        AccountAdapter(::onLoadedAccountClick, ::onErrorAccountClick, ::onAccountOptionsClick, ::onPortfolioInfoClick)

    private val accountListCollector: suspend (List<BaseAccountListItem>) -> Unit = {
        loadAccountsAndBalancePreview(it)
    }

    private val emptyStateVisibilityCollector: suspend (Boolean) -> Unit = { isEmptyStateVisible ->
        binding.emptyScreenStateView.isVisible = isEmptyStateVisible
    }

    private val fullScreenLoadingCollector: suspend (Boolean) -> Unit = { isFullScreenLoadingVisible ->
        binding.loadingProgressBar.isVisible = isFullScreenLoadingVisible
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        (activity as MainActivity).isAppUnlocked = true
        configureToolbar()
        initObservers()
        initSavedStateListener()
        initUi()
    }

    private fun initUi() {
        binding.accountsRecyclerView.apply {
            adapter = accountAdapter
            itemAnimator = null
        }
        // TODO implement swipe to refresh instead of disabling
        binding.swipeRefreshLayout.isEnabled = false
        binding.emptyScreenStateView.apply {
            setOnNeutralButtonClickListener(::onAddAccountClick)
            setupUi(accountsEmptyState)
        }
    }

    override fun onResume() {
        super.onResume()
        navigateToPeraIntroductionFragmentIfNeed()
    }

    private fun configureToolbar() {
        getAppToolbar()?.apply {
            addButtonToEnd(IconButton(R.drawable.ic_scan_qr, onClick = ::onScanQrClick))
            addButtonToEnd(TabButton(R.drawable.ic_add, R.color.layerGrayLighter, onClick = ::onAddAccountClick))
        }
    }

    private fun initObservers() {
        with(accountsViewModel) {
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it.accountListItems }.collectLatest(accountListCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it.isFullScreenAnimatedLoadingVisible }
                    .collectLatest(fullScreenLoadingCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it.isEmptyStateVisible }.collect(emptyStateVisibilityCollector)
            }
        }
    }

    private fun loadAccountsAndBalancePreview(accountListItems: List<BaseAccountListItem>) {
        accountAdapter.submitList(accountListItems)
    }

    private fun navigateToPeraIntroductionFragmentIfNeed() {
        if (accountsViewModel.shouldShowPeraIntroductionFragment()) {
            nav(AccountsFragmentDirections.actionAccountsFragmentToPeraIntroductionFragment())
        }
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.accountsFragment) {
            useSavedStateValue<DecodedQrCode?>(QrCodeScannerFragment.QR_SCAN_RESULT_KEY) {
                handleWalletConnectUrl(it?.walletConnectUrl.orEmpty())
            }
            useSavedStateValue<HomeAccountOptionsBottomSheet.HomeAccountOptionsResult>(DESTINATION_RESULT) {
                handleAccountOptionsResult(it)
            }
        }
    }

    private fun onScanQrClick() {
        nav(
            AccountsFragmentDirections.actionAccountsFragmentToQrCodeScannerNavigation(
                QrScanner(
                    scanTypes = arrayOf(
                        QrCodeScannerFragment.ScanReturnType.NAVIGATE_FORWARD,
                        QrCodeScannerFragment.ScanReturnType.WALLET_CONNECT
                    ),
                    isShowingWCSessionsButton = true
                )
            )
        )
    }

    private fun onLoadedAccountClick(publicKey: String) {
        nav(AccountsFragmentDirections.actionAccountsFragmentToAccountDetailFragment(publicKey))
    }

    private fun onErrorAccountClick(publicKey: String) {
        nav(AccountsFragmentDirections.actionAccountsFragmentToAccountErrorOptionsBottomSheet(publicKey))
    }

    private fun onAccountOptionsClick(isWatchAccount: Boolean) {
        nav(AccountsFragmentDirections.actionAccountsFragmentToHomeAccountOptionsBottomSheet(isWatchAccount))
    }

    private fun onPortfolioInfoClick(portfolioItem: BaseAccountListItem.BasePortfolioValueItem) {
        navToPortfolioInfoBottomSheet(portfolioItem)
    }

    private fun navigateToNotifications() {
        nav(AccountsFragmentDirections.actionAccountsFragmentToNotificationCenterFragment())
    }

    private fun handleAccountOptionsResult(result: HomeAccountOptionsBottomSheet.HomeAccountOptionsResult) {
        if (result is AddAccount) onAddAccountClick() else onArrangeListClick(result.isWatchAccount)
    }

    private fun onAddAccountClick() {
        nav(MainNavigationDirections.actionNewAccount())
    }

    private fun onArrangeListClick(isWatchAccount: Boolean) {
        if (isWatchAccount) {
            nav(AccountsFragmentDirections.actionAccountsFragmentToWatchAccountOrderFragment())
        } else {
            nav(AccountsFragmentDirections.actionAccountsFragmentToStandardAccountOrderFragment())
        }
    }

    private fun navToPortfolioInfoBottomSheet(portfolioItem: BaseAccountListItem.BasePortfolioValueItem) {
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.how_we_calculate_portfolio),
                descriptionAnnotatedString = AnnotatedString(R.string.the_total_portfolio_value),
                errorAnnotatedString = portfolioItem.errorStringResId?.run { AnnotatedString(this) }
            )
        )
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_accounts"
    }
}
