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

import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.nft.mapper.CollectibleDetailPreviewMapper
import com.algorand.android.nft.ui.model.CollectibleDetail
import com.algorand.android.nft.ui.model.CollectibleDetailPreview
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

@SuppressWarnings("LongParameterList")
open class CollectibleDetailPreviewUseCase @Inject constructor(
    private val collectibleDetailPreviewMapper: CollectibleDetailPreviewMapper,
    private val accountAddressUseCase: AccountAddressUseCase,
    private val collectibleDetailItemUseCase: CollectibleDetailItemUseCase
) {
    suspend fun getCollectibleDetailPreviewFlow(collectibleAssetId: Long, selectedAccountAddress: String) = flow {
        emit(collectibleDetailPreviewMapper.mapToLoading())
        collectibleDetailItemUseCase.getCollectibleDetailItemFlow(
            collectibleAssetId = collectibleAssetId,
            selectedAccountAddress = selectedAccountAddress
        ).collect {
            it.useSuspended(
                onSuccess = { collectibleDetail ->
                    emit(createCollectibleDetailPreviewWithCollectibleDetail(collectibleDetail = collectibleDetail))
                },
                onFailed = {
                    // TODO Show error
                }
            )
        }
    }

    @SuppressWarnings("LongMethod")
    private fun createCollectibleDetailPreviewWithCollectibleDetail(
        collectibleDetail: CollectibleDetail
    ): CollectibleDetailPreview {
        // TODO: 4.03.2022 Is error display text correct?
        val isOptOutButtonVisible = !collectibleDetail.isOwnedByTheUser &&
            !collectibleDetail.isHoldingByWatchAccount &&
            collectibleDetail.creatorWalletAddress != collectibleDetail.ownerAccountAddress

        return collectibleDetailPreviewMapper.mapTo(
            isLoadingVisible = false,
            isSendButtonVisible = collectibleDetail.isOwnedByTheUser,
            isErrorVisible = false,
            collectibleDetail = collectibleDetail,
            isOptOutButtonVisible = isOptOutButtonVisible
        )
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
