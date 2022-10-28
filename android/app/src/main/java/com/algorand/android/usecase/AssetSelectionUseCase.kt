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
import com.algorand.android.nft.domain.usecase.CollectibleDetailItemUseCase
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.nft.mapper.AssetSelectionPreviewMapper
import com.algorand.android.nft.ui.model.AssetSelectionPreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.isGreaterThan
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.emitAll
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
    private val assetItemSortUseCase: AssetItemSortUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val collectibleDetailItemUseCase: CollectibleDetailItemUseCase
) {
    fun getAssetSelectionListFlow(publicKey: String): Flow<List<BaseSelectAssetItem>> {
        return combine(
            accountAssetDataUseCase.getAccountOwnedAssetDataFlow(publicKey = publicKey, includeAlgo = true),
            accountCollectibleDataUseCase.getAccountOwnedCollectibleDataFlow(publicKey),
            parityUseCase.getSelectedCurrencyDetailCacheFlow()
        ) { accountAssetData, accountCollectibleData, _ ->
            val assetList = mutableListOf<BaseSelectAssetItem>().apply {
                addAll(createAssetSelectionItems(accountAssetData))
                addAll(createCollectibleSelectionItems(accountCollectibleData))
            }
            assetItemSortUseCase.sortAssets(assetList)
        }.distinctUntilChanged()
    }

    private fun createAssetSelectionItems(
        accountAssetData: List<BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData>
    ): List<BaseSelectAssetItem> {
        return accountAssetData.map { baseAccountAssetData ->
            val assetItemConfiguration = with(baseAccountAssetData) {
                assetItemConfigurationMapper.mapTo(
                    isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                    secondaryValueText = getSelectedCurrencyParityValue().getFormattedValue(isCompact = true),
                    formattedCompactAmount = formattedCompactAmount,
                    assetId = id,
                    name = name,
                    shortName = shortName,
                    prismUrl = prismUrl,
                    verificationTier = verificationTier,
                    primaryValue = parityValueInSelectedCurrency.amountAsCurrency
                )
            }
            assetSelectionMapper.mapToAssetItem(assetItemConfiguration)
        }
    }

    private fun createCollectibleSelectionItems(
        accountCollectibleData: List<BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData>
    ): List<BaseSelectAssetItem.BaseSelectCollectibleItem> {
        return accountCollectibleData.mapNotNull { ownedCollectibleData ->
            val isOwnedByTheUser = ownedCollectibleData.amount isGreaterThan BigInteger.ZERO
            if (isOwnedByTheUser) {
                when (ownedCollectibleData) {
                    is OwnedCollectibleImageData -> assetSelectionMapper.mapToCollectibleImageItem(ownedCollectibleData)
                    is OwnedCollectibleVideoData -> assetSelectionMapper.mapToCollectibleVideoItem(ownedCollectibleData)
                    is OwnedCollectibleMixedData -> assetSelectionMapper.mapToCollectibleMixedItem(ownedCollectibleData)
                    is OwnedUnsupportedCollectibleData -> {
                        assetSelectionMapper.mapToCollectibleNotSupportedItem(ownedCollectibleData)
                    }
                }
            } else {
                null
            }
        }
    }

    fun shouldShowTransactionTips(): Boolean {
        return transactionTipsUseCase.shouldShowTransactionTips()
    }

    fun getInitialStateOfAssetSelectionPreview(assetTransaction: AssetTransaction): AssetSelectionPreview {
        return assetSelectionPreviewMapper.mapToInitialState(assetTransaction)
    }

    fun getUpdatedPreviewFlowWithSelectedAsset(
        assetId: Long,
        previousState: AssetSelectionPreview
    ) = flow<AssetSelectionPreview> {
        emit(previousState.copy(isReceiverAccountOptInCheckLoadingVisible = true))
        val receiverAddress = previousState.assetTransaction.receiverUser?.publicKey
        val loadingFinishedStatePreview = previousState.copy(isReceiverAccountOptInCheckLoadingVisible = false)
        receiverAddress?.let {
            accountInformationUseCase.getAccountInformation(it).collect {
                it.useSuspended(
                    onSuccess = { accountInformation ->
                        val isReceiverOptedInToAsset = accountInformation.assetHoldingList.any { assetHolding ->
                            assetHolding.assetId == assetId
                        } || assetId == ALGO_ID
                        if (!isReceiverOptedInToAsset) {
                            emit(loadingFinishedStatePreview.copy(navigateToOptInEvent = Event(assetId)))
                        } else {
                            emitAll(getSendAssetNavigationUpdatedPreviewFlow(assetId, loadingFinishedStatePreview))
                        }
                    },
                    onFailed = { errorDataResource ->
                        val exceptionMessage = errorDataResource.exception?.message
                        if (exceptionMessage != null) {
                            emit(loadingFinishedStatePreview.copy(globalErrorTextEvent = Event(exceptionMessage)))
                        } else {
                            // TODO Show default error message
                            emit(loadingFinishedStatePreview)
                        }
                    }
                )
            }
        } ?: emitAll(getSendAssetNavigationUpdatedPreviewFlow(assetId, loadingFinishedStatePreview))
    }

    private suspend fun getSendAssetNavigationUpdatedPreviewFlow(
        assetId: Long,
        loadingFinishedStatePreview: AssetSelectionPreview
    ) = flow {
        val senderAddress = loadingFinishedStatePreview.assetTransaction.senderAddress
        val isPureCollectible = simpleCollectibleUseCase.isCachedCollectiblePureIfExists(assetId)
        if (isPureCollectible == true) {
            collectibleDetailItemUseCase.getCollectibleDetailItemFlow(assetId, senderAddress).collect {
                it.useSuspended(
                    onSuccess = {
                        emit(loadingFinishedStatePreview.copy(navigateToCollectibleSendFragmentEvent = Event(it)))
                    },
                    onFailed = {
                        emit(
                            loadingFinishedStatePreview.copy(
                                navigateToAssetTransferAmountFragmentEvent = Event(
                                    assetId
                                )
                            )
                        )
                    }
                )
            }
        } else {
            emit(loadingFinishedStatePreview.copy(navigateToAssetTransferAmountFragmentEvent = Event(assetId)))
        }
    }
}
