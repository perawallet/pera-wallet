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
 */

package com.algorand.android.nft.domain.usecase

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleMedia.GifCollectibleMedia
import com.algorand.android.nft.domain.model.BaseCollectibleMedia.ImageCollectibleMedia
import com.algorand.android.nft.domain.model.BaseCollectibleMedia.NoMediaCollectibleMedia
import com.algorand.android.nft.domain.model.BaseCollectibleMedia.UnsupportedCollectibleMedia
import com.algorand.android.nft.domain.model.BaseCollectibleMedia.VideoCollectibleMedia
import com.algorand.android.nft.mapper.CollectibleDetailMapper
import com.algorand.android.nft.mapper.CollectibleDetailPreviewMapper
import com.algorand.android.nft.mapper.CollectibleMediaItemMapper
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.CollectibleDetailPreview
import com.algorand.android.nft.utils.CollectibleUtils
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.usecase.AccountAssetRemovalUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.SendSignedTransactionUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

open class CollectibleDetailPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val collectibleDetailMapper: CollectibleDetailMapper,
    private val collectibleDetailPreviewMapper: CollectibleDetailPreviewMapper,
    private val collectibleUtils: CollectibleUtils,
    private val collectibleDetailUseCase: GetCollectibleDetailUseCase,
    private val collectibleMediaItemMapper: CollectibleMediaItemMapper,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val accountAssetRemovalUseCase: AccountAssetRemovalUseCase,
    private val accountAddressUseCase: AccountAddressUseCase
) {

    suspend fun getCollectableDetailPreviewFlow(collectibleAssetId: Long, publicKey: String) = flow {
        emit(collectibleDetailPreviewMapper.mapToLoading())
        val accountDetailList = accountDetailUseCase.getCachedAccountDetails()
        val ownerAccount = collectibleUtils
            .getCollectibleOwnerAccountOrNull(accountDetailList, collectibleAssetId, publicKey)
        val isHoldingByWatchAccount = ownerAccount?.type == Account.Type.WATCH
        val isOwnedByTheUser = collectibleUtils.isCollectibleOwnedByTheUser(
            accountDetailUseCase.getCachedAccountDetail(publicKey),
            collectibleAssetId
        )
        collectibleDetailUseCase.getCollectibleDetail(collectibleAssetId).collect { collectibleDetailResource ->
            collectibleDetailResource.useSuspended(
                onSuccess = { baseCollectibleDetail ->
                    val collectibleDetailPreview = onCollectibleDetailFetchedSuccessfully(
                        baseCollectibleDetail = baseCollectibleDetail,
                        isOwnedByTheUser = isOwnedByTheUser,
                        ownerAccount = ownerAccount,
                        isHoldingByWatchAccount = isHoldingByWatchAccount,
                        ownerAccountPublicKey = publicKey
                    )
                    emit(collectibleDetailPreview)
                },
                onFailed = {
                    // TODO Show error
                }
            )
        }
    }

    suspend fun sendSignedTransaction(
        signedTransactionDetail: SignedTransactionDetail.AssetOperation,
        previousState: CollectibleDetailPreview
    ) = flow<CollectibleDetailPreview> {
        sendSignedTransactionUseCase.sendSignedTransaction(signedTransactionDetail).map {
            it.useSuspended(
                onSuccess = {
                    accountAssetRemovalUseCase.addAssetDeletionToAccountCache(
                        publicKey = signedTransactionDetail.accountCacheData.account.address,
                        assetId = signedTransactionDetail.assetInformation.assetId
                    )
                    emit(previousState.copy(optOutSuccessEvent = Event(Unit)))
                },
                onFailed = {
                    val errorMessage = it.exception?.message.orEmpty()
                    emit(previousState.copy(isLoadingVisible = false, globalErrorEvent = Event(errorMessage)))
                },
                onLoading = {
                    emit(previousState.copy(isLoadingVisible = true))
                }
            )
        }.collect()
    }

    private fun onCollectibleDetailFetchedSuccessfully(
        baseCollectibleDetail: BaseCollectibleDetail,
        isOwnedByTheUser: Boolean,
        ownerAccountPublicKey: String,
        ownerAccount: Account?,
        isHoldingByWatchAccount: Boolean
    ): CollectibleDetailPreview {
        // TODO: 4.03.2022 Is error display text correct?
        val errorDisplayText = baseCollectibleDetail.title
            ?: baseCollectibleDetail.fullName
            ?: baseCollectibleDetail.shortName
            ?: baseCollectibleDetail.assetId.toString()
        val isNftExplorerVisible = !baseCollectibleDetail.nftExplorerUrl.isNullOrBlank()
        val ownerAccountAddress = accountAddressUseCase.createAccountAddress(ownerAccountPublicKey)
        val creatorAccountAddress = getCreatorAccountAddress(baseCollectibleDetail.assetCreator?.publicKey)
        val collectibleDetail = when (baseCollectibleDetail) {
            is BaseCollectibleDetail.ImageCollectibleDetail -> {
                collectibleDetailMapper.mapToCollectibleImage(
                    imageCollectibleDetail = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    errorDisplayText = errorDisplayText,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    isNftExplorerVisible = isNftExplorerVisible,
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress
                )
            }
            is BaseCollectibleDetail.VideoCollectibleDetail -> {
                collectibleDetailMapper.mapToCollectibleVideo(
                    videoCollectibleDetail = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    errorDisplayText = errorDisplayText,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    isNftExplorerVisible = isNftExplorerVisible,
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress
                )
            }
            is BaseCollectibleDetail.MixedCollectibleDetail -> {
                collectibleDetailMapper.mapToCollectibleMixed(
                    mixedCollectibleDetail = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    isNftExplorerVisible = isNftExplorerVisible,
                    collectibleMedias = mapToMixedMediaItem(baseCollectibleDetail, isOwnedByTheUser, errorDisplayText),
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress
                )
            }
            is BaseCollectibleDetail.NotSupportedCollectibleDetail -> {
                collectibleDetailMapper.mapToUnsupportedCollectible(
                    unsupportedCollectible = baseCollectibleDetail,
                    isOwnedByTheUser = isOwnedByTheUser,
                    ownerAccountAddress = ownerAccountAddress,
                    errorDisplayText = errorDisplayText,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    warningTextRes = R.string.we_don_t_support,
                    isNftExplorerVisible = isNftExplorerVisible,
                    ownerAccountType = ownerAccount?.type,
                    creatorAddress = creatorAccountAddress
                )
            }
        }

        return collectibleDetailPreviewMapper.mapTo(
            isLoadingVisible = false,
            isSendButtonVisible = isOwnedByTheUser,
            isErrorVisible = false,
            collectibleDetail = collectibleDetail
        )
    }

    private fun mapToMixedMediaItem(
        collectibleDetail: BaseCollectibleDetail,
        isOwnedByTheUser: Boolean,
        errorDisplayText: String
    ): List<BaseCollectibleMediaItem> {
        return collectibleDetail.collectibleMedias?.map {
            with(collectibleDetail) {
                with(collectibleMediaItemMapper) {
                    when (it) {
                        is ImageCollectibleMedia -> {
                            mapToImageCollectibleMediaItem(assetId, isOwnedByTheUser, errorDisplayText, it)
                        }
                        is UnsupportedCollectibleMedia -> {
                            mapToUnsupportedCollectibleMediaItem(assetId, isOwnedByTheUser, errorDisplayText, it)
                        }
                        is VideoCollectibleMedia -> {
                            val previewUrl = (it.previewUrl ?: it.downloadUrl).orEmpty()
                            mapToVideoCollectibleMediaItem(assetId, isOwnedByTheUser, errorDisplayText, it, previewUrl)
                        }
                        is GifCollectibleMedia -> {
                            mapToGifCollectibleMediaItem(assetId, isOwnedByTheUser, errorDisplayText, it)
                        }
                        is NoMediaCollectibleMedia -> {
                            mapToNoMediaCollectibleMediaItem(assetId, isOwnedByTheUser, errorDisplayText, it)
                        }
                    }
                }
            }
        }.orEmpty()
    }

    fun checkSendingCollectibleIsFractional(
        previousState: CollectibleDetailPreview?
    ) = flow<CollectibleDetailPreview?> {
        val collectibleDetail = previousState?.collectibleDetail
        val isCollectiblePure = collectibleDetail?.isPure ?: return@flow
        emit(
            previousState.copy(
                fractionalCollectibleSendEvent = if (isCollectiblePure.not()) Event(Unit) else null,
                pureCollectibleSendEvent = if (isCollectiblePure) Event(Unit) else null
            )
        )
    }

    private fun getCreatorAccountAddress(publicKey: String?): BaseAccountAddress.AccountAddress? {
        if (publicKey == null) return null
        return accountAddressUseCase.createAccountAddress(publicKey)
    }
}
