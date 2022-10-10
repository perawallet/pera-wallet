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
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectConnectionBinding
import com.algorand.android.models.AccountSelection
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.WCSessionRequestResult
import com.algorand.android.models.WCSessionRequestResult.ApproveRequest
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet.Companion.ACCOUNT_SELECTION_KEY
import com.algorand.android.utils.SingleButtonBottomSheet
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setAccountIconDrawable
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.loadPeerMetaIcon
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectConnectionBottomSheet :
    BaseBottomSheet(layoutResId = R.layout.bottom_sheet_wallet_connect_connection) {

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
        viewLifecycleOwner.collectOnLifecycle(
            walletConnectConnectionViewModel.selectedAccountFlow,
            selectedAccountCollector
        )
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectConnectionBottomSheet) {
            useSavedStateValue<AccountSelection>(ACCOUNT_SELECTION_KEY) { result ->
                walletConnectConnectionViewModel.setSelectedAccount(result)
            }
            useSavedStateValue<Boolean>(SingleButtonBottomSheet.CLOSE_KEY) { isBrowserBottomSheetClosed ->
                if (isBrowserBottomSheetClosed) navBack()
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
            listener?.onSessionRequestResult(
                ApproveRequest(
                    address = accountAddress,
                    wcSessionRequest = args.sessionRequest
                )
            )
            args.sessionRequest.fallbackBrowserGroupResponse?.let {
                navigateToFallbackBrowserSelectionBottomSheet(it, args.sessionRequest.peerMeta.name)
            } ?: showConnectedDappInfoBottomSheet()
        }
    }

    private fun navigateToFallbackBrowserSelectionBottomSheet(
        fallbackBrowserGroupResponse: String,
        peerMetaName: String
    ) {
        nav(
            WalletConnectConnectionBottomSheetDirections
                .actionWalletConnectConnectionBottomSheetToFallbackBrowserSelectionBottomSheet(
                    browserGroup = fallbackBrowserGroupResponse,
                    peerMetaName = peerMetaName
                )
        )
    }

    private fun showConnectedDappInfoBottomSheet() {
        nav(
            WalletConnectConnectionBottomSheetDirections
                .actionWalletConnectConnectionBottomSheetToSingleButtonBottomSheetNavigation(
                    titleAnnotatedString = AnnotatedString(
                        stringResId = R.string.you_are_connected,
                        replacementList = listOf("peer_name" to args.sessionRequest.peerMeta.name)
                    ),
                    descriptionAnnotatedString = AnnotatedString(
                        stringResId = R.string.please_return_to,
                        replacementList = listOf("peer_name" to args.sessionRequest.peerMeta.name)
                    ),
                    drawableResId = R.drawable.ic_check_72dp
                )
        )
    }

    private fun onAccountClick() {
        val selectedAccount = walletConnectConnectionViewModel.getSelectedAccount()
        nav(
            WalletConnectConnectionBottomSheetDirections
                .actionWalletConnectConnectionBottomSheetToAccountSelectionBottomSheet(
                    assetId = ALGO_ID,
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
                if (accountIconResource != null) {
                    accountIconImageView.setAccountIconDrawable(
                        accountIconResource = accountIconResource,
                        iconSize = R.dimen.account_icon_size_large
                    )
                }
                accountNameTextView.setTextAndVisibility(
                    accountDisplayName?.getDisplayTextOrAccountShortenedAddress()
                )
                accountAssetCountTextView.setTextAndVisibility(setupAssetCount(accountAssetCount ?: 0))
                selectAccountTextView.hide()
            }
        }
    }

    private fun setupAssetCount(assetCount: Int): String {
        return if (assetCount > 0) {
            resources.getQuantityString(R.plurals.account_asset_count, assetCount, assetCount)
        } else {
            getString(R.string.account_asset_count_zero)
        }
    }

    interface Callback {
        fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult)
    }
}
