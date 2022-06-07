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

package com.algorand.android.transactiondetail.domain.usecase

import com.algorand.android.R
import com.algorand.android.mapper.TransactionDetailItemMapper
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.tooltip.domain.usecase.TransactionDetailTooltipDisplayPreferenceUseCase
import com.algorand.android.transactiondetail.domain.mapper.TransactionDetailPreviewMapper
import com.algorand.android.transactiondetail.domain.model.TransactionDetail
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem.AmountItem.CloseAmountItem
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem.AmountItem.FeeItem
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem.AmountItem.RewardItem
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem.AmountItem.TransactionAmountItem
import com.algorand.android.transactiondetail.domain.model.TransactionDetailPreview
import com.algorand.android.transactiondetail.domain.model.TransactionSign
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.appendAssetName
import com.algorand.android.utils.decodeBase64IfUTF8
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsTxString
import com.algorand.android.utils.getAlgoExplorerUrl
import com.algorand.android.utils.getGoalSeekerUrl
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import com.algorand.android.utils.isGreaterThan
import com.algorand.android.utils.isNotEqualTo
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class TransactionDetailPreviewUseCase @Inject constructor(
    private val getTransactionDetailUseCase: GetTransactionDetailUseCase,
    private val assetDetailUseCase: SimpleAssetDetailUseCase,
    private val collectibleUseCase: SimpleCollectibleUseCase,
    private val getTransactionDetailAccountUseCase: GetTransactionDetailAccountUseCase,
    private val transactionDetailItemMapper: TransactionDetailItemMapper,
    private val algodInterceptor: AlgodInterceptor,
    private val transactionDetailTooltipDisplayPreferenceUseCase: TransactionDetailTooltipDisplayPreferenceUseCase,
    private val transactionDetailPreviewMapper: TransactionDetailPreviewMapper
) {

    fun setCopyAddressTipShown() {
        transactionDetailTooltipDisplayPreferenceUseCase.setCopyAddressTipShown()
    }

    suspend fun getTransactionDetailPreview(
        transactionId: String,
        publicKey: String,
        isRewardTransaction: Boolean
    ) = flow {
        emit(transactionDetailPreviewMapper.mapTo(isLoading = true, transactionDetailItemList = emptyList()))
        getTransactionDetailUseCase.getTransactionDetail(transactionId).collect { transactionDetailResource ->
            transactionDetailResource.useSuspended(
                onSuccess = { transactionDetail ->
                    emit(
                        createTransactionDetailListItems(
                            transactionDetail,
                            publicKey,
                            transactionId,
                            isRewardTransaction
                        )
                    )
                },
                onFailed = {
                    // TODO: no-op
                }
            )
        }
    }

    private suspend fun createTransactionDetailListItems(
        transactionDetail: TransactionDetail,
        publicKey: String,
        transactionId: String,
        isRewardTransaction: Boolean
    ): TransactionDetailPreview {
        val assetId = getTransactionAssetId(transactionDetail)
        val assetDetail = getAssetDetail(assetId)
        val assetDecimal = assetDetail?.fractionDecimals ?: DEFAULT_ASSET_DECIMAL
        val assetName = AssetName.createShortName(assetDetail?.shortName)
        val isAlgo = assetId == ALGORAND_ID
        val transactionAmount = getTransactionDetailAmount(transactionDetail, false)
        val receiverAccountPublicKey = getTransactionReceiverAddress(transactionDetail)
        val senderAccountPublicKey = transactionDetail.senderAddress.orEmpty()
        val otherAccountPublicKey = getTransactionOtherPublicKey(
            publicKey = publicKey,
            receiverAccountPublicKey = receiverAccountPublicKey,
            senderAccountPublicKey = senderAccountPublicKey
        )
        val closeToAccountAddress = getTransactionCloseToAccountAddress(transactionDetail)
        val transactionSign = getTransactionSign(
            receiverAccountPublicKey = receiverAccountPublicKey,
            senderAccountPublicKey = senderAccountPublicKey,
            publicKey = publicKey,
            closeToAccountAddress = closeToAccountAddress
        )

        val isCloseTo = with(transactionDetail) { closeAmount != null && payment?.closeToAddress != null }

        val shouldShowCopyAddressTip = transactionDetailTooltipDisplayPreferenceUseCase.shouldShowCopyAddressTip()

        val transactionDetailItemList = mutableListOf<TransactionDetailItem>().apply {
            add(
                createTransactionAmount(
                    transactionSign = transactionSign,
                    transactionAmount = transactionAmount,
                    assetName = assetName,
                    assetDecimal = assetDecimal,
                    isAlgo = isAlgo
                )
            )

            if (isCloseTo) {
                val transactionFullAmount = getTransactionDetailAmount(transactionDetail, true)
                add(
                    createTransactionCloseToAmountItem(
                        transactionSign = transactionSign,
                        transactionFullAmount = transactionFullAmount,
                        assetName = assetName,
                        assetDecimal = assetDecimal,
                        isAlgo = isAlgo
                    )
                )
            }

            addStatusOrRewardItem(this, isRewardTransaction, transactionDetail, publicKey)
            add(TransactionDetailItem.DividerItem)
            add(getTransactionDetailAccountUseCase.getTransactionFromAccount(publicKey, shouldShowCopyAddressTip))
            add(getTransactionDetailAccountUseCase.getTransactionToAccount(otherAccountPublicKey))
            if (isCloseTo) add(getTransactionDetailAccountUseCase.getTransactionCloseToAccount(publicKey))
            add(createTransactionFeeItem(transactionDetail))
            add(crateTransactionDateItem(transactionDetail.roundTimeAsTimestamp))
            add(createTransactionIdItem(transactionId))
            add(TransactionDetailItem.DividerItem)
            addNoteIfExist(this, transactionDetail.noteInBase64)
            add(createTransactionChipGroupItem(transactionId))
        }
        return transactionDetailPreviewMapper.mapTo(
            isLoading = false,
            transactionDetailItemList = transactionDetailItemList
        )
    }

    private fun addNoteIfExist(transactionList: MutableList<TransactionDetailItem>, note: String?) {
        if (!note.isNullOrBlank()) {
            transactionList.add(createTransactionNoteItem(note))
            transactionList.add(TransactionDetailItem.DividerItem)
        }
    }

    private fun addStatusOrRewardItem(
        transactionList: MutableList<TransactionDetailItem>,
        isRewardTransaction: Boolean,
        transactionDetail: TransactionDetail,
        publicKey: String
    ) {
        val rewardAmount = getTransactionReward(transactionDetail, publicKey)
        if (rewardAmount != null && rewardAmount isGreaterThan BigInteger.ZERO && isRewardTransaction) {
            transactionList.add(createTransactionRewardItem(rewardAmount))
        } else {
            transactionList.add(createTransactionStatusItem())
        }
    }

    private fun createTransactionAmount(
        transactionSign: TransactionSign,
        transactionAmount: BigInteger,
        assetDecimal: Int,
        assetName: AssetName,
        isAlgo: Boolean
    ): TransactionAmountItem {

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

    private fun createTransactionCloseToAmountItem(
        transactionSign: TransactionSign,
        transactionFullAmount: BigInteger,
        assetDecimal: Int,
        assetName: AssetName,
        isAlgo: Boolean
    ): CloseAmountItem {
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

    private fun createTransactionRewardItem(
        transactionRewardAmount: BigInteger
    ): RewardItem {
        return transactionDetailItemMapper.mapToRewardItem(
            labelTextRes = R.string.reward,
            transactionSign = TransactionSign.POSITIVE,
            transactionAmount = transactionRewardAmount,
            formattedTransactionAmount = transactionRewardAmount.formatAmount(ALGO_DECIMALS).formatAsAlgoAmount(),
            assetName = AssetName.createShortName(ALGOS_SHORT_NAME)
        )
    }

    private fun createTransactionStatusItem(): TransactionDetailItem.StatusItem.SuccessItem {
        return transactionDetailItemMapper.mapToSuccessStatusItem(
            labelTextRes = R.string.status,
            transactionStatusTextStyleRes = R.style.TextAppearance_Footnote_Sans_Medium,
            transactionStatusTextRes = R.string.completed,
            transactionStatusBackgroundColor = R.drawable.bg_turquoise_1a_24dp_radius,
            transactionStatusTextColorRes = R.color.positive
        )
    }

    private fun createTransactionFeeItem(transactionDetail: TransactionDetail): FeeItem {
        val transactionFee = getTransactionFee(transactionDetail)
        return transactionDetailItemMapper.mapToFeeItem(
            labelTextRes = R.string.fee,
            transactionSign = TransactionSign.NATURAL,
            transactionAmount = transactionFee,
            formattedTransactionAmount = transactionFee.formatAmount(ALGO_DECIMALS).formatAsAlgoAmount(),
            assetName = AssetName.createShortName(ALGOS_SHORT_NAME)
        )
    }

    private fun crateTransactionDateItem(roundTimeAsTimestamp: Long?): TransactionDetailItem.DateItem {
        val transactionDate = getTransactionFormattedDate(roundTimeAsTimestamp)
        return transactionDetailItemMapper.mapToDateItem(
            labelTextRes = R.string.date,
            date = transactionDate
        )
    }

    private fun createTransactionIdItem(transactionId: String): TransactionDetailItem.TransactionIdItem {
        return transactionDetailItemMapper.mapToTransactionIdItem(
            labelTextRes = R.string.transaction_id,
            transactionId = transactionId
        )
    }

    private fun createTransactionNoteItem(transactionNoteInBase64: String): TransactionDetailItem.NoteItem {
        return transactionDetailItemMapper.mapToNoteItem(
            labelTextRes = R.string.note,
            note = transactionNoteInBase64.decodeBase64IfUTF8()
        )
    }

    private fun createTransactionChipGroupItem(transactionId: String): TransactionDetailItem.ChipGroupItem {
        val networkSlug = algodInterceptor.currentActiveNode?.networkSlug
        return transactionDetailItemMapper.mapToChipGroupItem(
            transactionId = transactionId,
            goalSeekerUrl = getGoalSeekerUrl(transactionId, networkSlug),
            algoExplorerUrl = getAlgoExplorerUrl(transactionId, networkSlug)
        )
    }

    private fun getTransactionAssetId(transactionDetail: TransactionDetail): Long {
        return with(transactionDetail) {
            if (payment != null) {
                ALGORAND_ID
            } else {
                assetTransfer?.assetId ?: assetFreezeTransaction?.assetId
            }
        } ?: ALGORAND_ID
    }

    private fun getAssetDetail(assetId: Long): BaseAssetDetail? {
        return assetDetailUseCase.getCachedAssetDetail(assetId)?.data
            ?: collectibleUseCase.getCachedCollectibleById(assetId)?.data
    }

    private fun getTransactionReceiverAddress(transactionDetail: TransactionDetail): String {
        return with(transactionDetail) {
            payment?.receiverAddress
                ?: assetTransfer?.receiverAddress
                ?: assetFreezeTransaction?.receiverAddress
        }.orEmpty()
    }

    private fun getTransactionOtherPublicKey(
        publicKey: String,
        receiverAccountPublicKey: String,
        senderAccountPublicKey: String
    ): String {
        return if (publicKey == receiverAccountPublicKey) senderAccountPublicKey else receiverAccountPublicKey
    }

    private fun getTransactionDetailAmount(
        transactionDetail: TransactionDetail,
        includeCloseAmount: Boolean
    ): BigInteger {
        return with(transactionDetail) {
            if (payment != null) {
                if (includeCloseAmount && closeAmount != null && closeAmount isNotEqualTo BigInteger.ZERO) {
                    payment.amount.plus(closeAmount)
                } else {
                    payment.amount
                }
            } else {
                assetTransfer?.amount
            }
        } ?: BigInteger.ZERO
    }

    private fun getTransactionCloseToAccountAddress(transactionDetail: TransactionDetail): String? {
        return transactionDetail.payment?.closeToAddress
    }

    private fun getTransactionSign(
        receiverAccountPublicKey: String,
        senderAccountPublicKey: String,
        publicKey: String,
        closeToAccountAddress: String?
    ): TransactionSign {
        return when {
            senderAccountPublicKey == publicKey && receiverAccountPublicKey == publicKey -> TransactionSign.POSITIVE
            receiverAccountPublicKey == publicKey || closeToAccountAddress == publicKey -> TransactionSign.POSITIVE
            else -> TransactionSign.NEGATIVE
        }
    }

    private fun getTransactionReward(transactionDetail: TransactionDetail, publicKey: String): BigInteger? {
        return with(transactionDetail) {
            when {
                senderAddress == publicKey -> senderRewards
                payment?.receiverAddress == publicKey -> receiverRewards
                else -> null
            }?.toBigInteger()
        }
    }

    private fun getTransactionFee(transactionDetail: TransactionDetail): BigInteger {
        return transactionDetail.fee?.toBigInteger() ?: BigInteger.valueOf(MIN_FEE)
    }

    private fun getTransactionFormattedDate(roundTimeAsTimestamp: Long?): String {
        return roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()?.formatAsTxString().orEmpty()
    }
}
