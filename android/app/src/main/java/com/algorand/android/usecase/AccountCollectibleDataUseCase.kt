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

package com.algorand.android.usecase

import com.algorand.android.mapper.AccountCollectibleDataMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AssetHolding
import com.algorand.android.models.AssetStatus.OWNED_BY_ACCOUNT
import com.algorand.android.models.AssetStatus.PENDING_FOR_ADDITION
import com.algorand.android.models.AssetStatus.PENDING_FOR_REMOVAL
import com.algorand.android.models.AssetStatus.PENDING_FOR_SENDING
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData
import com.algorand.android.models.SimpleCollectibleDetail
import com.algorand.android.nft.domain.model.CollectibleMediaType
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsCurrency
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.mapNotNull

class AccountCollectibleDataUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountCollectibleDataMapper: AccountCollectibleDataMapper,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase
) {

    fun getAccountOwnedCollectibleDataList(publicKey: String): List<BaseOwnedCollectibleData> {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)?.data ?: return emptyList()
        return createAccountOwnedCollectibleDataList(accountDetail)
    }

    private fun createAccountOwnedCollectibleDataList(account: AccountDetail): List<BaseOwnedCollectibleData> {
        val accountOwnedCollectibleList = getAccountOwnedCachedCollectibleList(account)
        return createCollectibleDataList(
            account,
            accountOwnedCollectibleList
        ).filterIsInstance<BaseOwnedCollectibleData>()
    }

    fun getAccountAllCollectibleDataFlow(publicKey: String): Flow<List<BaseAccountAssetData>> {
        return accountDetailUseCase.getAccountDetailCacheFlow()
            .mapNotNull { it.getOrDefault(publicKey, null)?.data }
            .distinctUntilChanged()
            .mapNotNull { account -> createAccountAllCollectibleDataList(account) }
    }

    fun getAccountOwnedCollectibleDataFlow(publicKey: String): Flow<List<BaseOwnedCollectibleData>> {
        return accountDetailUseCase.getAccountDetailCacheFlow()
            .mapNotNull { it.getOrDefault(publicKey, null)?.data }
            .distinctUntilChanged()
            .mapNotNull { account ->
                createAccountAllCollectibleDataList(account).filterIsInstance<BaseOwnedCollectibleData>()
            }
    }

    private fun createAccountAllCollectibleDataList(account: AccountDetail): List<BaseAccountAssetData> {
        val accountAllCollectibleList = getAccountAllCachedCollectibleList(account)
        return createCollectibleDataList(account, accountAllCollectibleList)
    }

    fun getAllAccountsAllCollectibleDataFlow(): Flow<List<Pair<AccountDetail, List<BaseAccountAssetData>>>> {
        return accountDetailUseCase.getAccountDetailCacheFlow()
            .mapNotNull { accounts -> accounts.values.mapNotNull { it.data } }
            .distinctUntilChanged()
            .mapNotNull { account -> createAllAccountsAllCollectibleDataList(account) }
    }

    private fun createAllAccountsAllCollectibleDataList(
        accounts: List<AccountDetail>
    ): List<Pair<AccountDetail, List<BaseAccountAssetData>>> {
        return accounts.map { account ->
            val accountAllCollectibleList = getAccountAllCachedCollectibleList(account)
            val collectibles = createCollectibleDataList(account, accountAllCollectibleList)
            Pair(account, collectibles)
        }
    }

    private fun getAccountAllCachedCollectibleList(account: AccountDetail): List<SimpleCollectibleDetail> {
        return simpleCollectibleUseCase.getCachedCollectibleList(getAccountAllCollectibleIdList(account))
            .mapNotNull { it.data }
    }

    private fun getAccountAllCollectibleIdList(account: AccountDetail): List<Long> {
        return account.accountInformation.getAllAssetIds()
    }

    private fun createCollectibleDataList(
        account: AccountDetail,
        cachedAssetList: List<SimpleCollectibleDetail>
    ): List<BaseAccountAssetData> {
        return mutableListOf<BaseAccountAssetData>().apply {
            account.accountInformation.assetHoldingList.forEach { assetHolding ->
                cachedAssetList.firstOrNull { it.assetId == assetHolding.assetId }?.let { assetItem ->
                    val accountAssetData = when (assetHolding.status) {
                        OWNED_BY_ACCOUNT -> createCollectibleData(assetHolding, assetItem)
                        PENDING_FOR_REMOVAL -> createPendingRemovalCollectibleData(assetItem)
                        PENDING_FOR_ADDITION -> createPendingAdditionCollectibleData(assetItem)
                        PENDING_FOR_SENDING -> createPendingSendingCollectibleData(assetItem)
                    }
                    if (accountAssetData is BaseAccountAssetData.BaseOwnedAssetData) {
                        add(accountAssetData)
                    } else {
                        add(0, accountAssetData)
                    }
                }
            }
        }
    }

    private fun getAccountOwnedCachedCollectibleList(account: AccountDetail): List<SimpleCollectibleDetail> {
        return simpleCollectibleUseCase.getCachedCollectibleList(getAccountOwnedCollectibleIdList(account))
            .mapNotNull { it.data }
    }

    private fun getAccountOwnedCollectibleIdList(account: AccountDetail): List<Long> {
        return account.accountInformation.assetHoldingList.mapNotNull { assetHolding ->
            assetHolding.assetId.takeIf { assetHolding.status == OWNED_BY_ACCOUNT }
        }
    }

    private fun createCollectibleData(
        assetHolding: AssetHolding,
        collectibleItem: SimpleCollectibleDetail
    ): BaseOwnedCollectibleData {
        // TODO: 16.03.2022 Get selected currency symbol from algoPriceUseCase method when branch is merged to dev
        val selectedCurrencySymbol = algoPriceUseCase.getSelectedCurrencySymbolOrEmpty()
        val safeDecimal = collectibleItem.fractionDecimals ?: DEFAULT_ASSET_DECIMAL
        val assetAmountInSelectedCurrency =
            accountAssetAmountUseCase.getAssetAmountInSelectedCurrency(assetHolding, collectibleItem)
        return when (collectibleItem.collectible.mediaType) {
            CollectibleMediaType.IMAGE -> accountCollectibleDataMapper.mapToOwnedCollectibleImageData(
                collectibleDetail = collectibleItem,
                amount = assetHolding.amount,
                formattedAmount = assetHolding.amount.formatAmount(safeDecimal),
                formattedCompactAmount = assetHolding.amount.formatAmount(safeDecimal, isCompact = true),
                amountInSelectedCurrency = assetAmountInSelectedCurrency,
                formattedSelectedCurrencyValue = assetAmountInSelectedCurrency.formatAsCurrency(selectedCurrencySymbol),
                formattedSelectedCurrencyCompactValue = assetAmountInSelectedCurrency.formatAsCurrency(
                    selectedCurrencySymbol,
                    true
                )
            )
            CollectibleMediaType.VIDEO -> accountCollectibleDataMapper.mapToOwnedCollectibleVideoData(
                collectibleDetail = collectibleItem,
                amount = assetHolding.amount,
                formattedAmount = assetHolding.amount.formatAmount(safeDecimal),
                formattedCompactAmount = assetHolding.amount.formatAmount(safeDecimal, isCompact = true),
                amountInSelectedCurrency = assetAmountInSelectedCurrency,
                formattedSelectedCurrencyValue = assetAmountInSelectedCurrency.formatAsCurrency(selectedCurrencySymbol),
                formattedSelectedCurrencyCompactValue = assetAmountInSelectedCurrency.formatAsCurrency(
                    selectedCurrencySymbol,
                    true
                )
            )
            CollectibleMediaType.MIXED -> accountCollectibleDataMapper.mapToOwnedCollectibleMixedData(
                collectibleDetail = collectibleItem,
                amount = assetHolding.amount,
                formattedAmount = assetHolding.amount.formatAmount(safeDecimal),
                formattedCompactAmount = assetHolding.amount.formatAmount(safeDecimal, isCompact = true),
                amountInSelectedCurrency = assetAmountInSelectedCurrency,
                formattedSelectedCurrencyValue = assetAmountInSelectedCurrency.formatAsCurrency(selectedCurrencySymbol),
                formattedSelectedCurrencyCompactValue = assetAmountInSelectedCurrency.formatAsCurrency(
                    selectedCurrencySymbol,
                    true
                )
            )
            CollectibleMediaType.NOT_SUPPORTED -> accountCollectibleDataMapper.mapToNotSupportedOwnedCollectibleData(
                collectibleDetail = collectibleItem,
                amount = assetHolding.amount,
                formattedAmount = assetHolding.amount.formatAmount(safeDecimal),
                formattedCompactAmount = assetHolding.amount.formatAmount(safeDecimal, isCompact = true),
                amountInSelectedCurrency = assetAmountInSelectedCurrency,
                formattedSelectedCurrencyValue = assetAmountInSelectedCurrency.formatAsCurrency(selectedCurrencySymbol),
                formattedSelectedCurrencyCompactValue = assetAmountInSelectedCurrency.formatAsCurrency(
                    selectedCurrencySymbol,
                    true
                )
            )
        }
    }

    private fun createPendingRemovalCollectibleData(
        collectibleItem: SimpleCollectibleDetail
    ): BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData {
        return with(accountCollectibleDataMapper) {
            when (collectibleItem.collectible.mediaType) {
                CollectibleMediaType.IMAGE -> mapToPendingRemovalImageCollectibleData(collectibleItem)
                CollectibleMediaType.VIDEO -> mapToPendingRemovalVideoCollectibleData(collectibleItem)
                CollectibleMediaType.NOT_SUPPORTED -> mapToPendingRemovalUnsupportedCollectibleData(collectibleItem)
                CollectibleMediaType.MIXED -> mapToPendingRemovalMixedCollectibleData(collectibleItem)
            }
        }
    }

    private fun createPendingAdditionCollectibleData(
        collectibleItem: SimpleCollectibleDetail
    ): BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData {
        return with(accountCollectibleDataMapper) {
            when (collectibleItem.collectible.mediaType) {
                CollectibleMediaType.IMAGE -> mapToPendingAdditionImageCollectibleData(collectibleItem)
                CollectibleMediaType.VIDEO -> mapToPendingAdditionVideoCollectibleData(collectibleItem)
                CollectibleMediaType.NOT_SUPPORTED -> mapToPendingAdditionUnsupportedCollectibleData(collectibleItem)
                CollectibleMediaType.MIXED -> mapToPendingAdditionMixedCollectibleData(collectibleItem)
            }
        }
    }

    private fun createPendingSendingCollectibleData(
        collectibleItem: SimpleCollectibleDetail
    ): BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData {
        return with(accountCollectibleDataMapper) {
            when (collectibleItem.collectible.mediaType) {
                CollectibleMediaType.IMAGE -> mapToPendingSendingImageCollectibleData(collectibleItem)
                CollectibleMediaType.VIDEO -> mapToPendingSendingVideoCollectibleData(collectibleItem)
                CollectibleMediaType.NOT_SUPPORTED -> mapToPendingSendingUnsupportedCollectibleData(collectibleItem)
                CollectibleMediaType.MIXED -> mapToPendingSendingMixedCollectibleData(collectibleItem)
            }
        }
    }
}
