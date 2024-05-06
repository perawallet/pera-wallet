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

package com.algorand.android.modules.walletconnect.connectionrequest.ui

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectConnectionBinding
import com.algorand.android.modules.walletconnect.connectionrequest.ui.adapter.WalletConnectConnectionAdapter
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WCSessionRequestResult
import com.algorand.android.utils.Event
import com.algorand.android.utils.ExcludedViewTypesDividerItemDecoration
import com.algorand.android.utils.addCustomDivider
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WalletConnectConnectionBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_wallet_connect_connection) {

    private val binding by viewBinding(BottomSheetWalletConnectConnectionBinding::bind)

    private val walletConnectConnectionViewModel by viewModels<WalletConnectConnectionViewModel>()

    private val walletConnectConnectionAdapterListener =
        object : WalletConnectConnectionAdapter.WalletConnectConnectionAdapterListener {
            override fun onDappUrlClick(dappUrl: String) {
                context?.openUrl(dappUrl)
            }

            override fun onAccountChecked(accountAddress: String) {
                walletConnectConnectionViewModel.onAccountChecked(accountAddress)
            }
        }

    private var listener: Callback? = null

    private val walletConnectConnectionAdapter = WalletConnectConnectionAdapter(walletConnectConnectionAdapterListener)

    private val confirmationButtonStateCollector: suspend (Boolean?) -> Unit = {
        binding.connectButton.isEnabled = it == true
    }

    private val baseWalletConnectConnectionItemsCollector: suspend (List<BaseWalletConnectConnectionItem>?) -> Unit = {
        walletConnectConnectionAdapter.submitList(it)
    }

    private val sessionApprovalCollector: suspend (Event<WCSessionRequestResult.ApproveRequest>?) -> Unit = {
        it?.consume()?.run {
            navBack()
            listener?.onSessionRequestResult(this)
        }
    }

    private val sessionCancellationCollector: suspend (Event<WCSessionRequestResult.RejectRequest>?) -> Unit = {
        it?.consume()?.run {
            navBack()
            listener?.onSessionRequestResult(this)
        }
    }
    private val sessionRejectScamCollector: suspend (Event<WCSessionRequestResult.RejectScamRequest>?) -> Unit = {
        it?.consume()?.run {
            navBack()
            listener?.onSessionRequestResult(this)
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = activity as? Callback
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setDraggableEnabled(false)
        isCancelable = false
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            with(walletConnectConnectionList) {
                adapter = walletConnectConnectionAdapter
                addCustomDivider(
                    drawableResId = R.drawable.horizontal_divider_80_24dp,
                    showLast = false,
                    divider = ExcludedViewTypesDividerItemDecoration(
                        excludedViewTypes = BaseWalletConnectConnectionItem.excludedItemFromDivider
                    )
                )
            }
            connectButton.setOnClickListener { onConnectButtonClick() }
            cancelButton.setOnClickListener { onCancelButtonClick() }
        }
    }

    private fun initObservers() {
        with(walletConnectConnectionViewModel.walletConnectConnectionPreviewFlow) {
            collectLatestOnLifecycle(
                map { it?.isConfirmationButtonEnabled }.distinctUntilChanged(),
                confirmationButtonStateCollector
            )
            collectLatestOnLifecycle(
                map { it?.baseWalletConnectConnectionItems }.distinctUntilChanged(),
                baseWalletConnectConnectionItemsCollector
            )
            collectLatestOnLifecycle(
                map { it?.approveWalletConnectSessionRequest }.distinctUntilChanged(),
                sessionApprovalCollector
            )
            collectLatestOnLifecycle(
                map { it?.rejectWalletConnectSessionRequest }.distinctUntilChanged(),
                sessionCancellationCollector
            )
            collectLatestOnLifecycle(
                map { it?.rejectScamWalletConnectSessionRequest }.distinctUntilChanged(),
                sessionRejectScamCollector
            )
        }
    }

    private fun onConnectButtonClick() {
        walletConnectConnectionViewModel.onConnectSessionConnect()
    }

    private fun onCancelButtonClick() {
        walletConnectConnectionViewModel.onSessionCancelled()
    }

    fun interface Callback {
        fun onSessionRequestResult(wCSessionRequestResult: WCSessionRequestResult)
    }
}
