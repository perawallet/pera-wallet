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
import androidx.lifecycle.lifecycleScope
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
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ScreenState
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem
import com.algorand.android.modules.accounts.domain.model.BasePortfolioValue
import com.algorand.android.modules.accounts.ui.adapter.AccountAdapter
import com.algorand.android.tutorialdialog.util.showCopyAccountAddressTutorialDialog
import com.algorand.android.ui.assetaction.AddAssetActionBottomSheet.Companion.ADD_ASSET_ACTION_RESULT
import com.algorand.android.utils.TestnetBadgeDrawable
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.setDrawableTintColor
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@Suppress("TooManyFunctions")
@AndroidEntryPoint
class AccountsFragment : DaggerBaseFragment(R.layout.fragment_accounts),
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
            copyPublicKeyToClipboard(publicKey)
        }

        override fun onBannerCloseButtonClick(bannerId: Long) {
            accountsViewModel.onCloseBannerClick(bannerId)
        }

        override fun onBannerActionButtonClick(url: String) {
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

    private val motionLayoutTransition by lazy {
        binding.accountsFragmentMotionLayout.getTransition(R.id.accountsFragmentTransition)
    }

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
    }

    private val fullScreenLoadingCollector: suspend (Boolean?) -> Unit = { isFullScreenLoadingVisible ->
        binding.loadingProgressBar.isVisible = isFullScreenLoadingVisible == true
    }

    private val testnetBadgeVisibilityCollector: suspend (Boolean?) -> Unit = { isTestnetBadgeVisible ->
        initToolbarTestnetBadge(isTestnetBadgeVisible)
    }

    private val accountsPortfolioValuesCollector: suspend (BasePortfolioValue.PortfolioValues?) -> Unit = {
        if (it != null) setPortfolioValues(it)
    }

    private val accountsPortfolioValuesErrorCollector: suspend (BasePortfolioValue.PortfolioValuesError?) -> Unit = {
        if (it != null) setPortfolioValuesError(it)
    }

    private val copyAccountAddressTutorialCollector: suspend (Boolean?) -> Unit = { event ->
        event.let { shouldShow -> if (shouldShow == true) showTutorialDialog() }
    }

    private val motionLayoutAbilityCollector: suspend (Boolean?) -> Unit = {
        motionLayoutTransition.isEnabled = it == true
    }

    private val portfolioValuesBackgroundColorCollector: suspend (Int?) -> Unit = {
        if (it != null) binding.toolbarLayout.setBackgroundColor(ContextCompat.getColor(binding.root.context, it))
    }

    private val portfolioValueVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        if (isVisible != null) {
            with(binding) {
                portfolioValueTitleTextView.isInvisible = !isVisible
                primaryPortfolioValue.isInvisible = !isVisible
                secondaryPortfolioValue.isInvisible = !isVisible
            }
        }
    }

    private fun showTutorialDialog() {
        binding.root.context.showCopyAccountAddressTutorialDialog(
            onDismiss = { accountsViewModel.onTutorialDialogClosed() }
        )
    }

    private fun setPortfolioValues(portfolioValues: BasePortfolioValue.PortfolioValues) {
        with(binding) {
            primaryPortfolioValue.text = portfolioValues.formattedPrimaryAccountValue
            secondaryPortfolioValue.text = root.resources.getString(
                R.string.approximate_currency_value,
                portfolioValues.formattedSecondaryAccountValue
            )
            portfolioValueTitleTextView.apply {
                setTextColor(ContextCompat.getColor(root.context, R.color.secondary_text_color))
                setDrawableTintColor(R.color.secondary_text_color)
                setOnClickListener { navToPortfolioInfoBottomSheet(portfolioValues) }
            }
        }
    }

    private fun setPortfolioValuesError(portfolioValuesError: BasePortfolioValue.PortfolioValuesError) {
        with(binding) {
            val notAvailableText = root.resources.getString(R.string.not_available_shortened)
            primaryPortfolioValue.text = notAvailableText
            secondaryPortfolioValue.text = notAvailableText
            portfolioValueTitleTextView.apply {
                setTextColor(ContextCompat.getColor(root.context, portfolioValuesError.titleColorResId))
                setDrawableTintColor(portfolioValuesError.titleColorResId)
                setOnClickListener { navToPortfolioInfoBottomSheet(portfolioValuesError) }
                show()
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
        initSavedStateListener()
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
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.accountListItems }.collectLatest(accountListCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.isFullScreenAnimatedLoadingVisible }
                    .collectLatest(fullScreenLoadingCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.isEmptyStateVisible }.collect(emptyStateVisibilityCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.isTestnetBadgeVisible }.collectLatest(testnetBadgeVisibilityCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.portfolioValues }.collectLatest(accountsPortfolioValuesCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.portfolioValuesError }.collectLatest(accountsPortfolioValuesErrorCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.shouldShowDialog }
                    .distinctUntilChanged()
                    .collectLatest(copyAccountAddressTutorialCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.isMotionLayoutTransitionEnabled }
                    .distinctUntilChanged()
                    .collectLatest(motionLayoutAbilityCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.portfolioValuesBackgroundRes }
                    .distinctUntilChanged()
                    .collectLatest(portfolioValuesBackgroundColorCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                accountPreviewFlow.map { it?.isPortfolioValueGroupVisible }
                    .distinctUntilChanged()
                    .collectLatest(portfolioValueVisibilityCollector)
            }
        }
    }

    private fun loadAccountsAndBalancePreview(accountListItems: List<BaseAccountListItem>) {
        accountAdapter.submitList(accountListItems)
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.accountsFragment) {
            useSavedStateValue<AssetActionResult>(ADD_ASSET_ACTION_RESULT) { assetActionResult ->
                (activity as? MainActivity)?.signAddAssetTransaction(assetActionResult)
            }
        }
    }

    private fun navToQrScanFragment() {
        nav(HomeNavigationDirections.actionGlobalAccountsQrScannerFragment())
    }

    private fun navigateToNotifications() {
        nav(AccountsFragmentDirections.actionAccountsFragmentToNotificationCenterFragment())
    }

    private fun onAddAccountClick() {
        accountsViewModel.logAddAccountTapEvent()
        nav(MainNavigationDirections.actionNewAccount(shouldNavToRegisterWatchAccount = false))
    }

    private fun onArrangeListClick() {
        nav(AccountsFragmentDirections.actionAccountsFragmentToStandardAccountOrderFragment())
    }

    private fun navToPortfolioInfoBottomSheet(portfolio: BasePortfolioValue) {
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

    private fun copyPublicKeyToClipboard(publicKey: String) {
        context?.copyToClipboard(publicKey, showToast = false)
        showTopToast(getString(R.string.address_copied_to_clipboard), publicKey.toShortenedAddress())
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_accounts"
    }
}
