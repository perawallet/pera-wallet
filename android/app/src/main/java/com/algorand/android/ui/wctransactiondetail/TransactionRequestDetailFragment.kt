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
import com.algorand.android.models.AssetParams
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionRequestAction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.ui.common.walletconnect.WalletConnectExtrasChipGroupView
import com.algorand.android.utils.openApplicationInAlgoExplorer
import com.algorand.android.utils.openAssetInAlgoExplorer
import com.algorand.android.utils.openAssetUrl
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

        override fun onShowAssetInAlgoExplorerClick(assetId: Long) {
            val networkSlug = transactionDetailViewModel.getNetworkSlug()
            context?.openAssetInAlgoExplorer(assetId, networkSlug)
        }

        override fun onShowAppInAlgoExplorerClick(appId: Long) {
            val networkSlug = transactionDetailViewModel.getNetworkSlug()
            context?.openApplicationInAlgoExplorer(appId, networkSlug)
        }

        override fun onAssetUrlClick(url: String) {
            context?.openAssetUrl(url)
        }

        override fun onAssetMetadataClick(assetParams: AssetParams) {
            transactionRequestListener?.onNavigate(
                TransactionRequestDetailFragmentDirections
                    .actionTransactionRequestDetailFragmentToWalletConnectAssetMetadataBottomSheet(assetParams)
            )
        }
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
    }

    private fun initTransactionInfoViews() {
        with(binding) {
            val transactionInfo = transactionDetailViewModel.buildTransactionRequestTransactionInfo(args.transaction)
            transactionInfoDivider.isVisible = transactionInfo != null
            transactionInfoCardView.isVisible = transactionInfo != null
            transactionInfoCardView.initTransactionInfo(transactionInfo)
        }
    }

    private fun initAmountInfoViews() {
        val amountInfo = transactionDetailViewModel.buildTransactionRequestAmountInfo(args.transaction)
        binding.amountInfoCardView.initAmountInfo(amountInfo)
    }

    private fun initSenderInfoViews() {
        val senderInfo = transactionDetailViewModel.buildTransactionRequestSenderInfo(args.transaction)
        with(binding) {
            senderInfoDivider.isVisible = senderInfo != null
            senderInfoCardView.isVisible = senderInfo != null
            senderInfoCardView.initSender(senderInfo)
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

    private fun initExtrasInfoViews() {
        val extrasInfo = transactionDetailViewModel.buildTransactionRequestExtrasInfo(args.transaction)
        with(binding.extrasChipGroupView) {
            initExtrasButtons(extrasInfo, R.dimen.spacing_xlarge)
            setChipGroupListener(extrasChipGroupViewListener)
        }
    }
}
