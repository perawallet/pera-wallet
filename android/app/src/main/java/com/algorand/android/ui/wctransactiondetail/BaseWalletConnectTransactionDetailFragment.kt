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

package com.algorand.android.ui.wctransactiondetail

import android.os.Bundle
import android.view.View
import androidx.annotation.StringRes
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.WalletConnectRequestNavigationDirections.Companion.actionGlobalWalletConnectAssetMetadataBottomSheet
import com.algorand.android.WalletConnectRequestNavigationDirections.Companion.actionGlobalWalletConnectDappMessageBottomSheet
import com.algorand.android.WalletConnectRequestNavigationDirections.Companion.actionGlobalWalletConnectRawTransactionBottomSheet
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentBaseWalletConnectTransactionDetailBinding
import com.algorand.android.models.AssetParams
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccountsInfo
import com.algorand.android.models.WalletConnectAmountInfo
import com.algorand.android.models.WalletConnectExtras
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSenderInfo
import com.algorand.android.models.WalletConnectTransactionInfo
import com.algorand.android.ui.common.walletconnect.WalletConnectAppPreviewCardView.OnShowMoreClickListener
import com.algorand.android.ui.common.walletconnect.WalletConnectExtrasCardView
import com.algorand.android.utils.openAssetUrl
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import javax.inject.Inject

abstract class BaseWalletConnectTransactionDetailFragment : DaggerBaseFragment(
    R.layout.fragment_base_wallet_connect_transaction_detail
) {

    @Inject
    lateinit var errorProvider: WalletConnectTransactionErrorProvider

    abstract val peerMeta: WalletConnectPeerMeta

    abstract val transaction: BaseWalletConnectTransaction

    open fun onAlgoExplorerClick(assetId: Long?, networkSlug: String?) {
        // Nothing to do in super.
    }

    protected val binding by viewBinding(FragmentBaseWalletConnectTransactionDetailBinding::bind)

    protected val transactionInfoObserver = Observer<WalletConnectTransactionInfo> { transactionInfo ->
        binding.transactionInfoCardView.initTransactionInfo(transactionInfo)
    }

    protected val amountInfoObserver = Observer<WalletConnectAmountInfo> { amountInfo ->
        binding.amountInfoCardView.initAmountInfo(amountInfo)
    }

    protected val senderInfoObserver = Observer<WalletConnectSenderInfo> { senderInfo ->
        binding.senderInfoCardView.initSender(senderInfo)
    }

    protected val extrasObserver = Observer<WalletConnectExtras> { extras ->
        binding.extrasCardView.initExtras(extras, extrasListener)
    }

    protected val accountsInfoObserver = Observer<WalletConnectAccountsInfo> { accountsInfo ->
        binding.accountsCardView.initAccountsInfo(accountsInfo)
    }

    private val extrasListener = object : WalletConnectExtrasCardView.Listener {
        override fun onRawTransactionClick(rawTransaction: WCAlgoTransactionRequest) {
            nav(actionGlobalWalletConnectRawTransactionBottomSheet(rawTransaction))
        }

        override fun onAlgoExplorerClick(assetId: Long?, networkSlug: String?) {
            this@BaseWalletConnectTransactionDetailFragment.onAlgoExplorerClick(assetId, networkSlug)
        }

        override fun onAssetUrlClick(assetUrl: String?) {
            context?.openAssetUrl(assetUrl)
        }

        override fun onAssetMetadataClick(assetParams: AssetParams?) {
            nav(actionGlobalWalletConnectAssetMetadataBottomSheet(assetParams))
        }
    }

    private val descriptionShowMoreClickListener = OnShowMoreClickListener { peerMeta, message ->
        nav(actionGlobalWalletConnectDappMessageBottomSheet(message, peerMeta))
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    open fun initUi() {
        binding.appInfoCardView.apply {
            initPeerMeta(peerMeta, transaction.transactionMessage, descriptionShowMoreClickListener)
            visibility = View.VISIBLE
        }
    }

    open fun initObservers() {
        // Nothing to do for now. Needs to be overridden.
    }

    protected fun setCloseToLabel(@StringRes textResId: Int) {
        binding.transactionInfoCardView.setCloseToLabel(textResId)
    }

    protected fun setCloseToWarning(warningText: String) {
        binding.transactionInfoCardView.setCloseToWarning(warningText)
    }
}
