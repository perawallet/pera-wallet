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

package com.algorand.android.ui.wcconnection

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectConnectionBinding
import com.algorand.android.models.AccountSelection
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.WCSessionRequestResult
import com.algorand.android.models.WCSessionRequestResult.ApproveRequest
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet.Companion.ACCOUNT_SELECTION_KEY
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.loadPeerMetaIcon
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class WalletConnectConnectionBottomSheet : BaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_wallet_connect_connection,
    fullPageNeeded = false
) {

    private val binding by viewBinding(BottomSheetWalletConnectConnectionBinding::bind)
    private val args: WalletConnectConnectionBottomSheetArgs by navArgs()
    private val walletConnectConnectionViewModel by viewModels<WalletConnectConnectionViewModel>()

    private val selectedAccountCollector: suspend (AccountSelection?) -> Unit = { accountCacheData ->
        if (accountCacheData != null) initSelectedAccountUi(accountCacheData)
    }

    private var listener: Callback? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = activity as? Callback
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setDraggableEnabled(isEnabled = false)
        isCancelable = false
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            cancelButton.setOnClickListener { onCancelClick() }
            connectButton.setOnClickListener { onConnectClick() }
            accountContainer.setOnClickListener { onAccountClick() }
            initSessionPeerMetaUi()
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            walletConnectConnectionViewModel.selectedAccountFlow.collect(selectedAccountCollector)
        }
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectConnectionBottomSheet) {
            useSavedStateValue<AccountSelection>(ACCOUNT_SELECTION_KEY) { result ->
                walletConnectConnectionViewModel.setSelectedAccount(result)
            }
        }
    }

    private fun initSessionPeerMetaUi() {
        val peerMeta = args.sessionRequest.peerMeta
        with(binding) {
            appIconImageView.loadPeerMetaIcon(peerMeta.peerIconUri.toString())
            appUrlTextView.apply {
                text = peerMeta.url
                if (peerMeta.url.isNotBlank()) {
                    setOnClickListener { context?.openUrl(peerMeta.url) }
                }
            }
            descriptionTextView.text = context?.getXmlStyledString(
                AnnotatedString(R.string.wallet_wants_to_connect, listOf("app_name" to peerMeta.name))
            )
        }
    }

    private fun onCancelClick() {
        listener?.onSessionRequestResult(WCSessionRequestResult.RejectRequest(args.sessionRequest))
        navBack()
    }

    private fun onConnectClick() {
        walletConnectConnectionViewModel.getSelectedAccount()?.run {
            listener?.onSessionRequestResult(ApproveRequest(accountAddress, args.sessionRequest))
            navBack()
        }
    }

    private fun onAccountClick() {
        val selectedAccount = walletConnectConnectionViewModel.getSelectedAccount()
        nav(
            WalletConnectConnectionBottomSheetDirections
                .actionWalletConnectConnectionBottomSheetToAccountSelectionBottomSheet(
                    assetId = ALGORAND_ID,
                    titleResId = R.string.accounts,
                    selectedAccountAddress = selectedAccount?.accountAddress,
                    showBackButton = true,
                    showBalance = false
                )
        )
    }

    private fun initSelectedAccountUi(accountSelection: AccountSelection) {
        with(binding) {
            with(accountSelection) {
                accountIconImageView.setAccountIcon(accountIcon)
                accountNameTextView.setTextAndVisibility(accountName)
                accountBalanceTextView.setTextAndVisibility(
                    root.resources.getQuantityString(
                        R.plurals.account_asset_count, accountAssetCount, accountAssetCount, accountAssetCount
                    )
                )
                selectAccountTextView.hide()
            }
        }
    }

    interface Callback {
        fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult)
    }
}
