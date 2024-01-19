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

package com.algorand.android.ui.wctransactiondetail

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentTransactionRequestDetailBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionRequestAction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectTransactionAssetDetail
import com.algorand.android.ui.common.walletconnect.WalletConnectAmountInfoCardView
import com.algorand.android.ui.common.walletconnect.WalletConnectExtrasChipGroupView
import com.algorand.android.ui.common.walletconnect.WalletConnectSenderCardView
import com.algorand.android.ui.common.walletconnect.WalletConnectTransactionInfoCardView
import com.algorand.android.utils.browser.openApplicationInPeraExplorer
import com.algorand.android.utils.browser.openAssetInPeraExplorer
import com.algorand.android.utils.browser.openAssetUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class TransactionRequestDetailFragment : DaggerBaseFragment(
    R.layout.fragment_transaction_request_detail
) {
    override val fragmentConfiguration = FragmentConfiguration()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = { transactionRequestListener?.onNavigateBack() },
        titleResId = R.string.transaction_details
    )

    private val args: TransactionRequestDetailFragmentArgs by navArgs()
    private val binding by viewBinding(FragmentTransactionRequestDetailBinding::bind)
    private val transactionDetailViewModel: TransactionRequestDetailViewModel by viewModels()

    private var transactionRequestListener: TransactionRequestAction? = null

    private val extrasChipGroupViewListener = object : WalletConnectExtrasChipGroupView.Listener {
        override fun onRawTransactionClick(rawTransaction: WCAlgoTransactionRequest) {
            transactionRequestListener?.onNavigate(
                TransactionRequestDetailFragmentDirections
                    .actionTransactionRequestDetailFragmentToWalletConnectRawTransactionBottomSheet(rawTransaction)
            )
        }

        override fun onShowAssetInPeraExplorerClick(assetId: Long) {
            val networkSlug = transactionDetailViewModel.getNetworkSlug()
            context?.openAssetInPeraExplorer(assetId, networkSlug)
        }

        override fun onShowAppInPeraExplorerClick(appId: Long) {
            val networkSlug = transactionDetailViewModel.getNetworkSlug()
            context?.openApplicationInPeraExplorer(appId, networkSlug)
        }

        override fun onAssetUrlClick(url: String) {
            context?.openAssetUrl(url)
        }

        override fun onAssetMetadataClick(walletConnectTransactionAssetDetail: WalletConnectTransactionAssetDetail) {
            transactionRequestListener?.onNavigate(
                TransactionRequestDetailFragmentDirections
                    .actionTransactionRequestDetailFragmentToWalletConnectAssetMetadataBottomSheet(
                        walletConnectTransactionAssetDetail = walletConnectTransactionAssetDetail
                    )
            )
        }
    }

    private val walletConnectTransactionCardListener =
        object : WalletConnectTransactionInfoCardView.WalletConnectTransactionInfoCardViewListener {
            override fun onAssetItemClick(assetId: Long?, accountAddress: String?) {
                assetId?.let {
                    navToAsaProfileNavigation(assetId = it, accountAddress = accountAddress)
                }
            }

            override fun onAccountAddressLongPressed(accountAddress: String) {
                onAccountAddressCopied(accountAddress)
            }
        }

    private val walletConnectSenderCardListener =
        object : WalletConnectSenderCardView.WalletConnectSenderCardViewListener {
            override fun onAccountAddressLongPressed(fullAddress: String) {
                onAccountAddressCopied(fullAddress)
            }

            override fun onAssetItemClick(assetId: Long?, accountAddress: String?) {
                assetId?.let {
                    navToAsaProfileNavigation(assetId = it, accountAddress = accountAddress)
                }
            }
        }

    private val walletConnectAmountInfoCardListener =
        WalletConnectAmountInfoCardView.WalletConnectAmountInfoCardListener { accountAddress ->
            onAccountAddressCopied(accountAddress)
        }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        transactionRequestListener = parentFragment?.parentFragment as? TransactionRequestAction
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        transactionRequestListener?.hideButtons()
        binding.customToolbar.configure(toolbarConfiguration)
        initTransactionInfoViews()
        initAmountInfoViews()
        initSenderInfoViews()
        initNoteInfoViews()
        initExtrasInfoViews()
        initOnlineKeyRefInfoViews()
        initOfflineKeyRefInfoViews()
    }

    private fun initTransactionInfoViews() {
        with(binding) {
            val transactionInfo = transactionDetailViewModel.buildTransactionRequestTransactionInfo(args.transaction)
            transactionInfoDivider.isVisible = transactionInfo != null
            transactionInfoCardView.isVisible = transactionInfo != null
            transactionInfoCardView.initTransactionInfo(transactionInfo)
            transactionInfoCardView.setListener(walletConnectTransactionCardListener)
        }
    }

    private fun initAmountInfoViews() {
        val amountInfo = transactionDetailViewModel.buildTransactionRequestAmountInfo(args.transaction)
        binding.amountInfoCardView.initAmountInfo(amountInfo)
        binding.amountInfoCardView.setListener(walletConnectAmountInfoCardListener)
    }

    private fun initSenderInfoViews() {
        val senderInfo = transactionDetailViewModel.buildTransactionRequestSenderInfo(args.transaction)
        with(binding) {
            senderInfoDivider.isVisible = senderInfo != null
            senderInfoCardView.isVisible = senderInfo != null
            senderInfoCardView.initSender(senderInfo)
            senderInfoCardView.setListener(walletConnectSenderCardListener)
        }
    }

    private fun initNoteInfoViews() {
        val noteInfo = transactionDetailViewModel.buildTransactionRequestNoteInfo(args.transaction)
        with(binding) {
            noteInfoDivider.isVisible = noteInfo != null
            noteInfoCardView.isVisible = noteInfo != null
            noteInfoCardView.initNoteInfo(noteInfo)
        }
    }

    private fun initOnlineKeyRefInfoViews() {
        val keyRegInfo = transactionDetailViewModel.buildTransactionRequestOnlineKeyRegInfo(args.transaction)
        with(binding) {
            onlineKeyRegInfoCardView.isVisible = keyRegInfo != null
            onlineKeyRegInfoDivider.isVisible = keyRegInfo != null
            if (keyRegInfo != null) {
                onlineKeyRegInfoCardView.initKeyRegInfo(keyRegInfo)
            }
        }
    }

    private fun initOfflineKeyRefInfoViews() {
        val keyRegInfo = transactionDetailViewModel.buildTransactionRequestOfflineKeyRegInfo(args.transaction)
        with(binding) {
            offlineKeyRegInfoCardView.isVisible = keyRegInfo != null
            offlineKeyRegInfoDivider.isVisible = keyRegInfo != null
            if (keyRegInfo != null) {
                offlineKeyRegInfoCardView.initKeyRegInfo(keyRegInfo)
            }
        }
    }

    private fun initExtrasInfoViews() {
        val extrasInfo = transactionDetailViewModel.buildTransactionRequestExtrasInfo(args.transaction)
        with(binding.extrasChipGroupView) {
            initExtrasButtons(extrasInfo, R.dimen.spacing_xlarge)
            setChipGroupListener(extrasChipGroupViewListener)
        }
    }

    private fun navToAsaProfileNavigation(assetId: Long, accountAddress: String?) {
        transactionRequestListener?.run {
            hideButtons()
            motionTransitionToEnd()
            onNavigate(
                TransactionRequestDetailFragmentDirections
                    .actionTransactionRequestDetailFragmentToWalletConnectAsaProfileNavigation(
                        assetId = assetId,
                        accountAddress = accountAddress
                    )
            )
        }
    }
}
