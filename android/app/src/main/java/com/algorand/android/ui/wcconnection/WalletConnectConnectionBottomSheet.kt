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

package com.algorand.android.ui.wcconnection

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectConnectionBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.WCSessionRequestResult
import com.algorand.android.models.WCSessionRequestResult.ApproveRequest
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet.Companion.ACCOUNT_SELECTION_KEY
import com.algorand.android.ui.wcconnection.WalletConnectConnectionBottomSheetDirections.Companion.actionWalletConnectConnectionBottomSheetToAccountSelectionBottomSheet
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.loadPeerMetaIcon
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlin.properties.Delegates

@AndroidEntryPoint
class WalletConnectConnectionBottomSheet : BaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_wallet_connect_connection,
    fullPageNeeded = false
) {

    private val walletConnectConnectionViewModel: WalletConnectConnectionViewModel by viewModels()
    private val binding by viewBinding(BottomSheetWalletConnectConnectionBinding::bind)
    private val args: WalletConnectConnectionBottomSheetArgs by navArgs()
    private var selectedAccount by Delegates.observable<AccountCacheData?>(null) { _, oldValue, newValue ->
        if (newValue != oldValue && newValue != null) initSelectedAccountUi(newValue)
    }

    private val defaultAccountObserver = Observer<AccountCacheData?> { defaultAccount ->
        selectedAccount = defaultAccount
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

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectConnectionBottomSheet) {
            useSavedStateValue<AccountSelectionBottomSheet.Result>(ACCOUNT_SELECTION_KEY) { result ->
                selectedAccount = result.accountCacheData
            }
        }
    }

    private fun initObservers() {
        walletConnectConnectionViewModel.accountLiveData.observe(viewLifecycleOwner, defaultAccountObserver)
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
        selectedAccount?.run {
            listener?.onSessionRequestResult(ApproveRequest(account.address, args.sessionRequest))
            navBack()
        }
    }

    private fun onAccountClick() {
        nav(actionWalletConnectConnectionBottomSheetToAccountSelectionBottomSheet(ALGORAND_ID, R.string.accounts))
    }

    private fun initSelectedAccountUi(accountCacheData: AccountCacheData) {
        with(binding) {
            with(accountCacheData) {
                accountIconImageView.setImageResource(getImageResource())
                accountNameTextView.text = account.name
                accountCacheData.assetsInformation.first { it.isAlgorand() }.run {
                    accountBalanceTextView.text = getString(R.string.algos_amount_formatted, formattedAmount)
                }
            }
        }
    }

    interface Callback {
        fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult)
    }
}
