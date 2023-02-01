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

package com.algorand.android.modules.transaction.detail.domain.usecase

import com.algorand.android.R
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.domain.model.TransactionSign
import com.algorand.android.modules.transaction.detail.ui.mapper.TransactionDetailItemMapper
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.tooltip.domain.usecase.TransactionDetailTooltipDisplayPreferenceUseCase
import com.algorand.android.usecase.GetActiveNodeUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.ALGO_SHORT_NAME
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.appendAssetName
import com.algorand.android.utils.browser.getAlgoExplorerUrl
import com.algorand.android.utils.browser.getGoalSeekerUrl
import com.algorand.android.utils.decodeBase64IfUTF8
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsDateAndTime
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import com.algorand.android.utils.isNotEqualTo
import java.math.BigInteger

open class BaseTransactionDetailPreviewUseCase constructor(
    private val assetDetailUseCase: SimpleAssetDetailUseCase,
    private val collectibleUseCase: SimpleCollectibleUseCase,
    private val transactionDetailItemMapper: TransactionDetailItemMapper,
    private val getActiveNodeUseCase: GetActiveNodeUseCase,
    private val transactionDetailTooltipDisplayPreferenceUseCase: TransactionDetailTooltipDisplayPreferenceUseCase,
    private val clearInnerTransactionStackCacheUseCase: ClearInnerTransactionStackCacheUseCase
) {

    fun setCopyAddressTipShown() {
        transactionDetailTooltipDisplayPreferenceUseCase.setCopyAddressTipShown()
    }

    suspend fun clearInnerTransactionStackCache() {
        clearInnerTransactionStackCacheUseCase.clearInnerTransactionStackCacheUseCase()
    }

    protected fun addNoteIfExist(transactionList: MutableList<TransactionDetailItem>, note: String?) {
        if (!note.isNullOrBlank()) {
            transactionList.add(
                transactionDetailItemMapper.mapToNoteItem(
                    labelTextRes = R.string.note,
                    note = note.decodeBase64IfUTF8()
                )
            )
            transactionList.add(TransactionDetailItem.DividerItem)
        }
    }

    protected fun createTransactionAmount(
        transactionSign: TransactionSign,
        transactionAmount: BigInteger,
        assetDecimal: Int,
        assetName: AssetName,
        isAlgo: Boolean
    ): TransactionDetailItem.StandardTransactionItem.TransactionAmountItem {

        val formattedTransactionAmount = with(transactionAmount.formatAmount(assetDecimal)) {
            if (isAlgo) formatAsAlgoAmount() else appendAssetName(assetName)
        }
        return transactionDetailItemMapper.mapToTransactionAmountItem(
            labelTextRes = R.string.amount,
            transactionSign = transactionSign,
            transactionAmount = transactionAmount,
            formattedTransactionAmount = formattedTransactionAmount,
            assetName = assetName
        )
    }

    protected fun createTransactionCloseToAmountItem(
        transactionSign: TransactionSign,
        transactionFullAmount: BigInteger,
        assetDecimal: Int,
        assetName: AssetName,
        isAlgo: Boolean
    ): TransactionDetailItem.StandardTransactionItem.CloseAmountItem {
        val formattedTransactionAmount = with(transactionFullAmount.formatAmount(assetDecimal)) {
            if (isAlgo) formatAsAlgoAmount() else appendAssetName(assetName)
        }
        return transactionDetailItemMapper.mapToCloseAmountItem(
            labelTextRes = R.string.close_amount,
            transactionSign = transactionSign,
            transactionAmount = transactionFullAmount,
            formattedTransactionAmount = formattedTransactionAmount,
            assetName = assetName
        )
    }

    protected fun createTransactionStatusItem(): TransactionDetailItem.StandardTransactionItem.StatusItem.SuccessItem {
        return transactionDetailItemMapper.mapToSuccessStatusItem(
            labelTextRes = R.string.status,
            transactionStatusTextStyleRes = R.style.TextAppearance_Footnote_Sans_Medium,
            transactionStatusTextRes = R.string.completed,
            transactionStatusBackgroundColor = R.drawable.bg_positive_lighter_24dp_radius,
            transactionStatusTextColorRes = R.color.positive
        )
    }

    protected fun createTransactionFeeItem(fee: BigInteger): TransactionDetailItem.FeeItem {
        return transactionDetailItemMapper.mapToFeeItem(
            labelTextRes = R.string.fee,
            transactionSign = TransactionSign.NATURAL,
            transactionAmount = fee,
            formattedTransactionAmount = fee.formatAmount(ALGO_DECIMALS).formatAsAlgoAmount(),
            assetName = AssetName.createShortName(ALGO_SHORT_NAME)
        )
    }

    protected fun createTransactionChipGroupItem(transactionId: String): TransactionDetailItem.ChipGroupItem {
        val networkSlug = getActiveNodeUseCase.getActiveNode()?.networkSlug
        return transactionDetailItemMapper.mapToChipGroupItem(
            transactionId = transactionId,
            goalSeekerUrl = getGoalSeekerUrl(transactionId, networkSlug),
            algoExplorerUrl = getAlgoExplorerUrl(transactionId, networkSlug)
        )
    }

    protected fun getTransactionAssetId(baseTransactionDetail: BaseTransactionDetail): Long {
        return when (baseTransactionDetail) {
            is BaseTransactionDetail.AssetConfigurationTransaction -> baseTransactionDetail.assetId
            is BaseTransactionDetail.AssetTransferTransaction -> baseTransactionDetail.assetId
            is BaseTransactionDetail.PaymentTransaction -> ALGO_ID
            is BaseTransactionDetail.ApplicationCallTransaction,
            is BaseTransactionDetail.UndefinedTransaction -> null
        } ?: ALGO_ID
    }

    protected fun getAssetDetail(assetId: Long): BaseAssetDetail? {
        return assetDetailUseCase.getCachedAssetDetail(assetId)?.data
            ?: collectibleUseCase.getCachedCollectibleById(assetId)?.data
    }

    protected fun getTransactionDetailAmount(
        baseTransactionDetail: BaseTransactionDetail,
        includeCloseAmount: Boolean
    ): BigInteger {
        return when (baseTransactionDetail) {
            is BaseTransactionDetail.AssetTransferTransaction,
            is BaseTransactionDetail.PaymentTransaction -> {
                baseTransactionDetail.transactionCloseAmount?.let { transactionCloseAmount ->
                    if (includeCloseAmount && transactionCloseAmount isNotEqualTo BigInteger.ZERO) {
                        baseTransactionDetail.transactionAmount?.plus(transactionCloseAmount)
                    } else {
                        baseTransactionDetail.transactionAmount
                    }
                }
            }
            is BaseTransactionDetail.ApplicationCallTransaction,
            is BaseTransactionDetail.AssetConfigurationTransaction,
            is BaseTransactionDetail.UndefinedTransaction -> null
        } ?: BigInteger.ZERO
    }

    protected fun getTransactionSign(
        receiverAccountPublicKey: String,
        senderAccountPublicKey: String,
        publicKey: String,
        closeToAccountAddress: String?,
        areAccountsInCache: Boolean
    ): TransactionSign {
        return when {
            !areAccountsInCache -> TransactionSign.NATURAL
            senderAccountPublicKey == publicKey && receiverAccountPublicKey == publicKey -> TransactionSign.NATURAL
            receiverAccountPublicKey == publicKey || closeToAccountAddress == publicKey -> TransactionSign.POSITIVE
            else -> TransactionSign.NEGATIVE
        }
    }

    protected fun getTransactionFormattedDate(roundTimeAsTimestamp: Long?): String {
        return roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()?.formatAsDateAndTime().orEmpty()
    }

    protected fun isTransactionCloseTo(baseTransactionDetail: BaseTransactionDetail): Boolean {
        return baseTransactionDetail.closeToAccountAddress != null &&
            baseTransactionDetail.transactionCloseAmount != null
    }

    protected fun getRequiredTransactionIdLabelTextResId(isInnerTransaction: Boolean): Int {
        return if (isInnerTransaction) R.string.parent_transaction_id else R.string.transaction_id
    }
}
