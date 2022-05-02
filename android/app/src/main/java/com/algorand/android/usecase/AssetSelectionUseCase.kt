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

package com.algorand.android.usecase

import com.algorand.android.mapper.AssetSelectionMapper
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.nft.mapper.AssetSelectionPreviewMapper
import com.algorand.android.nft.ui.model.AssetSelectionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flow

class AssetSelectionUseCase @Inject constructor(
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val transactionTipsUseCase: TransactionTipsUseCase,
    private val assetSelectionMapper: AssetSelectionMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase,
    private val assetSelectionPreviewMapper: AssetSelectionPreviewMapper,
    private val accountInformationUseCase: AccountInformationUseCase
) {
    fun getAssetSelectionListFlow(publicKey: String): Flow<List<BaseSelectAssetItem>> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(publicKey),
            algoPriceUseCase.getAlgoPriceCacheFlow()
        ) { _, _ ->
            mutableListOf<BaseSelectAssetItem>().apply {
                val algoAssetSelectionItem = createAlgoSelectionItem(publicKey)
                add(algoAssetSelectionItem)

                val otherAssetSelectionItem = createOtherAssetSelectionItems(publicKey)
                addAll(otherAssetSelectionItem)

                val collectibleSelectionItems = createCollectibleSelectionItems(publicKey)
                addAll(collectibleSelectionItems)
            }
        }
    }

    private fun createAlgoSelectionItem(publicKey: String): BaseSelectAssetItem.SelectAssetItem {
        val algoOwnedAsset = accountAlgoAmountUseCase.getAccountAlgoAmount(publicKey)
        return assetSelectionMapper.mapToAssetItem(algoOwnedAsset)
    }

    private fun createOtherAssetSelectionItems(publicKey: String): List<BaseSelectAssetItem.SelectAssetItem> {
        return accountAssetDataUseCase.getAccountOwnedAssetData(publicKey, false).map { ownedAssetData ->
            assetSelectionMapper.mapToAssetItem(ownedAssetData)
        }
    }

    private fun createCollectibleSelectionItems(
        publicKey: String
    ): List<BaseSelectAssetItem.BaseSelectCollectibleItem> {
        return accountCollectibleDataUseCase.getAccountOwnedCollectibleDataList(publicKey).map { ownedCollectibleData ->
            when (ownedCollectibleData) {
                is OwnedCollectibleImageData -> assetSelectionMapper.mapToCollectibleImageItem(ownedCollectibleData)
                is OwnedCollectibleVideoData -> assetSelectionMapper.mapToCollectibleVideoItem(ownedCollectibleData)
                is OwnedCollectibleMixedData -> assetSelectionMapper.mapToCollectibleMixedItem(ownedCollectibleData)
                is OwnedUnsupportedCollectibleData -> {
                    assetSelectionMapper.mapToCollectibleNotSupportedItem(ownedCollectibleData)
                }
            }
        }
    }

    fun shouldShowTransactionTips(): Boolean {
        return transactionTipsUseCase.shouldShowTransactionTips()
    }

    fun getInitialStateOfAssetSelectionPreview(assetTransaction: AssetTransaction): AssetSelectionPreview {
        return assetSelectionPreviewMapper.mapToInitialState(assetTransaction)
    }

    fun checkIfSelectedAccountReceiveAsset(
        publicKey: String,
        assetId: Long,
        previousState: AssetSelectionPreview
    ) = flow<AssetSelectionPreview> {
        emit(previousState.copy(isLoadingVisible = true))
        accountInformationUseCase.getAccountInformation(publicKey).collect {
            it.useSuspended(
                onSuccess = { accountInformation ->
                    val isReceiverOptedInToAsset = accountInformation.assetHoldingList.any { assetHolding ->
                        assetHolding.assetId == assetId
                    } || assetId == ALGORAND_ID
                    if (!isReceiverOptedInToAsset) {
                        emit(previousState.copy(navigateToOptInEvent = Event(assetId)))
                    } else {
                        emit(previousState.copy(navigateToAssetTransferAmountFragmentEvent = Event(assetId)))
                    }
                },
                onFailed = { errorDataResource ->
                    val exceptionMessage = errorDataResource.exception?.message
                    if (exceptionMessage != null) {
                        emit(previousState.copy(globalErrorTextEvent = Event(exceptionMessage)))
                    } else {
                        // TODO Show default error message
                        emit(previousState.copy(isLoadingVisible = false))
                    }
                }
            )
            emit(previousState.copy(isLoadingVisible = false))
        }
    }
}
