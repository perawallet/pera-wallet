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
import com.algorand.android.models.AssetAction
import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.assets.profile.asaprofile.ui.mapper.AsaStatusPreviewMapper
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.PeraButtonState
import com.algorand.android.modules.collectibles.detail.base.domain.decider.CollectibleDetailDecider
import com.algorand.android.modules.collectibles.detail.base.domain.usecase.GetCollectibleDetailUseCase
import com.algorand.android.modules.collectibles.detail.base.ui.mapper.CollectibleMediaItemMapper
import com.algorand.android.modules.collectibles.detail.base.ui.mapper.CollectibleTraitItemMapper
import com.algorand.android.modules.collectibles.profile.ui.mapper.CollectibleProfilePreviewMapper
import com.algorand.android.modules.collectibles.profile.ui.model.CollectibleProfilePreview
import com.algorand.android.modules.collectibles.util.deciders.NFTAmountFormatDecider
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.nft.utils.CollectibleUtils
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.AssetName
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

@SuppressWarnings("LongParameterList")
class CollectibleProfilePreviewUseCase @Inject constructor(
    private val getCollectibleDetailUseCase: GetCollectibleDetailUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountAddressUseCase: AccountAddressUseCase,
    private val asaStatusPreviewMapper: AsaStatusPreviewMapper,
    private val collectibleProfilePreviewMapper: CollectibleProfilePreviewMapper,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val assetActionMapper: AssetActionMapper,
    private val collectibleUtils: CollectibleUtils,
    private val collectibleMediaItemMapper: CollectibleMediaItemMapper,
    private val collectibleTraitItemMapper: CollectibleTraitItemMapper,
    private val collectibleDetailDecider: CollectibleDetailDecider,
    private val nftAmountFormatDecider: NFTAmountFormatDecider,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase
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

    fun getCollectibleProfilePreviewFlow(nftId: Long, accountAddress: String) = flow<CollectibleProfilePreview?> {
        accountDetailUseCase.getAccountDetailCacheFlow(accountAddress).collect { cachedAccountDetail ->
            val accountDetail = cachedAccountDetail?.data ?: return@collect
            getCollectibleDetailUseCase.getCollectibleDetail(nftId).use(
                onSuccess = { nftDetail ->
                    val isOptedInByAccount = accountDetailUseCase.isAssetOwnedByAccount(
                        publicKey = accountAddress,
                        assetId = nftId
                    )
                    val isOwnedByTheUser = collectibleUtils.isCollectibleOwnedByTheUser(
                        accountDetail = accountDetail,
                        collectibleAssetId = nftId
                    )
                    val asaStatusPreview = createAsaStatusPreview(
                        isUserHasCollectibleBalance = isOwnedByTheUser,
                        isCollectibleOwnedByAccount = isOptedInByAccount,
                        accountAddress = accountAddress,
                        creatorWalletAddress = nftDetail.assetCreator?.publicKey
                    )
                    val preview = collectibleProfilePreviewMapper.mapToCollectibleProfilePreview(
                        isLoadingVisible = false,
                        asaStatusPreview = asaStatusPreview,
                        accountAddress = accountAddress,
                        nftName = AssetName.create(nftDetail.title ?: nftDetail.fullName),
                        collectionNameOfNFT = nftDetail.collectionName,
                        mediaListOfNFT = nftDetail.collectibleMedias?.map { nftMedia ->
                            collectibleMediaItemMapper.mapToCollectibleMediaItem(
                                baseCollectibleMedia = nftMedia,
                                shouldDecreaseOpacity = !isOptedInByAccount,
                                baseCollectibleDetail = nftDetail,
                                showMediaButtons = true
                            )
                        }.orEmpty(),
                        traitListOfNFT = nftDetail.traits?.map { collectibleTraitItemMapper.mapToTraitItem(it) },
                        nftId = nftDetail.assetId,
                        nftDescription = nftDetail.description,
                        creatorAccountAddressOfNFT = accountDisplayNameUseCase.invoke(
                            accountAddress = nftDetail.assetCreator?.publicKey.orEmpty()
                        ),
                        formattedTotalSupply = nftAmountFormatDecider.decideNFTAmountFormat(
                            nftAmount = nftDetail.totalSupply,
                            fractionalDecimal = nftDetail.fractionDecimals
                        ),
                        peraExplorerUrl = nftDetail.explorerUrl.orEmpty(),
                        isPureNFT = nftDetail.isPure(),
                        primaryWarningResId = collectibleDetailDecider.decideWarningTextRes(
                            prismUrl = nftDetail.prismUrl
                        ),
                        secondaryWarningResId = null
                    )
                    emit(preview)
                }
            )
        }
    }

    private fun createAsaStatusPreview(
        isUserHasCollectibleBalance: Boolean,
        accountAddress: String,
        isCollectibleOwnedByAccount: Boolean,
        creatorWalletAddress: String?
    ): AsaStatusPreview? {
        return when {
            !isCollectibleOwnedByAccount -> {
                asaStatusPreviewMapper.mapToAsaAdditionStatusPreview(
                    accountAddress = accountAddressUseCase.createAccountAddress(accountAddress),
                    statusLabelTextResId = R.string.you_can_opt_in_to_this_nft,
                    peraButtonState = PeraButtonState.ADDITION,
                    actionButtonTextResId = R.string.opt_dash_in
                )
            }
            !isUserHasCollectibleBalance && creatorWalletAddress != accountAddress -> {
                asaStatusPreviewMapper.mapToCollectibleRemovalStatusPreview(
                    statusLabelTextResId = R.string.opted_in_to,
                    peraButtonState = PeraButtonState.REMOVAL,
                    actionButtonTextResId = R.string.remove,
                    accountAddress = accountAddressUseCase.createAccountAddress(accountAddress)
                )
            }
            else -> null
        }
    }

    private fun getCreatorAccountAddress(publicKey: String?): BaseAccountAddress.AccountAddress? {
        if (publicKey == null) return null
        return accountAddressUseCase.createAccountAddress(publicKey)
    }
}
