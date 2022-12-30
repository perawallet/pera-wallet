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

package com.algorand.android.modules.collectibles.detail.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.models.Result
import com.algorand.android.modules.collectibles.detail.base.domain.usecase.GetCollectibleDetailUseCase
import com.algorand.android.modules.collectibles.detail.base.ui.mapper.CollectibleMediaItemMapper
import com.algorand.android.modules.collectibles.detail.base.ui.model.BaseCollectibleMediaItem
import com.algorand.android.modules.collectibles.detail.ui.mapper.CollectibleDetailItemMapper
import com.algorand.android.modules.collectibles.detail.ui.model.CollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.utils.CollectibleUtils
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.usecase.AccountCollectibleDataUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import java.math.BigInteger
import javax.inject.Inject

class CollectibleDetailItemUseCase @Inject constructor(
    private val collectibleDetailItemMapper: CollectibleDetailItemMapper,
    private val accountAddressUseCase: AccountAddressUseCase,
    private val collectibleMediaItemMapper: CollectibleMediaItemMapper,
    private val collectibleDetailUseCase: GetCollectibleDetailUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val collectibleUtils: CollectibleUtils,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase
) {

    suspend fun getCollectibleDetailItemFlow(
        collectibleAssetId: Long,
        selectedAccountAddress: String
    ): Result<CollectibleDetail> {
        return collectibleDetailUseCase.getCollectibleDetail(collectibleAssetId).map {
            val accountDetailList = accountDetailUseCase.getCachedAccountDetails()
            val ownerAccount = collectibleUtils.getCollectibleOwnerAccountOrNull(
                accountDetailList = accountDetailList,
                collectibleAssetId = collectibleAssetId,
                publicKey = selectedAccountAddress
            )
            val isHoldingByWatchAccount = ownerAccount?.type == Account.Type.WATCH
            val isOwnedByTheUser = collectibleUtils.isCollectibleOwnedByTheUser(
                accountDetailUseCase.getCachedAccountDetail(selectedAccountAddress),
                collectibleAssetId
            )
            val collectibleDetail = accountCollectibleDataUseCase.getAccountCollectibleDetail(
                accountAddress = selectedAccountAddress,
                collectibleId = collectibleAssetId
            )
            val formattedCollectibleAmount = collectibleDetail?.formattedCompactAmount.orEmpty()
            val isAmountVisible = (collectibleDetail?.amount ?: BigInteger.ZERO) > BigInteger.ONE

            getCollectibleDetailItem(
                baseCollectibleDetail = it,
                isOwnedByTheUser = isOwnedByTheUser,
                ownerAccountPublicKey = selectedAccountAddress,
                ownerAccount = ownerAccount,
                isHoldingByWatchAccount = isHoldingByWatchAccount,
                formattedCollectibleAmount = formattedCollectibleAmount,
                isAmountVisible = isAmountVisible
            )
        }
    }

    @SuppressWarnings("LongMethod")
    private fun getCollectibleDetailItem(
        baseCollectibleDetail: BaseCollectibleDetail,
        isOwnedByTheUser: Boolean,
        ownerAccountPublicKey: String,
        ownerAccount: Account?,
        isHoldingByWatchAccount: Boolean,
        formattedCollectibleAmount: String,
        isAmountVisible: Boolean
    ): CollectibleDetail {
        val isNftExplorerVisible = !baseCollectibleDetail.nftExplorerUrl.isNullOrBlank()
        val ownerAccountAddress = accountAddressUseCase.createAccountAddress(ownerAccountPublicKey)
        val creatorAccountAddress = getCreatorAccountAddress(baseCollectibleDetail.assetCreator?.publicKey)
        val isCreatedByTheUser = creatorAccountAddress?.publicKey == ownerAccountPublicKey
        return when (baseCollectibleDetail) {
            is BaseCollectibleDetail.ImageCollectibleDetail -> {
                collectibleDetailItemMapper.mapToCollectibleImage(
                    imageCollectibleDetail = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    isCreatedByTheUser = isCreatedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    isNftExplorerVisible = isNftExplorerVisible,
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress,
                    formattedCollectibleAmount = formattedCollectibleAmount,
                    isAmountVisible = isAmountVisible
                )
            }
            is BaseCollectibleDetail.VideoCollectibleDetail -> {
                collectibleDetailItemMapper.mapToCollectibleVideo(
                    videoCollectibleDetail = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    isCreatedByTheUser = isCreatedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    isNftExplorerVisible = isNftExplorerVisible,
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress,
                    formattedCollectibleAmount = formattedCollectibleAmount,
                    isAmountVisible = isAmountVisible
                )
            }
            is BaseCollectibleDetail.MixedCollectibleDetail -> {
                collectibleDetailItemMapper.mapToCollectibleMixed(
                    mixedCollectibleDetail = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    isCreatedByTheUser = isCreatedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    isNftExplorerVisible = isNftExplorerVisible,
                    collectibleMedias = mapToMixedMediaItem(baseCollectibleDetail, isOwnedByTheUser),
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress,
                    formattedCollectibleAmount = formattedCollectibleAmount,
                    isAmountVisible = isAmountVisible
                )
            }
            is BaseCollectibleDetail.NotSupportedCollectibleDetail -> {
                collectibleDetailItemMapper.mapToUnsupportedCollectible(
                    unsupportedCollectible = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    isCreatedByTheUser = isCreatedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    warningTextRes = R.string.we_don_t_support,
                    isNftExplorerVisible = isNftExplorerVisible,
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress,
                    formattedCollectibleAmount = formattedCollectibleAmount,
                    isAmountVisible = isAmountVisible
                )
            }
            is BaseCollectibleDetail.AudioCollectibleDetail -> {
                collectibleDetailItemMapper.mapToCollectibleAudio(
                    audioCollectibleDetail = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    isCreatedByTheUser = isCreatedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    isNftExplorerVisible = isNftExplorerVisible,
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress,
                    formattedCollectibleAmount = formattedCollectibleAmount,
                    isAmountVisible = isAmountVisible
                )
            }
        }
    }

    private fun mapToMixedMediaItem(
        collectibleDetail: BaseCollectibleDetail,
        isOwnedByTheUser: Boolean
    ): List<BaseCollectibleMediaItem> {
        return collectibleDetail.collectibleMedias?.map {
            collectibleMediaItemMapper.mapToCollectibleMediaItem(
                baseCollectibleMedia = it,
                shouldDecreaseOpacity = isOwnedByTheUser,
                baseCollectibleDetail = collectibleDetail,
                showMediaButtons = true
            )
        }.orEmpty()
    }

    private fun getCreatorAccountAddress(publicKey: String?): BaseAccountAddress.AccountAddress? {
        if (publicKey == null) return null
        return accountAddressUseCase.createAccountAddress(publicKey)
    }
}
