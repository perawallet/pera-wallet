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
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetCollectibleTransactionApproveBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.CollectibleSendApproveResult
import com.algorand.android.models.ui.CollectibleTransactionApprovePreview
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

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
        with(binding) {
            positiveButton.setOnClickListener {
                setNavigationResult(
                    COLLECTIBLE_TXN_APPROVE_KEY,
                    CollectibleSendApproveResult(
                        isApproved = true,
                        isOptOutChecked = optOutCheckbox.isChecked && optOutCheckbox.isVisible
                    )
                )
                navBack()
            }
            cancelButton.setOnClickListener { navBack() }
            optOutInfoButton.setOnClickListener { navToOptOutInfoBottomSheet() }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectOnLifecycle(
            collectibleTransactionApproveViewModel.collectibleTransactionApprovePreviewFlow,
            collectibleTransactionApprovePreviewCollector
        )
    }

    private fun updateUiWithCollectibleTransactionApprovePreview(preview: CollectibleTransactionApprovePreview?) {
        with(binding) {
            preview?.let {
                senderAlgorandUserView.setAccount(
                    name = it.senderAccountDisplayText,
                    accountIconResource = it.senderAccountIconResource,
                    publicKey = it.senderAccountPublicKey
                )
                if (it.nftDomainName.isNullOrBlank()) {
                    toAlgorandUserView.setAccount(
                        name = it.receiverAccountDisplayText,
                        accountIconResource = it.receiverAccountIconResource,
                        publicKey = it.receiverAccountPublicKey
                    )
                } else {
                    toAlgorandUserView.setNftDomainAddress(
                        nftDomainAddress = it.nftDomainName,
                        nftDomainServiceLogoUrl = it.nftDomainLogoUrl
                    )
                }
                transactionFeeTextView.text = it.formattedTransactionFee
                optOutGroup.isVisible = it.isOptOutGroupVisible
                optOutCheckbox.isChecked = it.isOptOutGroupVisible
            }
        }
    }

    private fun navToOptOutInfoBottomSheet() {
        nav(
            HomeNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.opt_out_from_the),
                drawableResId = R.drawable.ic_info,
                drawableTintResId = R.color.info_tint_color,
                descriptionAnnotatedString = AnnotatedString(R.string.algorand_blockchain)
            )
        )
    }

    companion object {
        const val COLLECTIBLE_TXN_APPROVE_KEY = "collectible_transaction_approved"
    }
}
