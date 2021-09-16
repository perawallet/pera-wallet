/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectSenderViewBinding
import com.algorand.android.models.ApplicationCallStateSchema
import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectSenderInfo
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectSenderCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectSenderViewBinding::inflate)

    init {
        initRootLayout()
    }

    fun initSender(senderInfo: WalletConnectSenderInfo) {
        with(binding) {
            root.visibility = View.VISIBLE
            with(senderInfo) {
                initSenderAddress(senderDisplayedAddress, senderTypeImageResId)
                initOnComplete(onComplete)
                initRekeyToAddress(rekeyToAccountAddress)
                initApplicationId(applicationId)
                initAppGlobalSchema(appGlobalSchema)
                initAppLocalSchema(appLocalSchema)
                initAppExtraPages(appExtraPages)
                initApprovalHash(approvalHash)
                initClearStateHash(clearStateHash)
            }
        }
    }

    private fun initSenderAddress(displayedAddress: BaseWalletConnectDisplayedAddress, senderTypeImageResId: Int?) {
        with(binding) {
            senderNameTextView.apply {
                text = displayedAddress.displayValue
                isSingleLine = displayedAddress.isSingleLine
            }
            if (senderTypeImageResId != null) {
                senderTypeImageView.setImageResource(senderTypeImageResId)
            }
        }
    }

    private fun initAppGlobalSchema(appGlobalSchema: ApplicationCallStateSchema?) {
        appGlobalSchema?.let { schema ->
            if (schema.numberOfInts == null || schema.numberOfBytes == null) return
            with(binding) {
                appGlobalSchemaTextView.text = context.getString(
                    R.string.byte_uint_formatted,
                    schema.numberOfBytes,
                    schema.numberOfInts
                )
                appGlobalSchemaGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initAppLocalSchema(appLocalSchema: ApplicationCallStateSchema?) {
        appLocalSchema?.let { schema ->
            if (schema.numberOfInts == null || schema.numberOfBytes == null) return
            with(binding) {
                appLocalSchemaTextView.text = context.getString(
                    R.string.byte_uint_formatted,
                    schema.numberOfBytes,
                    schema.numberOfInts
                )
                appLocalSchemaGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initAppExtraPages(appExtraPages: Int?) {
        appExtraPages?.let { extraPages ->
            with(binding) {
                appExtraPagesTextView.text = extraPages.toString()
                appExtraPagesGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initApprovalHash(approvalHash: String?) {
        approvalHash?.let { hash ->
            if (hash.isBlank()) return
            with(binding) {
                approvalHashTextView.text = hash
                approvalHashGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initClearStateHash(clearStateHash: String?) {
        clearStateHash?.let { hash ->
            if (hash.isBlank()) return
            with(binding) {
                clearStateHashTextView.text = hash
                clearStateHashGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initOnComplete(onComplete: BaseAppCallTransaction.AppOnComplete) {
        binding.onCompleteTextView.setText(onComplete.displayTextResId)
    }

    private fun initApplicationId(appId: Long?) {
        if (appId == null) return
        with(binding) {
            val appIdWithHashTag = "#$appId"
            applicationIdTextView.text = appIdWithHashTag
            applicationIdGroup.visibility = View.VISIBLE
        }
    }

    private fun initRekeyToAddress(address: String?) {
        if (!address.isNullOrBlank()) {
            with(binding) {
                rekeyToTextView.text = address
                rekeyGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(resources.getDimensionPixelSize(R.dimen.keyline_1_plus_4_dp))
    }
}
