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
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO.CLEAR_STATE
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO.CLOSE_OUT
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO.DELETE_APPLICATION
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO.NO_OP
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO.OPT_IN
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO.UNKNOWN
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO.UPDATE_APPLICATION
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.domain.model.TransactionDetailPreview
import com.algorand.android.modules.transaction.detail.ui.mapper.ApplicationCallAssetInformationMapper
import com.algorand.android.modules.transaction.detail.ui.mapper.TransactionDetailItemMapper
import com.algorand.android.modules.transaction.detail.ui.mapper.TransactionDetailPreviewMapper
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.tooltip.domain.usecase.TransactionDetailTooltipDisplayPreferenceUseCase
import com.algorand.android.usecase.GetActiveNodeUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

@SuppressWarnings("LongParameterList")
class ApplicationCallTransactionDetailPreviewUseCase @Inject constructor(
    private val transactionDetailItemMapper: TransactionDetailItemMapper,
    private val transactionDetailPreviewMapper: TransactionDetailPreviewMapper,
    private val getTransactionDetailUseCase: GetTransactionDetailUseCase,
    private val putInnerTransactionToStackCacheUseCase: PutInnerTransactionToStackCacheUseCase,
    private val applicationCallAssetInformationMapper: ApplicationCallAssetInformationMapper,
    assetDetailUseCase: SimpleAssetDetailUseCase,
    collectibleUseCase: SimpleCollectibleUseCase,
    getActiveNodeUseCase: GetActiveNodeUseCase,
    transactionDetailTooltipDisplayPreferenceUseCase: TransactionDetailTooltipDisplayPreferenceUseCase,
    clearInnerTransactionStackCacheUseCase: ClearInnerTransactionStackCacheUseCase
) : BaseTransactionDetailPreviewUseCase(
    assetDetailUseCase = assetDetailUseCase,
    collectibleUseCase = collectibleUseCase,
    transactionDetailItemMapper = transactionDetailItemMapper,
    getActiveNodeUseCase = getActiveNodeUseCase,
    transactionDetailTooltipDisplayPreferenceUseCase = transactionDetailTooltipDisplayPreferenceUseCase,
    clearInnerTransactionStackCacheUseCase = clearInnerTransactionStackCacheUseCase
) {

    suspend fun putInnerTransactionToStackCache(transactions: List<BaseTransactionDetail>) {
        putInnerTransactionToStackCacheUseCase.putInnerTransactionToStackCache(transactions)
    }

    suspend fun getTransactionDetailPreview(transactionId: String, isInnerTransaction: Boolean) = flow {
        emit(transactionDetailPreviewMapper.mapTo(isLoading = true, transactionDetailItemList = emptyList()))
        getTransactionDetailUseCase.getTransactionDetail(transactionId).collect { transactionDetailResource ->
            transactionDetailResource.useSuspended(
                onSuccess = { baseTransactionDetail ->
                    if (baseTransactionDetail !is BaseTransactionDetail.ApplicationCallTransaction) return@useSuspended
                    val transactionDetailPreview = createApplicationCallTransactionPreview(
                        applicationCallTransactionDetail = baseTransactionDetail,
                        transactionId = transactionId,
                        isInnerTransaction = isInnerTransaction
                    )
                    emit(transactionDetailPreview)
                },
                onFailed = {
                    // TODO: Currently, we don't have a design for this case. We should handle error cases after
                    //  preparing the design for this case.
                }
            )
        }
    }

    @SuppressWarnings("LongMethod")
    fun createApplicationCallTransactionPreview(
        applicationCallTransactionDetail: BaseTransactionDetail.ApplicationCallTransaction,
        transactionId: String,
        isInnerTransaction: Boolean
    ): TransactionDetailPreview {
        val transactionDetailList = mutableListOf<TransactionDetailItem>().apply {
            with(applicationCallTransactionDetail) {
                add(
                    transactionDetailItemMapper.mapToSenderItem(
                        labelTextRes = R.string.sender,
                        senderAccountAddress = senderAccountAddress.toShortenedAddress()
                    )
                )
                add(
                    transactionDetailItemMapper.mapToApplicationIdItem(
                        labelTextRes = R.string.application_id,
                        applicationId = applicationId ?: 0
                    )
                )
                add(
                    transactionDetailItemMapper.mapToOnCompletionItem(
                        labelTextRes = R.string.on_completion,
                        onCompletionTextRes = getOnCompletionTextRes(onCompletion)
                    )
                )

                val applicationCallAssetInformationList = foreignAssetIds?.mapNotNull { assetId ->
                    getAssetDetail(assetId)?.run {
                        applicationCallAssetInformationMapper.mapToApplicationCallAssetInformation(
                            assetFullName = AssetName.create(fullName),
                            assetShortName = AssetName.create(shortName),
                            isVerified = isVerified,
                            assetId = assetId
                        )
                    }
                }.orEmpty()

                if (applicationCallAssetInformationList.isNotEmpty()) {
                    val assetInformationCount = applicationCallAssetInformationList.count()
                    add(
                        transactionDetailItemMapper.mapToApplicationCallAssetInformationItem(
                            labelTextRes = R.plurals.assets,
                            assetInformationList = applicationCallAssetInformationList,
                            showMoreButton = assetInformationCount > MAX_ASSET_COUNT_TO_SHOW,
                            showMoreAssetCount = assetInformationCount - MAX_ASSET_COUNT_TO_SHOW
                        )
                    )
                }
                add(TransactionDetailItem.DividerItem)
                add(createTransactionFeeItem(fee))
                add(TransactionDetailItem.DividerItem)
                if (hasInnerTransaction()) {
                    add(
                        transactionDetailItemMapper.mapToInnerTransactionListItem(
                            labelTextRes = R.string.inner_n_transactions,
                            innerTransactionCount = innerTransactionCount,
                            innerTransactions = innerTransactions
                        )
                    )
                    add(TransactionDetailItem.DividerItem)
                }
                add(
                    transactionDetailItemMapper.mapToTransactionIdItem(
                        labelTextRes = getRequiredTransactionIdLabelTextResId(isInnerTransaction = isInnerTransaction),
                        transactionId = transactionId
                    )
                )
                add(TransactionDetailItem.DividerItem)
                addNoteIfExist(this@apply, noteInBase64)
                add(createTransactionChipGroupItem(id.orEmpty()))
            }
        }
        return transactionDetailPreviewMapper.mapTo(
            isLoading = false,
            transactionDetailItemList = transactionDetailList,
            toolbarTitleResId = applicationCallTransactionDetail.toolbarTitleResId
        )
    }

    private fun getOnCompletionTextRes(onCompletionDTO: OnCompletionDTO?): Int? {
        return when (onCompletionDTO) {
            OPT_IN -> R.string.opt_in
            NO_OP -> R.string.no_op
            CLOSE_OUT -> R.string.close_out
            CLEAR_STATE -> R.string.clear_state
            UPDATE_APPLICATION -> R.string.app_call_update
            DELETE_APPLICATION -> R.string.app_call_delete
            UNKNOWN, null -> null
        }
    }

    companion object {
        const val MAX_ASSET_COUNT_TO_SHOW = 2
    }
}
