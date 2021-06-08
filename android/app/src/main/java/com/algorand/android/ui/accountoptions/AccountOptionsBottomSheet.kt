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

package com.algorand.android.ui.accountoptions

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountsOptionsBinding
import com.algorand.android.models.Account
import com.algorand.android.ui.accountoptions.AccountOptionsBottomSheetDirections.Companion.actionAccountOptionsBottomSheetToEditAccountNameBottomSheet
import com.algorand.android.ui.accountoptions.AccountOptionsBottomSheetDirections.Companion.actionAccountOptionsBottomSheetToRekeyAccountFragment
import com.algorand.android.ui.accountoptions.AccountOptionsBottomSheetDirections.Companion.actionAccountOptionsBottomSheetToRemoveAccountBottomSheet
import com.algorand.android.ui.accountoptions.AccountOptionsBottomSheetDirections.Companion.actionAccountOptionsBottomSheetToRemoveAssetsFragment
import com.algorand.android.ui.accountoptions.AccountOptionsBottomSheetDirections.Companion.actionAccountOptionsBottomSheetToShowQrBottomSheet
import com.algorand.android.ui.accountoptions.AccountOptionsBottomSheetDirections.Companion.actionAccountOptionsBottomSheetToViewPassphraseLockFragment
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import com.algorand.android.utils.ShowQrBottomSheet
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AccountOptionsBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_accounts_options,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private val accountOptionsViewModel: AccountOptionsViewModel by viewModels()

    private val binding by viewBinding(BottomSheetAccountsOptionsBinding::bind)

    private val args by navArgs<AccountOptionsBottomSheetArgs>()

    private val notificationObserverCollector: suspend (Resource<Unit>?) -> Unit = {
        it?.use(
            onLoadingFinished = {
                navBack()
            }
        )
    }

    private val notificationFilterCheckCollector: suspend (Boolean?) -> Unit = { isMuted ->
        if (isMuted != null) {
            setupNotificationOption(isMuted)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        accountOptionsViewModel.checkIfNotificationFiltered(args.publicKey)
        val accountCacheData = accountCacheManager.getCacheData(args.publicKey)
        val isThereAnyAsset = accountCacheData?.assetsInformation?.filterNot { it.isAssetPending() }?.size ?: 0 > 1
        if (isThereAnyAsset && args.accountType != Account.Type.WATCH) {
            binding.removeAssetButton.apply {
                visibility = View.VISIBLE
                setOnClickListener {
                    nav(actionAccountOptionsBottomSheetToRemoveAssetsFragment(args.publicKey))
                }
            }
        }
        if (accountCacheData?.isRekeyedToAnotherAccount() == true) {
            binding.authAddressButton.apply {
                visibility = View.VISIBLE
                setOnClickListener {
                    nav(
                        actionAccountOptionsBottomSheetToShowQrBottomSheet(
                            title = getString(R.string.auth_account_address),
                            qrText = accountCacheData.authAddress.orEmpty(),
                            state = ShowQrBottomSheet.State.ADDRESS_QR
                        )
                    )
                }
            }
        }
        binding.accountNameButton.setOnClickListener {
            nav(actionAccountOptionsBottomSheetToEditAccountNameBottomSheet(args.name, args.publicKey))
        }
        binding.removeAccountButton.setOnClickListener {
            nav(actionAccountOptionsBottomSheetToRemoveAccountBottomSheet(args.publicKey))
        }
        binding.cancelButton.setOnClickListener {
            navBack()
        }
        setupViewPassphraseButton()
        setupRekeyOption()
        initObservers()
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            accountOptionsViewModel.notificationFilterOperationFlow.collectLatest(notificationObserverCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            accountOptionsViewModel.notificationFilterCheckFlow.collect(notificationFilterCheckCollector)
        }
    }

    private fun setupViewPassphraseButton() {
        if (args.accountType == Account.Type.STANDARD) {
            binding.viewPassphraseButton.apply {
                visibility = View.VISIBLE
                setOnClickListener {
                    nav(actionAccountOptionsBottomSheetToViewPassphraseLockFragment(args.publicKey))
                }
            }
        }
    }

    private fun setupRekeyOption() {
        if (args.accountType != Account.Type.WATCH) {
            binding.rekeyButton.apply {
                visibility = View.VISIBLE
                setOnClickListener {
                    nav(actionAccountOptionsBottomSheetToRekeyAccountFragment(args.publicKey))
                }
            }
        }
    }

    private fun setupNotificationOption(isMuted: Boolean) {
        binding.notificationButton.apply {
            setText(if (isMuted) R.string.unmute_notifications else R.string.mute_notifications)
            setIconResource(if (isMuted) R.drawable.ic_empty_notification else R.drawable.ic_empty_notification)
            setOnClickListener {
                accountOptionsViewModel.startFilterOperation(args.publicKey, isMuted.not())
            }
            visibility = View.VISIBLE
        }
    }
}
