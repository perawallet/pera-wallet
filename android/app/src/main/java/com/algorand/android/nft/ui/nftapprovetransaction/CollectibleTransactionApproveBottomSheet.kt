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

package com.algorand.android.nft.ui.nftapprovetransaction

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetCollectibleTransactionApproveBinding
import com.algorand.android.models.ui.CollectibleTransactionApprovePreview
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class CollectibleTransactionApproveBottomSheet :
    DaggerBaseBottomSheet(R.layout.bottom_sheet_collectible_transaction_approve, false, null) {

    private val binding by viewBinding(BottomSheetCollectibleTransactionApproveBinding::bind)

    private val collectibleTransactionApproveViewModel: CollectibleTransactionApproveViewModel by viewModels()

    private val collectibleTransactionApprovePreviewCollector: suspend (CollectibleTransactionApprovePreview?) -> Unit =
        {
            updateUiWithCollectibleTransactionApprovePreview(it)
        }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.positiveButton.setOnClickListener {
            setNavigationResult(COLLECTIBLE_TXN_APPROVE_KEY, true)
            navBack()
        }
        binding.learnMoreButton.setOnClickListener { navBack() }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            collectibleTransactionApproveViewModel.collectibleTransactionApprovePreviewFlow.collect(
                collectibleTransactionApprovePreviewCollector
            )
        }
    }

    private fun updateUiWithCollectibleTransactionApprovePreview(preview: CollectibleTransactionApprovePreview?) {
        with(binding) {
            preview?.let {
                senderAlgorandUserView.setAccount(it.senderAccountDisplayText, it.senderAccountIcon)
                toAlgorandUserView.setAccount(it.receiverAccountDisplayText, it.receiverAccountIcon)
                transactionFeeTextView.text = it.formattedTransactionFee
            }
        }
    }

    companion object {
        const val COLLECTIBLE_TXN_APPROVE_KEY = "collectible_transaction_approved"
    }
}
