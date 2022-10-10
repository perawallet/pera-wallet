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

package com.algorand.android.modules.accounts.ui

import android.graphics.drawable.Drawable
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.CoreMainActivity
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.MainActivity
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BackPressedControllerComponent
import com.algorand.android.core.BottomNavigationBackPressedDelegate
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentAccountsBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ScreenState
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem
import com.algorand.android.modules.accounts.domain.model.BasePortfolioValueItem
import com.algorand.android.modules.accounts.ui.adapter.AccountAdapter
import com.algorand.android.tutorialdialog.util.showCopyAccountAddressTutorialDialog
import com.algorand.android.utils.TestnetBadgeDrawable
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.setDrawableTintColor
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@Suppress("TooManyFunctions")
@AndroidEntryPoint
class AccountsFragment :
    DaggerBaseFragment(R.layout.fragment_accounts),
    BackPressedControllerComponent by BottomNavigationBackPressedDelegate() {

    override val fragmentConfiguration = FragmentConfiguration(
        isBottomBarNeeded = true,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    private val binding by viewBinding(FragmentAccountsBinding::bind)

    private val accountsViewModel: AccountsViewModel by viewModels()

    private val accountsEmptyState by lazy {
        ScreenState.CustomState(
            icon = R.drawable.ic_wallet,
            title = R.string.create_an_account,
            description = R.string.you_need_to_create,
            buttonText = R.string.create_new_account
        )
    }

    private val accountAdapterListener = object : AccountAdapter.AccountAdapterListener {
        override fun onSucceedAccountClick(publicKey: String) {
            nav(AccountsFragmentDirections.actionAccountsFragmentToAccountDetailFragment(publicKey))
        }

        override fun onFailedAccountClick(publicKey: String) {
            nav(AccountsFragmentDirections.actionAccountsFragmentToAccountErrorOptionsBottomSheet(publicKey))
        }

        override fun onAccountItemLongPressed(publicKey: String) {
            onAccountAddressCopied(publicKey)
        }

        override fun onBannerCloseButtonClick(bannerId: Long) {
            accountsViewModel.onCloseBannerClick(bannerId)
        }

        override fun onBannerActionButtonClick(url: String, isGovernance: Boolean) {
            accountsViewModel.onBannerActionButtonClick(isGovernance)
            context?.openUrl(url)
        }

        override fun onBuyAlgoClick() {
            accountsViewModel.logAccountsFragmentAlgoBuyTapEvent()
            navToMoonpayIntroFragment()
        }

        override fun onSendClick() {
            navToSendAlgoNavigation()
        }

        override fun onReceiveClick() {
            navToReceiveAccountSelectionFragment()
        }

        override fun onScanQrClick() {
            accountsViewModel.logQrScanTapEvent()
            navToQrScanFragment()
        }

        override fun onSortClick() {
            onArrangeListClick()
        }

        override fun onAddAccountClick() {
            this@AccountsFragment.onAddAccountClick()
        }
    }

    private val accountAdapter: AccountAdapter = AccountAdapter(accountAdapterListener = accountAdapterListener)

    private val accountListCollector: suspend (List<BaseAccountListItem>?) -> Unit = { accountList ->
        accountList?.let { safeList ->
            loadAccountsAndBalancePreview(safeList)
        }
    }

    private val testnetBadgeDrawable: Drawable? by lazy {
        context?.run {
            TestnetBadgeDrawable.toDrawable(this)
        }
    }

    private val emptyStateVisibilityCollector: suspend (Boolean?) -> Unit = { isEmptyStateVisible ->
        binding.emptyScreenStateView.isVisible = isEmptyStateVisible == true
        binding.notificationImageButton.isInvisible = isEmptyStateVisible == true
    }

    private val fullScreenLoadingCollector: suspend (Boolean?) -> Unit = { isFullScreenLoadingVisible ->
        binding.loadingProgressBar.isVisible = isFullScreenLoadingVisible == true
    }

    private val testnetBadgeVisibilityCollector: suspend (Boolean?) -> Unit = { isTestnetBadgeVisible ->
        initToolbarTestnetBadge(isTestnetBadgeVisible)
    }

    private val accountsPortfolioValuesCollector: suspend (BasePortfolioValueItem?) -> Unit = {
        if (it != null) setPortfolioValues(it)
    }

    private val copyAccountAddressTutorialCollector: suspend (Boolean?) -> Unit = { event ->
        event.let { shouldShow -> if (shouldShow == true) showTutorialDialog() }
    }

    private val portfolioValuesBackgroundColorCollector: suspend (Int?) -> Unit = {
        if (it != null) binding.toolbarLayout.setBackgroundColor(ContextCompat.getColor(binding.root.context, it))
    }

    private val successStateVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        if (isVisible != null) {
            with(binding) {
                portfolioValueTitleTextView.isInvisible = !isVisible
                primaryPortfolioValue.isInvisible = !isVisible
                secondaryPortfolioValue.isInvisible = !isVisible
                accountsRecyclerView.isInvisible = !isVisible
                if (isVisible.not()) binding.accountsFragmentMotionLayout.transitionToState(R.id.start)
                accountsFragmentMotionLayout.getTransition(R.id.accountsFragmentTransition).isEnabled = isVisible
            }
        }
    }

    private val notificationStateCollector: suspend (Boolean?) -> Unit = { isActive ->
        if (isActive != null) {
            binding.notificationImageButton.isActivated = isActive
        }
    }

    private fun showTutorialDialog() {
        binding.root.context.showCopyAccountAddressTutorialDialog(
            onDismiss = { accountsViewModel.onTutorialDialogClosed() }
        )
    }

    private fun setPortfolioValues(portfolioValues: BasePortfolioValueItem) {
        with(binding) {
            primaryPortfolioValue.apply { text = portfolioValues.getPrimaryAccountValue(context) }
            secondaryPortfolioValue.apply { text = portfolioValues.getSecondaryAccountValue(context) }
            portfolioValueTitleTextView.apply {
                setTextColor(ContextCompat.getColor(root.context, portfolioValues.titleColorResId))
                setDrawableTintColor(portfolioValues.titleColorResId)
                setOnClickListener { navToPortfolioInfoBottomSheet(portfolioValues) }
            }
        }
    }

    private fun initToolbarTestnetBadge(isTestnetBadgeVisible: Boolean?) {
        val centerDrawable = if (isTestnetBadgeVisible == true) testnetBadgeDrawable else null
        binding.nodeImageView.apply {
            isVisible = centerDrawable != null
            setImageDrawable(centerDrawable ?: return)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        (activity as? CoreMainActivity)?.let { initBackPressedControllerComponent(it, viewLifecycleOwner) }
        (activity as MainActivity).isAppUnlocked = true
        initObservers()
        initUi()
    }

    private fun initUi() {
        binding.accountsRecyclerView.apply {
            adapter = accountAdapter
            itemAnimator = null
        }
        binding.emptyScreenStateView.apply {
            setOnNeutralButtonClickListener(::onAddAccountClick)
            setupUi(accountsEmptyState)
        }
        binding.notificationImageButton.setOnClickListener { navigateToNotifications() }
    }

    override fun onResume() {
        super.onResume()
        accountsViewModel.refreshCachedAlgoPrice()
    }

    private fun initObservers() {
        with(accountsViewModel) {
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.accountListItems },
                accountListCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.isFullScreenAnimatedLoadingVisible },
                fullScreenLoadingCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.isEmptyStateVisible },
                emptyStateVisibilityCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.isTestnetBadgeVisible },
                testnetBadgeVisibilityCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.portfolioValueItem }.distinctUntilChanged(),
                accountsPortfolioValuesCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.shouldShowDialog }.distinctUntilChanged(),
                copyAccountAddressTutorialCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.portfolioValuesBackgroundRes }.distinctUntilChanged(),
                portfolioValuesBackgroundColorCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.isSuccessStateVisible }.distinctUntilChanged(),
                successStateVisibilityCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                accountPreviewFlow.map { it?.hasNewNotification }.distinctUntilChanged(),
                notificationStateCollector
            )
        }
    }

    private fun loadAccountsAndBalancePreview(accountListItems: List<BaseAccountListItem>) {
        accountAdapter.submitList(accountListItems)
    }

    private fun navToQrScanFragment() {
        nav(HomeNavigationDirections.actionGlobalAccountsQrScannerFragment())
    }

    private fun navigateToNotifications() {
        nav(AccountsFragmentDirections.actionAccountsFragmentToNotificationCenterFragment())
    }

    private fun onAddAccountClick() {
        accountsViewModel.logAddAccountTapEvent()
        // TODO: Handle this in error with an event inside preview
        if (accountsViewModel.isAccountLimitExceed()) {
            showMaxAccountLimitExceededError()
            return
        }
        nav(MainNavigationDirections.actionNewAccount(shouldNavToRegisterWatchAccount = false))
    }

    private fun onArrangeListClick() {
        nav(AccountsFragmentDirections.actionAccountsFragmentToStandardAccountOrderFragment())
    }

    private fun navToPortfolioInfoBottomSheet(portfolio: BasePortfolioValueItem) {
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.how_we_calculate_portfolio),
                descriptionAnnotatedString = AnnotatedString(R.string.the_total_portfolio_value),
                errorAnnotatedString = portfolio.errorStringResId?.run { AnnotatedString(this) }
            )
        )
    }

    private fun navToMoonpayIntroFragment() {
        nav(AccountsFragmentDirections.actionAccountsFragmentToMoonpayNavigation())
    }

    private fun navToSendAlgoNavigation() {
        nav(AccountsFragmentDirections.actionGlobalSendAlgoNavigation(null))
    }

    private fun navToReceiveAccountSelectionFragment() {
        nav(AccountsFragmentDirections.actionGlobalReceiveAccountSelectionFragment())
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_accounts"
    }
}
