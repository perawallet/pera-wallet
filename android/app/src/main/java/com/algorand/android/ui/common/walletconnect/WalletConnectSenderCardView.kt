/*
 * Copyright 2022 Pera Wallet, LDA
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
import androidx.appcompat.content.res.AppCompatResources
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectSenderViewBinding
import com.algorand.android.models.ApplicationCallStateSchema
import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.TransactionRequestAssetInformation
import com.algorand.android.models.TransactionRequestSenderInfo
import com.algorand.android.utils.enableClickToCopy
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectSenderCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectSenderViewBinding::inflate)

    init {
        initRootLayout()
    }

    fun initSender(senderInfo: TransactionRequestSenderInfo?) {
        if (senderInfo == null) return
        with(senderInfo) {
            initSenderAddress(senderDisplayedAddress.toShortenedAddress())
            initOnComplete(onCompletion)
            initRekeyToAddress(rekeyToAccountAddress, warningCount)
            initApplicationId(appId)
            initAppGlobalSchema(appGlobalScheme)
            initAppLocalSchema(appLocalScheme)
            initAppExtraPages(appExtraPages)
            initApprovalHash(approvalHash)
            initClearStateHash(clearStateHash)
            initAssetInformation(assetInformation)
            initToAccount(toDisplayedAddress)
        }
    }

    private fun initSenderAddress(address: String?) {
        binding.senderNameTextView.text = address
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
                appGlobalSchemaGroup.show()
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
                appLocalSchemaGroup.show()
            }
        }
    }

    private fun initAppExtraPages(appExtraPages: Int?) {
        appExtraPages?.let { extraPages ->
            with(binding) {
                appExtraPagesTextView.text = extraPages.toString()
                appExtraPagesGroup.show()
            }
        }
    }

    private fun initApprovalHash(approvalHash: String?) {
        approvalHash?.let { hash ->
            if (hash.isBlank()) return
            with(binding) {
                approvalHashTextView.text = hash
                approvalHashGroup.show()
            }
        }
    }

    private fun initClearStateHash(clearStateHash: String?) {
        clearStateHash?.let { hash ->
            if (hash.isBlank()) return
            with(binding) {
                clearStateHashTextView.text = hash
                clearStateHashGroup.show()
            }
        }
    }

    private fun initOnComplete(onComplete: BaseAppCallTransaction.AppOnComplete?) {
        onComplete?.let {
            with(binding) {
                onCompleteTextView.text = root.context.getText(onComplete.displayTextResId)
                onCompleteGroup.show()
            }
        }
    }

    private fun initApplicationId(appId: Long?) {
        if (appId == null) return
        with(binding) {
            val appIdWithHashTag = "#$appId"
            applicationIdTextView.text = appIdWithHashTag
            applicationIdGroup.show()
        }
    }

    private fun initRekeyToAddress(address: String?, warningCount: Int?) {
        if (!address.isNullOrBlank()) {
            with(binding) {
                rekeyToTextView.text = address
                rekeyGroup.show()
                rekeyToWarningTextView.isVisible = warningCount != null
            }
        }
    }

    private fun initAssetInformation(assetInformation: TransactionRequestAssetInformation?) {
        assetInformation?.let {
            with(binding) {
                if (assetInformation.isVerified == true) {
                    assetNameTextView.setDrawable(start = AppCompatResources.getDrawable(context, R.drawable.ic_shield))
                }
                assetNameTextView.text = assetInformation.shortName
                assetIdTextView.text = assetInformation.assetId.toString()
                assetGroup.show()
            }
        }
    }

    private fun initToAccount(toDisplayedAddress: BaseWalletConnectDisplayedAddress?) {
        toDisplayedAddress?.let {
            with(binding) {
                toNameTextView.text = toDisplayedAddress.displayValue
                toNameTextView.isSingleLine = toDisplayedAddress.isSingleLine
                toNameTextView.enableClickToCopy(toDisplayedAddress.fullAddress)
                toGroup.show()
            }
        }
    }

    private fun initRootLayout() {
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_xlarge))
    }
}
