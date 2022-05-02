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

package com.algorand.android.ui.accountdetail

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.AlgorandFloatingActionButton
import com.algorand.android.databinding.FragmentAccountDetailBinding
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.DateFilter
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accountdetail.assets.AccountAssetsFragment
import com.algorand.android.ui.accountdetail.history.AccountHistoryFragment
import com.algorand.android.ui.accountdetail.nfts.AccountCollectiblesFragment
import com.algorand.android.ui.accounts.RenameAccountBottomSheet
import com.algorand.android.ui.accounts.ViewPassphraseLockBottomSheet
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.tabs.TabLayoutMediator
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class AccountDetailFragment : BaseFragment(R.layout.fragment_account_detail), AccountHistoryFragment.Listener,
    AccountAssetsFragment.Listener, AccountCollectiblesFragment.Listener {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
        showAccountImage = true
    )

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

    private lateinit var accountDetailPagerAdapter: AccountDetailPagerAdapter

    private val extendedStatusBarConfiguration by lazy {
        StatusBarConfiguration(backgroundColor = R.color.black_alpha_64, showNodeStatus = false)
    }

    private val defaultStatusBarConfiguration by lazy { StatusBarConfiguration() }

    private val fabListener = object : AlgorandFloatingActionButton.Listener {
        override fun onReceiveClick() {
            nav(
                AccountDetailFragmentDirections.actionAccountDetailFragmentToShowQrBottomSheet(
                    title = getString(R.string.qr_code),
                    qrText = args.publicKey
                )
            )
        }

        override fun onSendClick() {
            nav(
                HomeNavigationDirections.actionGlobalSendAlgoNavigation(
                    assetTransaction = AssetTransaction(senderAddress = args.publicKey)
                )
            )
        }

        override fun onBuyAlgoClick() {
            navToMoonpayIntroFragment()
        }

        override fun onStateChange(isExtended: Boolean) {
            val statusBarConfiguration = if (isExtended) {
                extendedStatusBarConfiguration
            } else {
                defaultStatusBarConfiguration
            }
            changeStatusBarConfiguration(statusBarConfiguration)
        }
    }

    override fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToTransactionDetailBottomSheet(transaction))
    }

    override fun onFilterTransactionClick(dateFilter: DateFilter) {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToDateFilterPickerBottomSheet(dateFilter))
    }

    override fun onAddAssetClick() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToAddAssetFragment(args.publicKey))
    }

    override fun onAssetClick(assetItem: AccountDetailAssetsItem.BaseAssetItem) {
        val publicKey = accountDetailViewModel.accountPublicKey
        nav(AccountDetailFragmentDirections.actionGlobalAssetDetailFragment(assetItem.id, publicKey))
    }

    override fun onAssetSearchClick() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToAssetSearchFragment(args.publicKey))
    }

    override fun onImageItemClick(nftAssetId: Long) {
        navToCollectibleDetailFragment(nftAssetId)
    }

    override fun onVideoItemClick(nftAssetId: Long) {
        navToCollectibleDetailFragment(nftAssetId)
    }

    override fun onSoundItemClick(nftAssetId: Long) {
        // TODO "Not yet implemented"
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

    override fun onFilterClick() {
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToCollectibleFiltersFragment())
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
            useSavedStateValue<String>(ViewPassphraseLockBottomSheet.VIEW_PASSPHRASE_ADDRESS_KEY) { address ->
                nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToViewPassphraseBottomSheet(address))
            }

            useSavedStateValue<Boolean>(WarningConfirmationBottomSheet.WARNING_CONFIRMATION_KEY) {
                if (it) {
                    accountDetailViewModel.removeAccount(args.publicKey)
                    navBack()
                }
            }
            useSavedStateValue<String>(RenameAccountBottomSheet.RENAME_ACCOUNT_RESULT) {
                binding.toolbar.changeTitle(it)
            }
        }
    }

    private fun initUi() {
        setupToolbar()
        initAccountDetailPager()
        setupTabLayout()
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            accountDetailViewModel.accountDetailSummaryFlow.collect(accountDetailSummaryCollector)
        }
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            accountDetailViewModel.accountDetailTabArgFlow.collect(accountDetailTabArgCollector)
        }
    }

    private fun setupTabLayout() {
        with(binding) {
            accountDetailViewPager.isUserInputEnabled = false
            TabLayoutMediator(algorandTabLayout, accountDetailViewPager) { tab, position ->
                tab.text = when (position) {
                    0 -> getString(R.string.assets)
                    1 -> getString(R.string.collectibles)
                    else -> getString(R.string.history)
                }
            }.attach()
        }
    }

    private fun setupToolbar() {
        with(binding.toolbar) {
            configure(toolbarConfiguration)
            addButtonToEnd(IconButton(R.drawable.ic_more, onClick = ::showAccountOptions))
        }
    }

    private fun initAccountDetailSummary(accountDetailSummary: AccountDetailSummary) {
        with(binding) {
            accountDetailSendReceiveFab.isVisible = accountDetailSummary.canSignTransaction
            if (accountDetailSummary.canSignTransaction) {
                accountDetailSendReceiveFab.setListener(fabListener)
            }
            toolbar.apply {
                changeTitle(accountDetailSummary.name)
                setAccountImage(accountDetailSummary.accountIcon)
            }
        }
    }

    private fun showAccountOptions() {
        val publicKey = accountDetailViewModel.accountPublicKey
        nav(AccountDetailFragmentDirections.actionAccountDetailFragmentToAccountOptionsBottomSheet(publicKey))
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
}
