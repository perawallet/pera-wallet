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

@file:Suppress("TooManyFunctions")

/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.modules.accountdetail.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.NavDirections
import androidx.navigation.fragment.navArgs
import androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountDetailBinding
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.DateFilter
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.ToolbarImageButton
import com.algorand.android.modules.accountdetail.assets.ui.AccountAssetsFragment
import com.algorand.android.modules.accountdetail.collectibles.ui.AccountCollectiblesFragment
import com.algorand.android.modules.accountdetail.history.ui.AccountHistoryFragment
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailEntryPoint
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.ui.accounts.RenameAccountBottomSheet
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.Event
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.tabs.TabLayoutMediator
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountDetailFragment :
    BaseFragment(R.layout.fragment_account_detail),
    AccountHistoryFragment.Listener,
    AccountAssetsFragment.Listener,
    AccountCollectiblesFragment.Listener {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    private val onPageChangeCallback = object : OnPageChangeCallback() {
        override fun onPageSelected(position: Int) {
            super.onPageSelected(position)
            onSelectedPageChange(position)
        }
    }

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentAccountDetailBinding::bind)

    private val accountDetailViewModel: AccountDetailViewModel by viewModels()

    private val args: AccountDetailFragmentArgs by navArgs()

    private val accountDetailSummaryCollector: suspend (AccountDetailSummary?) -> Unit = { summary ->
        if (summary != null) initAccountDetailSummary(summary)
    }

    private val accountDetailTabArgCollector: suspend (Event<Int>?) -> Unit = {
        it?.consume()?.run { updateViewPagerBySelectedTab(this) }
    }

    private val swapNavigationDirectionEventCollector: suspend (Event<NavDirections>?) -> Unit = {
        it?.consume()?.run { nav(this) }
    }

    private val copyAssetIDToClipboardEventCollector: suspend (Event<Long>?) -> Unit = {
        it?.consume()?.run {
            context?.copyToClipboard(textToCopy = this.toString(), showToast = false)
            showTopToast(getString(R.string.asset_id_copied_to_clipboard), this.toString())
        }
    }

    private lateinit var accountDetailPagerAdapter: AccountDetailPagerAdapter

    override fun onStandardTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
        nav(
            AccountDetailFragmentDirections.actionAccountDetailFragmentToTransactionDetailNavigation(
                transactionId = transaction.id ?: return,
                accountAddress = accountDetailViewModel.accountPublicKey,
                entryPoint = TransactionDetailEntryPoint.STANDARD_TRANSACTION
            )
        )
    }

    override fun onApplicationCallTransactionClick(
        transaction: BaseTransactionItem.TransactionItem.ApplicationCallItem
    ) {
        nav(
            AccountDetailFragmentDirections.actionAccountDetailFragmentToTransactionDetailNavigation(
                transactionId = transaction.id ?: return,
                accountAddress = accountDetailViewModel.accountPublicKey,
                entryPoint = TransactionDetailEntryPoint.APPLICATION_CALL_TRANSACTION
            )
        )
    }

    override fun onFilterTransactionClick(dateFilter: DateFilter) {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToDateFilterNavigation(dateFilter))
    }

    override fun onAddAssetClick() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToAssetAdditionNavigation(args.publicKey))
    }

    override fun onAssetClick(assetId: Long) {
        val publicKey = accountDetailViewModel.accountPublicKey
        nav(
            AccountDetailFragmentDirections.actionAccountDetailFragmentToAssetProfileNavigation(
                assetId = assetId,
                accountAddress = publicKey
            )
        )
    }

    override fun onAssetLongClick(assetId: Long) {
        accountDetailViewModel.onAssetLongClick(assetId)
    }

    override fun onNFTClick(nftId: Long) {
        navToCollectibleDetailFragment(nftId)
    }

    override fun onNFTLongClick(nftId: Long) {
        accountDetailViewModel.onAssetLongClick(nftId)
    }

    override fun onBuyAlgoClick() {
        navToMoonpayIntroFragment()
    }

    override fun onSendClick() {
        navToSendNavigation()
    }

    override fun onSwapClick() {
        accountDetailViewModel.onSwapClick()
    }

    override fun onMoreClick() {
        navToAccountOptionsBottomSheet()
    }

    override fun onManageAssetsClick() {
        navToManageAssetsFragment()
    }

    override fun onAccountQuickActionsFloatingActionButtonClicked() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToAccountQuickActionsBottomSheet(args.publicKey))
    }

    override fun onMinimumBalanceInfoClick() {
        navToMinimumBalanceInfoBottomSheet()
    }

    override fun onImageItemClick(nftAssetId: Long) {
        navToCollectibleDetailFragment(nftAssetId)
    }

    override fun onVideoItemClick(nftAssetId: Long) {
        navToCollectibleDetailFragment(nftAssetId)
    }

    override fun onSoundItemClick(nftAssetId: Long) {
        navToCollectibleDetailFragment(nftAssetId)
    }

    override fun onGifItemClick(nftAssetId: Long) {
        // TODO "Not yet implemented"
    }

    override fun onNotSupportedItemClick(nftAssetId: Long) {
        navToCollectibleDetailFragment(nftAssetId)
    }

    override fun onMixedItemClick(nftAssetId: Long) {
        navToCollectibleDetailFragment(nftAssetId)
    }

    private fun navToCollectibleDetailFragment(collectibleId: Long) {
        nav(
            AccountDetailFragmentDirections.actionAccountDetailFragmentToCollectibleDetailFragment(
                collectibleId,
                args.publicKey
            )
        )
    }

    override fun onReceiveCollectibleClick() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToReceiveCollectibleFragment(args.publicKey))
    }

    override fun onManageCollectiblesClick() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToManageAccountNFTsBottomSheet())
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    override fun onStart() {
        super.onStart()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.accountDetailFragment) {
            useSavedStateValue<Boolean>(WarningConfirmationBottomSheet.WARNING_CONFIRMATION_KEY) {
                if (it) {
                    accountDetailViewModel.removeAccount(args.publicKey)
                    navBack()
                }
            }

            useSavedStateValue<Boolean>(RenameAccountBottomSheet.RENAME_ACCOUNT_KEY) { isNameChanged ->
                if (isNameChanged) {
                    accountDetailViewModel.initAccountDetailSummary()
                }
            }
        }
    }

    private fun initUi() {
        initAccountDetailPager()
        setupTabLayout()
    }

    private fun initObservers() {
        viewLifecycleOwner.collectOnLifecycle(
            accountDetailViewModel.accountDetailSummaryFlow,
            accountDetailSummaryCollector
        )
        viewLifecycleOwner.collectOnLifecycle(
            accountDetailViewModel.accountDetailTabArgFlow,
            accountDetailTabArgCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            accountDetailViewModel.accountDetailPreviewFlow
                .map { it?.swapNavigationDirectionEvent }.distinctUntilChanged(),
            swapNavigationDirectionEventCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            accountDetailViewModel.accountDetailPreviewFlow
                .map { it?.copyAssetIDToClipboardEvent }
                .distinctUntilChanged(),
            copyAssetIDToClipboardEventCollector
        )
    }

    private fun setupTabLayout() {
        with(binding) {
            accountDetailViewPager.isUserInputEnabled = false
            accountDetailViewPager.registerOnPageChangeCallback(onPageChangeCallback)
            TabLayoutMediator(algorandTabLayout, accountDetailViewPager) { tab, position ->
                accountDetailPagerAdapter.getItem(position)?.titleResId?.let {
                    tab.text = getString(it)
                }
            }.attach()
        }
    }

    private fun initAccountDetailSummary(accountDetailSummary: AccountDetailSummary) {
        with(binding) {
            configureToolbar(accountDetailSummary)
        }
    }

    fun configureToolbar(accountDetailSummary: AccountDetailSummary) {
        binding.toolbar.apply {
            configure(toolbarConfiguration)
            configureToolbarName(accountDetailSummary)
            setOnTitleLongClickListener { onAccountAddressCopied(accountDetailSummary.publicKey) }
            val drawableWidth = resources.getDimension(R.dimen.toolbar_title_drawable_size).toInt()
            AccountIconDrawable.create(context, accountDetailSummary.accountIconResource, drawableWidth)?.run {
                setEndButton(button = ToolbarImageButton(this, onClick = ::navToAccountOptionsBottomSheet))
            }
        }
    }

    private fun configureToolbarName(accountDetailSummary: AccountDetailSummary) {
        with(binding.toolbar) {
            changeTitle(accountDetailSummary.accountDisplayName.getAccountPrimaryDisplayName())
            accountDetailSummary.accountDisplayName.getAccountSecondaryDisplayName(resources)?.let {
                changeSubtitle(it)
            }
        }
    }

    private fun navToAccountOptionsBottomSheet() {
        val publicKey = accountDetailViewModel.accountPublicKey
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToAccountOptionsNavigation(publicKey))
    }

    private fun initAccountDetailPager() {
        accountDetailPagerAdapter = AccountDetailPagerAdapter(this, args.publicKey)
        binding.accountDetailViewPager.adapter = accountDetailPagerAdapter
    }

    private fun updateViewPagerBySelectedTab(selectedTab: Int) {
        binding.accountDetailViewPager.post {
            binding.accountDetailViewPager.setCurrentItem(selectedTab, false)
        }
    }

    private fun navToMoonpayIntroFragment() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToMoonpayNavigation(args.publicKey))
    }

    private fun navToSendNavigation() {
        nav(
            HomeNavigationDirections.actionGlobalSendAlgoNavigation(
                assetTransaction = AssetTransaction(senderAddress = args.publicKey)
            )
        )
    }

    private fun navToManageAssetsFragment() {
        nav(
            AccountDetailFragmentDirections.actionAccountDetailFragmentToManageAssetsBottomSheet(
                publicKey = args.publicKey,
                canSignTransaction = accountDetailViewModel.getCanSignTransaction()
            )
        )
    }

    private fun onSelectedPageChange(position: Int) {
        with(accountDetailViewModel) {
            when (accountDetailPagerAdapter.getItem(position)?.fragmentInstance) {
                is AccountAssetsFragment -> logAccountDetailAssetsTapEventTracker()
                is AccountCollectiblesFragment -> logAccountDetailCollectiblesTapEventTracker()
                is AccountHistoryFragment -> logAccountDetailTransactionHistoryTapEventTracker()
            }
        }
    }

    private fun navToMinimumBalanceInfoBottomSheet() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToRequiredMinimumBalanceInformationBottomSheet())
    }
}
