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

package com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.Account.Type.STANDARD
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.mapper.RekeyToStandardAccountConfirmationPreviewMapper
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.model.RekeyToStandardAccountConfirmationPreview
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountAdditionUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject
import kotlin.math.max
import kotlinx.coroutines.flow.flow

class RekeyToStandardAccountConfirmationPreviewUseCase @Inject constructor(
    private val rekeyToStandardAccountConfirmationPreviewMapper: RekeyToStandardAccountConfirmationPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val transactionsRepository: TransactionsRepository,
    private val accountAdditionUseCase: AccountAdditionUseCase,
) {

    suspend fun sendRekeyToStandardAccountTransaction(
        preview: RekeyToStandardAccountConfirmationPreview,
        transactionDetail: SignedTransactionDetail.RekeyToStandardAccountOperation
    ) = flow {
        emit(preview.copy(isLoading = true))
        transactionsRepository.sendSignedTransaction(transactionDetail.signedTransactionData).use(
            onSuccess = {
                val accountSecretKey = accountDetailUseCase.getCachedAccountDetail(transactionDetail.accountAddress)
                    ?.data
                    ?.account
                    ?.getSecretKey()

                val rekeyedAccount = Account.create(
                    publicKey = transactionDetail.accountAddress,
                    detail = Account.Detail.Rekeyed(accountSecretKey),
                    accountName = transactionDetail.accountName
                )
                emit(
                    preview.copy(
                        isLoading = false,
                        navToRekeyToStandardAccountVerifyFragmentEvent = Event(Unit)
                    )
                )
                // TODO: There is a bug which solved in per-3138.
                //  For the further context, you can take a look at PR description
                //  https://github.com/Hipo/algorand-android/pull/1897
                accountAdditionUseCase.addNewAccount(
                    tempAccount = rekeyedAccount,
                    creationType = CreationType.REKEYED
                )
            },
            onFailed = { exception, _ ->
                emit(preview.copy(showGlobalErrorEvent = Event(exception.message.orEmpty())))
            }
        )
    }

    fun createRekeyToStandardAccountTransaction(
        accountAddress: String,
        authAccountAddress: String
    ): TransactionData.RekeyToStandardAccount? {
        val senderAccountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data ?: return null
        return TransactionData.RekeyToStandardAccount(
            senderAccountAddress = senderAccountDetail.account.address,
            senderAccountDetail = senderAccountDetail.account.detail,
            senderAccountType = senderAccountDetail.account.type,
            senderAuthAddress = senderAccountDetail.accountInformation.rekeyAdminAddress,
            senderAccountName = senderAccountDetail.account.name,
            isSenderRekeyedToAnotherAccount = senderAccountDetail.accountInformation.isRekeyed(),
            rekeyAdminAddress = authAccountAddress,
            senderAccountAuthTypeAndDetail = senderAccountDetail.account.getAuthTypeAndDetail()
        )
    }

    fun getInitialRekeyToStandardAccountConfirmationPreview(
        accountAddress: String,
        authAccountAddress: String
    ): RekeyToStandardAccountConfirmationPreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data
        val accountType = accountDetail?.account?.type
        val authAccountDetail = accountDetailUseCase.getCachedAccountDetail(authAccountAddress)?.data
        val authAccountType = authAccountDetail?.account?.type

        val oldAccountTypeIconResource = AccountIconResource.getAccountIconResourceByAccountType(accountType)
        val oldAccountTitleTextResId = if (accountType == STANDARD) R.string.passphrase else R.string.old_ledger
        val oldAccountDisplayName = if (accountType == STANDARD) {
            HIDDEN_PASSWORD
        } else {
            accountDetail?.accountInformation?.rekeyAdminAddress.toShortenedAddress()
        }

        val newAccountTypeIconResource = AccountIconResource.getAccountIconResourceByAccountType(authAccountType)
        val newAccountTitleTextResId = R.string.auth_account_address
        val newAccountDisplayName = authAccountAddress.toShortenedAddress()

        return rekeyToStandardAccountConfirmationPreviewMapper.mapToRekeyToStandardAccountConfirmationPreview(
            oldAccountTypeIconResource = oldAccountTypeIconResource,
            oldAccountTitleTextResId = oldAccountTitleTextResId,
            oldAccountDisplayName = oldAccountDisplayName,
            newAccountTypeIconResource = newAccountTypeIconResource,
            newAccountTitleTextResId = newAccountTitleTextResId,
            newAccountDisplayName = newAccountDisplayName,
            isLoading = false
        )
    }

    suspend fun updatePreviewWithTransactionFee(preview: RekeyToStandardAccountConfirmationPreview) = flow {
        transactionsRepository.getTransactionParams().use(
            onSuccess = { params ->
                val calculatedFee = max(REKEY_BYTE_ARRAY_SIZE * params.fee, params.minFee ?: MIN_FEE)
                val formattedFee = calculatedFee.formatAsAlgoString()
                emit(preview.copy(onDisplayCalculatedTransactionFeeEvent = Event(formattedFee)))
            },
            onFailed = { _, _ ->
                val formattedFee = MIN_FEE.formatAsAlgoString()
                emit(preview.copy(onDisplayCalculatedTransactionFeeEvent = Event(formattedFee)))
            }
        )
    }

    companion object {
        private const val HIDDEN_PASSWORD = "*************"
        private const val REKEY_BYTE_ARRAY_SIZE = 30
    }
}
