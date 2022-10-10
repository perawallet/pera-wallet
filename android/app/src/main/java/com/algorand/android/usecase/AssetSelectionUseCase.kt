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

import com.algorand.android.customviews.accountandassetitem.mapper.AssetItemConfigurationMapper
import com.algorand.android.mapper.AssetSelectionMapper
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.sorting.assetsorting.ui.usecase.AssetItemSortUseCase
import com.algorand.android.nft.mapper.AssetSelectionPreviewMapper
import com.algorand.android.nft.ui.model.AssetSelectionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow

class AssetSelectionUseCase @Inject constructor(
    private val transactionTipsUseCase: TransactionTipsUseCase,
    private val assetSelectionMapper: AssetSelectionMapper,
    private val parityUseCase: ParityUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase,
    private val assetSelectionPreviewMapper: AssetSelectionPreviewMapper,
    private val accountInformationUseCase: AccountInformationUseCase,
    private val assetItemConfigurationMapper: AssetItemConfigurationMapper,
    private val assetItemSortUseCase: AssetItemSortUseCase
) {
    fun getAssetSelectionListFlow(publicKey: String): Flow<List<BaseSelectAssetItem>> {
        return combine(
            accountAssetDataUseCase.getAccountAllAssetDataFlow(publicKey = publicKey, includeAlgo = true),
            parityUseCase.getSelectedCurrencyDetailCacheFlow()
        ) { accountAssetData, _ ->
            val assetList = mutableListOf<BaseSelectAssetItem>().apply {
                accountAssetData.filterIsInstance<BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData>()
                    .forEach { baseAccountAssetData ->
                        val assetItemConfiguration = with(baseAccountAssetData) {
                            assetItemConfigurationMapper.mapTo(
                                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                                secondaryValueText =
                                getSelectedCurrencyParityValue().getFormattedValue(isCompact = true),
                                formattedCompactAmount = formattedCompactAmount,
                                assetId = id,
                                name = name,
                                shortName = shortName,
                                prismUrl = prismUrl,
                                verificationTier = verificationTier,
                                primaryValue = parityValueInSelectedCurrency.amountAsCurrency
                            )
                        }
                        add(assetSelectionMapper.mapToAssetItem(assetItemConfiguration))
                    }
                val collectibleSelectionItems = createCollectibleSelectionItems(publicKey)
                addAll(collectibleSelectionItems)
            }
            assetItemSortUseCase.sortAssets(assetList)
        }.distinctUntilChanged()
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
        emit(previousState.copy(isReceiverAccountOptInCheckLoadingVisible = true))
        val loadingFinishedState = previousState.copy(isReceiverAccountOptInCheckLoadingVisible = false)
        accountInformationUseCase.getAccountInformation(publicKey).collect {
            it.useSuspended(
                onSuccess = { accountInformation ->
                    val isReceiverOptedInToAsset = accountInformation.assetHoldingList.any { assetHolding ->
                        assetHolding.assetId == assetId
                    } || assetId == ALGO_ID
                    if (!isReceiverOptedInToAsset) {
                        emit(loadingFinishedState.copy(navigateToOptInEvent = Event(assetId)))
                    } else {
                        emit(loadingFinishedState.copy(navigateToAssetTransferAmountFragmentEvent = Event(assetId)))
                    }
                },
                onFailed = { errorDataResource ->
                    val exceptionMessage = errorDataResource.exception?.message
                    if (exceptionMessage != null) {
                        emit(loadingFinishedState.copy(globalErrorTextEvent = Event(exceptionMessage)))
                    } else {
                        // TODO Show default error message
                        emit(loadingFinishedState)
                    }
                }
            )
        }
    }
}
