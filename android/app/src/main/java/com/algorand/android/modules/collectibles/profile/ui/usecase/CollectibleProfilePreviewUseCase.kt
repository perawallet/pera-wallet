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

package com.algorand.android.modules.collectibles.profile.ui.usecase

import com.algorand.android.R
import com.algorand.android.mapper.AssetActionMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AssetAction
import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.modules.assets.profile.asaprofile.ui.mapper.AsaStatusPreviewMapper
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusActionType
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.PeraButtonState
import com.algorand.android.modules.collectibles.profile.ui.mapper.CollectibleProfileMapper
import com.algorand.android.modules.collectibles.profile.ui.mapper.CollectibleProfilePreviewMapper
import com.algorand.android.modules.collectibles.profile.ui.model.CollectibleProfile
import com.algorand.android.modules.collectibles.profile.ui.model.CollectibleProfilePreview
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.domain.usecase.GetCollectibleDetailUseCase
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.nft.utils.CollectibleUtils
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

@SuppressWarnings("LongParameterList")
class CollectibleProfilePreviewUseCase @Inject constructor(
    private val getCollectibleDetailUseCase: GetCollectibleDetailUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountAddressUseCase: AccountAddressUseCase,
    private val asaStatusPreviewMapper: AsaStatusPreviewMapper,
    private val collectibleProfilePreviewMapper: CollectibleProfilePreviewMapper,
    private val collectibleProfileMapper: CollectibleProfileMapper,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val assetActionMapper: AssetActionMapper,
    private val collectibleUtils: CollectibleUtils,
) {

    fun createAssetAction(assetId: Long, accountAddress: String?): AssetAction {
        val collectibleDetail = simpleCollectibleUseCase.getCachedCollectibleById(assetId)?.data
        return assetActionMapper.mapTo(
            assetId = assetId,
            fullName = collectibleDetail?.fullName,
            shortName = collectibleDetail?.shortName,
            verificationTier = collectibleDetail?.verificationTier,
            accountAddress = accountAddress,
            creatorPublicKey = collectibleDetail?.assetCreator?.publicKey
        )
    }

    fun getLoadingPreview(accountAddress: String): CollectibleProfilePreview {
        return collectibleProfilePreviewMapper.mapToCollectibleProfilePreview(
            isLoadingVisible = true,
            asaStatusPreview = null,
            collectibleProfile = null,
            accountAddress = accountAddress
        )
    }

    fun getCollectibleProfilePreviewFlow(
        collectibleId: Long,
        accountAddress: String
    ): Flow<CollectibleProfilePreview?> {
        return combine(
            getCollectibleDetailUseCase.getCollectibleDetail(collectibleId),
            accountDetailUseCase.getAccountDetailCacheFlow(accountAddress)
        ) { baseCollectibleDetailResource, cachedAccountDetail ->
            when (baseCollectibleDetailResource) {
                is DataResource.Loading -> getLoadingPreview(accountAddress)
                is DataResource.Error -> null // todo handle error case when have a design
                is DataResource.Success -> {
                    val isOptedInByAccount = accountDetailUseCase.isAssetOwnedByAccount(
                        publicKey = accountAddress,
                        assetId = collectibleId
                    )
                    val isOwnedByTheUser = collectibleUtils.isCollectibleOwnedByTheUser(
                        accountDetail = cachedAccountDetail,
                        collectibleAssetId = collectibleId
                    )
                    val asaStatusPreview = createAsaStatusPreview(
                        isUserHasCollectibleBalance = isOwnedByTheUser,
                        isCollectibleOwnedByAccount = isOptedInByAccount,
                        accountAddress = accountAddress,
                        creatorWalletAddress = baseCollectibleDetailResource.data.assetCreator?.publicKey
                    )
                    val collectibleProfile = createCollectibleProfilePreview(
                        baseCollectibleDetail = baseCollectibleDetailResource.data,
                        isOwnedByTheUser = !isOptedInByAccount || isOwnedByTheUser,
                        ownerAccountType = cachedAccountDetail?.data?.account?.type
                    )
                    collectibleProfilePreviewMapper.mapToCollectibleProfilePreview(
                        isLoadingVisible = false,
                        collectibleProfile = collectibleProfile,
                        asaStatusPreview = asaStatusPreview,
                        accountAddress = accountAddress
                    )
                }
            }
        }
    }

    private fun createCollectibleProfilePreview(
        baseCollectibleDetail: BaseCollectibleDetail,
        isOwnedByTheUser: Boolean,
        ownerAccountType: Account.Type?
    ): CollectibleProfile {

        val errorDisplayText = baseCollectibleDetail.getErrorDisplayText()

        return collectibleProfileMapper.mapToCollectibleProfile(
            collectibleDetail = baseCollectibleDetail,
            creatorWalletAddress = getCreatorAccountAddress(baseCollectibleDetail.assetCreator?.publicKey),
            ownerAccountType = ownerAccountType,
            isOwnedByTheUser = isOwnedByTheUser,
            errorDisplayText = errorDisplayText,
            prismUrl = getCollectiblePrismUrl(baseCollectibleDetail)
        )
    }

    private fun createAsaStatusPreview(
        isUserHasCollectibleBalance: Boolean,
        accountAddress: String,
        isCollectibleOwnedByAccount: Boolean,
        creatorWalletAddress: String?
    ): AsaStatusPreview? {
        return when {
            !isCollectibleOwnedByAccount -> {
                asaStatusPreviewMapper.mapToAsaStatusPreview(
                    accountAddress = accountAddressUseCase.createAccountAddress(accountAddress),
                    statusLabelTextResId = R.string.you_can_add_this_nft,
                    peraButtonState = PeraButtonState.ADDITION,
                    actionButtonTextResId = R.string.opt_dash_in,
                    asaStatusActionType = AsaStatusActionType.ADDITION
                )
            }
            !isUserHasCollectibleBalance && creatorWalletAddress != accountAddress -> {
                asaStatusPreviewMapper.mapToAsaStatusPreview(
                    accountAddress = accountAddressUseCase.createAccountAddress(accountAddress),
                    statusLabelTextResId = R.string.opted_in_to,
                    peraButtonState = PeraButtonState.REMOVAL,
                    actionButtonTextResId = R.string.remove,
                    asaStatusActionType = AsaStatusActionType.REMOVAL
                )
            }
            else -> null
        }
    }

    private fun getCreatorAccountAddress(publicKey: String?): BaseAccountAddress.AccountAddress? {
        if (publicKey == null) return null
        return accountAddressUseCase.createAccountAddress(publicKey)
    }

    private fun getCollectiblePrismUrl(baseCollectibleDetail: BaseCollectibleDetail): String? {
        return with(baseCollectibleDetail) {
            when (this) {
                is BaseCollectibleDetail.ImageCollectibleDetail -> prismUrl
                is BaseCollectibleDetail.MixedCollectibleDetail -> thumbnailPrismUrl
                is BaseCollectibleDetail.NotSupportedCollectibleDetail -> null
                is BaseCollectibleDetail.VideoCollectibleDetail -> thumbnailPrismUrl
            }
        }
    }
}
