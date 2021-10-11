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

package com.algorand.android.ui.accounts

import android.content.SharedPreferences
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import com.algorand.android.MainActivity
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.databinding.FragmentAccountsBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AccountCacheStatus.DONE
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accounts.AccountsFragmentDirections.Companion.actionAccountsFragmentToAccountOptionsBottomSheet
import com.algorand.android.ui.accounts.AccountsFragmentDirections.Companion.actionAccountsFragmentToAddAssetFragment
import com.algorand.android.ui.accounts.AccountsFragmentDirections.Companion.actionAccountsFragmentToAssetDetailFragment
import com.algorand.android.ui.accounts.AccountsFragmentDirections.Companion.actionAccountsFragmentToMainQrScannerFragment
import com.algorand.android.ui.accounts.AccountsFragmentDirections.Companion.actionAccountsFragmentToShowQrBottomSheet
import com.algorand.android.ui.accounts.AccountsFragmentDirections.Companion.actionAccountsFragmentToViewPassphraseBottomSheet
import com.algorand.android.ui.common.listhelper.AccountAdapter
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.openAlgorandGovernancePage
import com.algorand.android.utils.preference.isQrTutorialShown
import com.algorand.android.utils.preference.setQrTutorialShown
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.WalletConnectViewModel
import com.google.android.material.button.MaterialButton
import com.google.firebase.crashlytics.FirebaseCrashlytics
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AccountsFragment : DaggerBaseFragment(R.layout.fragment_accounts) {

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.accounts,
        type = CustomToolbar.Type.TAB_TOOLBAR,
        showNodeStatus = true
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    private val binding by viewBinding(FragmentAccountsBinding::bind)

    private val accountsViewModel: AccountsViewModel by viewModels()

    private val walletConnectViewModel: WalletConnectViewModel by viewModels()

    private var accountAdapter: AccountAdapter? = null

    private var addedScanQrButton: View? = null
    private var addedAddButton: View? = null

    // <editor-fold defaultstate="collapsed" desc="observers">

    private val blockConnectionStableCollector: suspend (Boolean) -> Unit = { isStable ->
        binding.noInternetConnectionLayout.isInvisible = isStable
    }

    private val accountCacheObserver = Observer<AccountCacheStatus> { status ->
        binding.loadingProgressBar.isInvisible = status == DONE
    }

    private val listCollector: suspend (List<BaseAccountListItem>?) -> Unit = { value ->
        accountAdapter?.submitList(value)
    }

    private val isAnyAccountRegisteredCollector: suspend (Boolean) -> Unit = { isAnyAccountRegistered ->
        addedAddButton?.isInvisible = isAnyAccountRegistered.not()
        addedScanQrButton?.isInvisible = isAnyAccountRegistered.not()
        binding.noAccountLayout.isVisible = isAnyAccountRegistered.not()
    }

    // </editor-fold>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        (activity as MainActivity).isAppUnlocked = true
        setupRecyclerView()
        configureToolbar()
        initObservers()
        initSavedStateListener()
        setupEmptyAccountView()
    }

    private fun configureToolbar() {
        getAppToolbar()?.apply {
            val marginEnd = resources.getDimensionPixelSize(R.dimen.page_horizontal_spacing)

            val addAccountButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_circle_tab_button, this, false) as MaterialButton

            addAccountButton.apply {
                setIconResource(R.drawable.ic_add)
                backgroundTintList = ContextCompat.getColorStateList(context, R.color.colorPrimary)
                setOnClickListener { onAddAccount() }
                addedAddButton = addViewToEndSide(this, marginEnd)
            }

            val scanQrButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_circle_tab_button, this, false) as MaterialButton

            scanQrButton.apply {
                setIconResource(R.drawable.ic_qr_scan)
                rippleColor = ContextCompat.getColorStateList(context, R.color.gray_A4)
                elevation = resources.getDimension(R.dimen.tab_toolbar_scanqr_elevation)
                setOnClickListener { onScanQrClick() }
                addedScanQrButton = addViewToEndSide(this, marginEnd)
            }
        }
    }

    private fun setupEmptyAccountView() {
        binding.createNewAccountButton.setOnClickListener { onAddAccount() }
    }

    private fun setupRecyclerView() {
        if (accountAdapter == null) {
            val showQrTutorial = !sharedPref.isQrTutorialShown()
            accountAdapter = AccountAdapter(
                onAssetClick = ::onAssetClick,
                onAddAssetClick = ::onAddAssetClick,
                onAccountOptionsClick = ::onAccountsOptionClick,
                onShowQrClick = ::onShowQRClick,
                showQRTutorial = showQrTutorial,
                onBannerCloseClick = ::onBannerCloseClick,
                onBannerCheckOutClick = ::onBannerCheckOutClick
            )
            if (showQrTutorial) {
                sharedPref.setQrTutorialShown()
            }
        }
        binding.swipeRefresh.apply {
            setOnRefreshListener { postDelayed({ isRefreshing = false }, SWIPE_REFRESH_DELAY) }
        }
        binding.accountsRecyclerView.apply {
            adapter = accountAdapter
            itemAnimator = null
        }
    }

    private fun onAssetClick(accountPublicKey: String, assetInformation: AssetInformation) {
        if (assetInformation.isAssetPending().not()) {
            if (accountCacheManager.getCacheData(accountPublicKey) != null) {
                nav(actionAccountsFragmentToAssetDetailFragment(assetInformation, accountPublicKey))
            } else {
                val exception = Exception("$accountPublicKey doesn't have cache assetClick doesn't work")
                FirebaseCrashlytics.getInstance().recordException(exception)
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            (activity as MainActivity).mainViewModel.blockConnectionStableFlow.collectLatest(
                blockConnectionStableCollector
            )
        }

        (activity as MainActivity).mainViewModel.accountBalanceSyncStatus.observe(
            viewLifecycleOwner,
            accountCacheObserver
        )

        viewLifecycleOwner.lifecycleScope.launch {
            accountsViewModel.listFlow.collectLatest(listCollector)
        }

        viewLifecycleOwner.lifecycleScope.launch {
            accountsViewModel.isAnyAccountRegisteredFlow.collectLatest(isAnyAccountRegisteredCollector)
        }
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.accountsFragment) {
            useSavedStateValue<String>(ViewPassphraseLockFragment.VIEW_PASSPHRASE_ADDRESS_KEY) { address ->
                nav(actionAccountsFragmentToViewPassphraseBottomSheet(address))
            }

            useSavedStateValue<DecodedQrCode?>(QrCodeScannerFragment.QR_SCAN_RESULT_KEY) {
                handleWalletConnectUrl(it?.walletConnectUrl.orEmpty())
            }
        }
    }

    private fun onAddAccount() {
        nav(MainNavigationDirections.actionNewAccount())
    }

    private fun onAccountsOptionClick(accountName: String, accountPublicKey: String, accountType: Account.Type?) {
        nav(
            actionAccountsFragmentToAccountOptionsBottomSheet(
                accountName, accountPublicKey, accountType ?: Account.Type.STANDARD
            )
        )
    }

    private fun onAddAssetClick(accountPublicKey: String) {
        nav(actionAccountsFragmentToAddAssetFragment(accountPublicKey))
    }

    private fun onShowQRClick(accountPublicKey: String, accountName: String) {
        nav(actionAccountsFragmentToShowQrBottomSheet(title = accountName, qrText = accountPublicKey))
    }

    private fun onScanQrClick() {
        nav(
            actionAccountsFragmentToMainQrScannerFragment(
                scanReturnType = listOf(
                    QrCodeScannerFragment.ScanReturnType.NAVIGATE_FORWARD,
                    QrCodeScannerFragment.ScanReturnType.WALLET_CONNECT_NAVIGATE_BACK
                ).toTypedArray()
            )
        )
    }

    private fun onBannerCloseClick() {
        accountsViewModel.hideBanner()
    }

    private fun onBannerCheckOutClick() {
        context?.openAlgorandGovernancePage()
    }

    companion object {
        private const val SWIPE_REFRESH_DELAY = 1_000L
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_accounts"
    }
}
