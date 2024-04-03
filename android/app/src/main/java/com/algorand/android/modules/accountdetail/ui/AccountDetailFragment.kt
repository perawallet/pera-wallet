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
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.toolbar.buttoncontainer.model.BaseAccountIconButton
import com.algorand.android.databinding.FragmentAccountDetailBinding
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.DateFilter
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.accountdetail.assets.ui.AccountAssetsFragment
import com.algorand.android.modules.accountdetail.collectibles.ui.AccountCollectiblesFragment
import com.algorand.android.modules.accountdetail.haveyoubackedupconfirmation.ui.HaveYouBackedUpAccountConfirmationBottomSheet.Companion.HAVE_YOU_BACKED_UP_ACCOUNT_CONFIRMATION_KEY
import com.algorand.android.modules.accountdetail.history.ui.AccountHistoryFragment
import com.algorand.android.modules.accountdetail.removeaccount.ui.RemoveAccountConfirmationBottomSheet.Companion.ACCOUNT_REMOVE_CONFIRMATION_KEY
import com.algorand.android.modules.inapppin.pin.ui.InAppPinFragment
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailEntryPoint
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.ui.accountoptions.AccountOptionsBottomSheet.Companion.ACCOUNT_REMOVE_ACTION_KEY
import com.algorand.android.ui.accounts.RenameAccountBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.emptyString
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.tabs.TabLayoutMediator
import dagger.hilt.android.AndroidEntryPoint
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

    private val onNavigationEventCollector: suspend (Event<NavDirections>?) -> Unit = {
        it?.consume()?.run { nav(this) }
    }

    private val copyAssetIDToClipboardEventCollector: suspend (Event<Long>?) -> Unit = {
        it?.consume()?.let { assetId ->
            onAssetIdCopied(assetId)
        }
    }

    private val showGlobalErrorEventCollector: suspend (Event<Int>?) -> Unit = { event ->
        event?.consume()?.let { safeTextResId ->
            showGlobalError(errorMessage = emptyString(), title = context?.getString(safeTextResId))
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
        accountDetailViewModel.onAddAssetClick()
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

    override fun onBuySellClick() {
        accountDetailViewModel.onBuySellClick()
    }

    override fun onSendClick() {
        accountDetailViewModel.onSendClick()
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

    override fun onAccountQuickActionsFloatingActionButtonClicked(isWatchAccount: Boolean) {
        val navigationDestination = with(AccountDetailFragmentDirections) {
            if (isWatchAccount) {
                actionAccountDetailFragmentToWatchAccountQuickActionsBottomSheet(args.publicKey)
            } else {
                actionAccountDetailFragmentToAccountQuickActionsBottomSheet(args.publicKey)
            }
        }
        nav(navigationDestination)
    }

    override fun onMinimumBalanceInfoClick() {
        navToMinimumBalanceInfoBottomSheet()
    }

    override fun onCopyAddressClick() {
        onAccountAddressCopied(args.publicKey)
    }

    override fun onShowAddressClick() {
        navToShowQrFragment()
    }

    override fun onBackupNowClick() {
        navToBackupPassphraseInfoNavigation()
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
        useFragmentResultListenerValue<Boolean>(ACCOUNT_REMOVE_ACTION_KEY) { isConfirmed ->
            if (isConfirmed) {
                navToHaveYouBackedUpAccountConfirmationBottomSheet()
            }
        }
        useFragmentResultListenerValue<Boolean>(HAVE_YOU_BACKED_UP_ACCOUNT_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) {
                navToRemoveAccountConfirmationNavigation()
            }
        }
        useFragmentResultListenerValue<Boolean>(ACCOUNT_REMOVE_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) {
                accountDetailViewModel.removeAccount(args.publicKey)
                navBack()
            }
        }
        useFragmentResultListenerValue<Boolean>(InAppPinFragment.IN_APP_PIN_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) {
                navToViewPassphraseNavigation(accountDetailViewModel.accountPublicKey)
            }
        }

        startSavedStateListener(R.id.accountDetailFragment) {
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
            flow = accountDetailViewModel.accountDetailSummaryFlow,
            collection = accountDetailSummaryCollector
        )
        viewLifecycleOwner.collectOnLifecycle(
            flow = accountDetailViewModel.accountDetailTabArgFlow,
            collection = accountDetailTabArgCollector
        )
        with(accountDetailViewModel.accountDetailPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.onNavigationEvent },
                collection = onNavigationEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.copyAssetIDToClipboardEvent },
                collection = copyAssetIDToClipboardEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.showGlobalErrorEvent },
                collection = showGlobalErrorEventCollector
            )
        }
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
        binding.toolbar.apply {
            configure(toolbarConfiguration)
            configureToolbarName(accountDetailSummary)
            setOnTitleLongClickListener { onAccountAddressCopied(accountDetailSummary.publicKey) }
            // TODO: find a proper way to inflate button model in preview class
            val endButton = if (accountDetailSummary.shouldDisplayAccountType) {
                BaseAccountIconButton.ExtendedAccountButton(
                    accountIconDrawablePreview = accountDetailSummary.accountIconDrawablePreview,
                    accountTypeResId = accountDetailSummary.accountTypeResId,
                    onClick = ::navToAccountStatusDetailBottomSheet
                )
            } else {
                BaseAccountIconButton.AccountButton(
                    accountIconDrawablePreview = accountDetailSummary.accountIconDrawablePreview,
                    onClick = ::navToAccountStatusDetailBottomSheet
                )
            }
            setEndButton(button = endButton)
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

    private fun navToAccountStatusDetailBottomSheet() {
        val publicKey = accountDetailViewModel.accountPublicKey
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToAccountStatusDetailNavigation(publicKey))
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

    private fun navToManageAssetsFragment() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToManageAssetsBottomSheet(args.publicKey))
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

    private fun navToRemoveAccountConfirmationNavigation() {
        nav(
            AccountDetailFragmentDirections.actionAccountDetailFragmentToRemoveAccountConfirmationNavigation(
                accountAddress = accountDetailViewModel.accountPublicKey
            )
        )
    }

    private fun navToHaveYouBackedUpAccountConfirmationBottomSheet() {
        nav(
            AccountDetailFragmentDirections
                .actionAccountDetailFragmentToHaveYouBackedUpAccountConfirmationBottomSheet()
        )
    }

    private fun navToViewPassphraseNavigation(publicKey: String) {
        nav(
            AccountDetailFragmentDirections
                .actionAccountDetailFragmentToViewPassphraseNavigation(publicKey)
        )
    }

    private fun navToShowQrFragment() {
        nav(
            AccountDetailFragmentDirections
                .actionGlobalShowQrNavigation(
                    title = getString(R.string.qr_code),
                    qrText = accountDetailViewModel.accountPublicKey
                )
        )
    }

    private fun navToBackupPassphraseInfoNavigation() {
        nav(
            AccountDetailFragmentDirections
                .actionAccountDetailFragmentToBackupPassphraseInfoNavigation(
                    publicKeysOfAccountsToBackup = arrayOf(args.publicKey)
                )
        )
    }
}
