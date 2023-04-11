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

package com.algorand.android.nft.domain.usecase

import com.algorand.android.models.AssetStatus
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.modules.collectibles.detail.base.domain.usecase.GetCollectibleDetailUseCase
import com.algorand.android.modules.collectibles.detail.base.ui.mapper.CollectibleMediaItemMapper
import com.algorand.android.nft.mapper.CollectibleSendPreviewMapper
import com.algorand.android.nft.ui.model.CollectibleSendPreview
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AccountInformationUseCase
import com.algorand.android.usecase.SendSignedTransactionUseCase
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.Event
import java.io.IOException
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

class CollectibleSendPreviewUseCase @Inject constructor(
    private val collectibleSendPreviewMapper: CollectibleSendPreviewMapper,
    private val accountInformationUseCase: AccountInformationUseCase,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val getCollectibleDetailUseCase: GetCollectibleDetailUseCase,
    private val collectibleMediaItemMapper: CollectibleMediaItemMapper
) {

    suspend fun getInitialStateOfCollectibleSendPreview(nftId: Long) = flow {
        getCollectibleDetailUseCase.getCollectibleDetail(nftId).use(
            onSuccess = { baseCollectibleDetail ->
                val collectibleName = baseCollectibleDetail.fullName.orEmpty()
                val collectionName = baseCollectibleDetail.collectionName.orEmpty()
                emit(
                    collectibleSendPreviewMapper.mapToCollectibleSendPreview(
                        collectibleId = nftId,
                        collectionName = collectionName,
                        collectibleName = collectibleName,
                        collectibleMedias = baseCollectibleDetail.collectibleMedias?.map {
                            collectibleMediaItemMapper.mapToCollectibleMediaItem(
                                baseCollectibleMedia = it,
                                shouldDecreaseOpacity = false,
                                baseCollectibleDetail = baseCollectibleDetail,
                                showMediaButtons = false
                            )
                        }.orEmpty(),
                        isCollectionNameVisible = collectionName.isNotBlank(),
                        isCollectibleNameVisible = collectibleName.isNotBlank()
                    )
                )
            }
        )
    }

    fun checkIfSenderAndReceiverAccountSame(
        senderAccountAddress: String,
        receiverAccountAddress: String,
        previousState: CollectibleSendPreview?
    ) = flow {
        if (senderAccountAddress == receiverAccountAddress) {
            emit(previousState?.copy(showCollectibleAlreadyOwnedErrorEvent = Event(Unit)))
        } else {
            emit(previousState?.copy(checkIfSelectedAccountReceiveCollectibleEvent = Event(Unit)))
        }
    }

    fun checkIfSelectedAccountReceiveCollectible(
        publicKey: String,
        collectibleId: Long,
        previousState: CollectibleSendPreview
    ) = flow<CollectibleSendPreview> {
        emit(previousState.copy(isLoadingVisible = true))
        accountInformationUseCase.getAccountInformation(publicKey).collect {
            it.useSuspended(
                onSuccess = { accountInformation ->
                    val isReceiverOptedInToAsset = accountInformation.hasAsset(collectibleId)
                    if (isReceiverOptedInToAsset) {
                        emit(previousState.copy(navigateToApprovalBottomSheetEvent = Event(Unit)))
                    } else {
                        emit(previousState.copy(navigateToOptInEvent = Event(Unit)))
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
        }
    }

    suspend fun sendSignedTransaction(
        signedTransactionDetail: SignedTransactionDetail.Send,
        previousState: CollectibleSendPreview
    ): Flow<CollectibleSendPreview> {
        return sendSignedTransactionUseCase.sendSignedTransaction(signedTransactionDetail).map { dataResource ->
            when (dataResource) {
                is DataResource.Success -> {
                    addAssetSendingToAccountCache(
                        publicKey = signedTransactionDetail.senderAccountAddress,
                        assetId = signedTransactionDetail.assetInformation.assetId
                    )
                    getTransactionSentSuccessPreview(previousState)
                }
                is DataResource.Error -> getTransactionSentFailedPreview(dataResource, previousState)
                is DataResource.Loading -> previousState.copy(isLoadingVisible = true)
            }
        }
    }

    suspend fun sendSignedGroupTransaction(
        signedTransactionDetail: SignedTransactionDetail.Group,
        previousState: CollectibleSendPreview
    ): Flow<CollectibleSendPreview> {
        return sendSignedTransactionUseCase.sendSignedTransaction(signedTransactionDetail).map { dataResource ->
            when (dataResource) {
                is DataResource.Success -> {
                    val sendTransaction = getSendTransactionInGroupIfExists(signedTransactionDetail)
                    sendTransaction?.let {
                        addAssetSendingToAccountCache(
                            publicKey = it.senderAccountAddress,
                            assetId = it.assetInformation.assetId
                        )
                    }
                    getTransactionSentSuccessPreview(previousState)
                }
                is DataResource.Error -> getTransactionSentFailedPreview(dataResource, previousState)
                else -> previousState.copy(isLoadingVisible = true)
            }
        }
    }

    private fun getSendTransactionInGroupIfExists(
        signedTransactionDetail: SignedTransactionDetail.Group
    ): SignedTransactionDetail.Send? {
        return signedTransactionDetail.transactions?.firstOrNull {
            it is SignedTransactionDetail.Send
        } as? SignedTransactionDetail.Send
    }

    private suspend fun addAssetSendingToAccountCache(publicKey: String, assetId: Long) {
        val cachedAccountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)?.data ?: return
        cachedAccountDetail.accountInformation.setAssetHoldingStatus(assetId, AssetStatus.PENDING_FOR_SENDING)
        accountDetailUseCase.cacheAccountDetail(CacheResult.Success.create(cachedAccountDetail))
    }

    private fun getTransactionSentSuccessPreview(previousState: CollectibleSendPreview): CollectibleSendPreview {
        return previousState.copy(
            navigateToTransactionCompletedEvent = Event(Unit),
            isLoadingVisible = false
        )
    }

    private fun getTransactionSentFailedPreview(
        dataResource: DataResource.Error<String>,
        previousState: CollectibleSendPreview
    ): CollectibleSendPreview {
        return with(dataResource) {
            if ((code ?: -1) >= java.net.HttpURLConnection.HTTP_INTERNAL_ERROR || exception is IOException) {
                previousState.copy(
                    showNetworkErrorEvent = Event(Unit),
                    isLoadingVisible = false
                )
            } else {
                val errorMessage = (this as? DataResource.Error)?.exception?.message.orEmpty()
                previousState.copy(
                    globalErrorTextEvent = Event(errorMessage),
                    isLoadingVisible = false
                )
            }
        }
    }
}
