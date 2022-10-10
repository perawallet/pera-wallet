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

import com.algorand.android.models.Account
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TrackTransactionRequest
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.algorand.android.utils.analytics.logTransactionEvent
import com.algorand.android.utils.exception.AccountAlreadyOptedIntoAssetException
import com.google.firebase.analytics.FirebaseAnalytics
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class SendSignedTransactionUseCase @Inject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val algodInterceptor: AlgodInterceptor,
    private val firebaseAnalytics: FirebaseAnalytics,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetAdditionUseCase: AssetAdditionUseCase,
    private val accountAssetRemovalUseCase: AccountAssetRemovalUseCase
) {

    suspend fun sendSignedTransaction(
        signedTransactionDetail: SignedTransactionDetail,
        shouldLogTransaction: Boolean = true
    ) = flow<DataResource<String>> {
        emit(DataResource.Loading())
        if (
            signedTransactionDetail is SignedTransactionDetail.AssetOperation.AssetAddition &&
            isAccountAlreadyOptedIntoAsset(signedTransactionDetail)
        ) {
            emit(DataResource.Error.Local(AccountAlreadyOptedIntoAssetException()))
        } else {
            transactionsRepository.sendSignedTransaction(signedTransactionDetail.signedTransactionData).use(
                onSuccess = { sendTransactionResponse ->
                    sendTransactionResponse.taxId?.let { transactionId ->
                        transactionsRepository.postTrackTransaction(TrackTransactionRequest(transactionId))
                        if (shouldLogTransaction && signedTransactionDetail is SignedTransactionDetail.Send) {
                            logTransactionEvent(signedTransactionDetail, transactionId)
                        }
                    }
                    cacheAssetIfAssetOperationTransaction(signedTransactionDetail)
                    emit(DataResource.Success(sendTransactionResponse.taxId.orEmpty()))
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api(exception, code))
                }
            )
        }
    }

    private fun logTransactionEvent(signedTransactionDetail: SignedTransactionDetail.Send, taxId: String?) {
        if (algodInterceptor.currentActiveNode?.networkSlug == MAINNET_NETWORK_SLUG) {
            with(signedTransactionDetail) {
                firebaseAnalytics.logTransactionEvent(
                    amount = amount,
                    assetId = assetInformation.assetId,
                    accountType = accountCacheData.account.type ?: Account.Type.STANDARD,
                    isMax = isMax,
                    transactionId = taxId
                )
            }
        }
    }

    private fun isAccountAlreadyOptedIntoAsset(
        transaction: SignedTransactionDetail.AssetOperation.AssetAddition
    ): Boolean {
        return accountDetailUseCase.isAssetOwnedByAccount(
            publicKey = transaction.accountCacheData.account.address,
            assetId = transaction.assetInformation.assetId
        )
    }

    private suspend fun cacheAssetIfAssetOperationTransaction(signedTransactionDetail: SignedTransactionDetail) {
        when (signedTransactionDetail) {
            is SignedTransactionDetail.AssetOperation.AssetAddition -> {
                assetAdditionUseCase.addAssetAdditionToAccountCache(
                    publicKey = signedTransactionDetail.accountCacheData.account.address,
                    assetInformation = signedTransactionDetail.assetInformation
                )
            }
            is SignedTransactionDetail.AssetOperation.AssetRemoval -> {
                accountAssetRemovalUseCase.addAssetDeletionToAccountCache(
                    publicKey = signedTransactionDetail.accountCacheData.account.address,
                    assetId = signedTransactionDetail.assetInformation.assetId
                )
            }
            else -> Unit
        }
    }
}
