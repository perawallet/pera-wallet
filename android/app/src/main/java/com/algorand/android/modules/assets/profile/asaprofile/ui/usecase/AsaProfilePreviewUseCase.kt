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

package com.algorand.android.modules.assets.profile.asaprofile.ui.usecase

import com.algorand.android.R
import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.mapper.AssetActionMapper
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetAssetDetailFlowFromAsaProfileLocalCache
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetSelectedAssetExchangeValueUseCase
import com.algorand.android.modules.assets.profile.asaprofile.ui.mapper.AsaProfilePreviewMapper
import com.algorand.android.modules.assets.profile.asaprofile.ui.mapper.AsaStatusPreviewMapper
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaProfilePreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.PeraButtonState
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.ALGO_SHORT_NAME
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.isGreaterThan
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow

@SuppressWarnings("LongParameterList")
class AsaProfilePreviewUseCase @Inject constructor(
    private val getAssetDetailFlowFromAsaProfileLocalCache: GetAssetDetailFlowFromAsaProfileLocalCache,
    private val getSelectedAssetExchangeValueUseCase: GetSelectedAssetExchangeValueUseCase,
    private val asaProfilePreviewMapper: AsaProfilePreviewMapper,
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider,
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider,
    private val accountAddressUseCase: AccountAddressUseCase,
    private val asaStatusPreviewMapper: AsaStatusPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val assetActionMapper: AssetActionMapper,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase
) {

    // TODO: We should fetch asset details from API
    fun createAssetAction(assetId: Long, accountAddress: String?): AssetAction {
        val assetDetail = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data
        return assetActionMapper.mapTo(
            assetId = assetId,
            fullName = assetDetail?.fullName ?: assetId.toString(),
            shortName = assetDetail?.shortName,
            verificationTier = assetDetail?.verificationTier,
            accountAddress = accountAddress,
            creatorPublicKey = assetDetail?.assetCreator?.publicKey
        )
    }

    fun getAsaProfilePreview(accountAddress: String?, assetId: Long): Flow<AsaProfilePreview?> {
        return when {
            accountAddress.isNullOrBlank() -> createAsaProfilePreviewWithoutAccountInformation()
            assetId == ALGO_ID -> createAlgoProfilePreviewWithAccountInformation(accountAddress)
            else -> createAsaProfilePreviewWithAccountInformation(accountAddress, assetId)
        }
    }

    private fun createAlgoProfilePreviewWithAccountInformation(accountAddress: String) = flow {
        simpleAssetDetailUseCase.getCachedAssetDetail(ALGO_ID)?.useSuspended(
            onSuccess = { cachedAlgoDetail ->
                val asaStatusPreview = createAsaStatusPreview(
                    isAlgo = true,
                    isUserOptedInAsset = true,
                    accountAddress = accountAddress,
                    hasUserAmount = true,
                    assetShortName = AssetName.createShortName(ALGO_SHORT_NAME)
                )
                val asaProfilePreview = cachedAlgoDetail.data?.run {
                    createAsaProfilePreviewFromAssetDetail(assetDetail = this, asaStatusPreview = asaStatusPreview)
                }
                emit(asaProfilePreview)
            }
        )
    }.distinctUntilChanged()

    private fun createAsaProfilePreviewWithAccountInformation(
        accountAddress: String,
        assetId: Long
    ): Flow<AsaProfilePreview?> {
        return combine(
            getAssetDetailFlowFromAsaProfileLocalCache.getAssetDetailFlowFromAsaProfileLocalCache(),
            accountDetailUseCase.getAccountDetailCacheFlow(accountAddress)
        ) { cachedAssetDetailResult, _ ->
            val ownedAssetData = getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(assetId, accountAddress)
            val hasUserAmount = ownedAssetData?.amount isGreaterThan BigInteger.ZERO
            val isUserOptedInAsset = accountDetailUseCase.isAssetOwnedByAccount(accountAddress, assetId)
            val asaStatusPreview = createAsaStatusPreview(
                isAlgo = false,
                isUserOptedInAsset = isUserOptedInAsset,
                accountAddress = accountAddress,
                hasUserAmount = hasUserAmount,
                formattedAccountBalance = ownedAssetData?.formattedAmount,
                assetShortName = AssetName.createShortName(ownedAssetData?.shortName)
            )
            cachedAssetDetailResult?.data?.run {
                createAsaProfilePreviewFromAssetDetail(assetDetail = this, asaStatusPreview = asaStatusPreview)
            }
        }
    }

    private fun createAsaProfilePreviewWithoutAccountInformation() = flow {
        getAssetDetailFlowFromAsaProfileLocalCache.getAssetDetailFlowFromAsaProfileLocalCache()
            .collect { cachedAssetDetailResult ->
                val asaStatusPreview = createAsaStatusPreview(
                    isAlgo = false,
                    isUserOptedInAsset = false,
                    accountAddress = null,
                    hasUserAmount = false,
                    assetShortName = null
                )
                val preview = cachedAssetDetailResult?.data?.run {
                    createAsaProfilePreviewFromAssetDetail(assetDetail = this, asaStatusPreview = asaStatusPreview)
                }
                emit(preview)
            }
    }

    private fun createAsaProfilePreviewFromAssetDetail(
        assetDetail: BaseAssetDetail,
        asaStatusPreview: AsaStatusPreview?
    ): AsaProfilePreview {
        return with(assetDetail) {
            val formattedAssetPrice = getSelectedAssetExchangeValueUseCase
                .getSelectedAssetExchangeValue(assetDetail = this)
                ?.getFormattedValue(isCompact = true)
            val verificationTierConfiguration = verificationTierConfigurationDecider
                .decideVerificationTierConfiguration(verificationTier)
            val assetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(assetDetail)
            val isAvailableOnDiscoverMobile = isAvailableOnDiscoverMobile ?: false
            val isMarketInformationVisible = isAvailableOnDiscoverMobile &&
                verificationTier != VerificationTier.SUSPICIOUS &&
                hasUsdValue()
            asaProfilePreviewMapper.mapToAsaProfilePreview(
                isAlgo = assetDetail.assetId == ALGO_ID,
                assetFullName = fullName,
                assetShortName = shortName,
                assetId = assetId,
                formattedAssetPrice = formattedAssetPrice,
                verificationTierConfiguration = verificationTierConfiguration,
                baseAssetDrawableProvider = assetDrawableProvider,
                assetPrismUrl = logoUri,
                asaStatusPreview = asaStatusPreview,
                isMarketInformationVisible = isMarketInformationVisible,
                last24HoursChange = last24HoursAlgoPriceChangePercentage
            )
        }
    }

    private fun createAsaStatusPreview(
        isAlgo: Boolean,
        isUserOptedInAsset: Boolean,
        accountAddress: String?,
        hasUserAmount: Boolean,
        formattedAccountBalance: String? = null,
        assetShortName: AssetName?
    ): AsaStatusPreview? {
        return when {
            isAlgo -> null
            accountAddress.isNullOrBlank() -> {
                asaStatusPreviewMapper.mapToAsaAccountSelectionStatusPreview(
                    statusLabelTextResId = R.string.you_can_opt_in_to_this,
                    peraButtonState = PeraButtonState.ADDITION,
                    actionButtonTextResId = R.string.opt_in_to_asset
                )
            }
            !isUserOptedInAsset -> {
                asaStatusPreviewMapper.mapToAsaAdditionStatusPreview(
                    accountAddress = accountAddressUseCase.createAccountAddress(accountAddress),
                    statusLabelTextResId = R.string.you_can_add_this_asset,
                    peraButtonState = PeraButtonState.ADDITION,
                    actionButtonTextResId = R.string.opt_in_to_asset
                )
            }
            isUserOptedInAsset && hasUserAmount -> {
                asaStatusPreviewMapper.mapToAsaTransferStatusPreview(
                    statusLabelTextResId = R.string.balance,
                    peraButtonState = PeraButtonState.REMOVAL,
                    actionButtonTextResId = R.string.remove,
                    formattedAccountBalance = formattedAccountBalance.orEmpty(),
                    assetShortName = assetShortName
                )
            }
            isUserOptedInAsset -> {
                asaStatusPreviewMapper.mapToAsaRemovalStatusPreview(
                    statusLabelTextResId = R.string.balance,
                    peraButtonState = PeraButtonState.REMOVAL,
                    actionButtonTextResId = R.string.remove,
                    formattedAccountBalance = formattedAccountBalance.orEmpty(),
                    assetShortName = assetShortName
                )
            }
            else -> null
        }
    }
}
