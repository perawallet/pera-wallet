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
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.rekey.domain.usecase.SendSignedTransactionUseCase
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.decider.RekeyToStandardAccountPreviewDecider
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.mapper.RekeyToStandardAccountConfirmationPreviewMapper
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.model.RekeyToStandardAccountConfirmationPreview
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountAdditionUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.calculateRekeyFee
import com.algorand.android.utils.emptyString
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsAlgoString
import kotlinx.coroutines.flow.flow
import javax.inject.Inject

class RekeyToStandardAccountConfirmationPreviewUseCase @Inject constructor(
    private val rekeyToStandardAccountConfirmationPreviewMapper: RekeyToStandardAccountConfirmationPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val transactionsRepository: TransactionsRepository,
    private val accountAdditionUseCase: AccountAdditionUseCase,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    private val rekeyToStandardAccountPreviewDecider: RekeyToStandardAccountPreviewDecider
) {

    fun sendRekeyToStandardAccountTransaction(
        preview: RekeyToStandardAccountConfirmationPreview,
        transactionDetail: SignedTransactionDetail.RekeyToStandardAccountOperation
    ) = flow {
        emit(preview.copy(isLoading = true))
        sendSignedTransactionUseCase.invoke(transactionDetail).useSuspended(
            onSuccess = {
                val rekeyedAccount = createAccountRegardingByRekeyType(
                    accountAddress = transactionDetail.accountAddress,
                    accountName = transactionDetail.accountName
                )
                accountAdditionUseCase.addNewAccount(tempAccount = rekeyedAccount, creationType = CreationType.REKEYED)
                emit(
                    preview.copy(
                        isLoading = false,
                        navToRekeyResultInfoFragmentEvent = Event(Unit)
                    )
                )
            },
            onFailed = {
                val title = R.string.error
                val description = it.exception?.message.orEmpty()
                emit(preview.copy(showGlobalErrorEvent = Event(title to description), isLoading = false))
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
        val accountDisplayName = accountDisplayNameUseCase.invoke(accountAddress)

        val authAccountDisplayName = accountDisplayNameUseCase.invoke(authAccountAddress)

        val currentlyRekeyedAccountDisplayName = if (accountDetail?.accountInformation?.isRekeyed() == true) {
            accountDisplayNameUseCase.invoke(accountDetail.accountInformation.rekeyAdminAddress.orEmpty())
        } else {
            null
        }
        val currentlyRekeyAccountIconDrawable = if (accountDetail?.accountInformation?.isRekeyed() == true) {
            createAccountIconDrawableUseCase.invoke(accountDetail.accountInformation.rekeyAdminAddress.orEmpty())
        } else {
            null
        }

        return rekeyToStandardAccountConfirmationPreviewMapper.mapToRekeyToStandardAccountConfirmationPreview(
            isLoading = false,
            descriptionAnnotatedString = rekeyToStandardAccountPreviewDecider.decideDescriptionAnnotatedString(
                accountDetail = accountDetail
            ),
            rekeyedAccountDisplayName = accountDisplayName,
            rekeyedAccountIconResource = createAccountIconDrawableUseCase.invoke(accountAddress),
            authAccountDisplayName = authAccountDisplayName,
            authAccountIconResource = createAccountIconDrawableUseCase.invoke(authAccountAddress),
            currentlyRekeyedAccountDisplayName = currentlyRekeyedAccountDisplayName,
            currentlyRekeyedAccountIconDrawable = currentlyRekeyAccountIconDrawable,
            formattedTransactionFee = emptyString(),
            titleTextResId = R.string.confirm_rekeying,
            subtitleTextResId = R.string.summary_of_rekey
        )
    }

    suspend fun updatePreviewWithTransactionFee(preview: RekeyToStandardAccountConfirmationPreview) = flow {
        transactionsRepository.getTransactionParams().use(
            onSuccess = { params ->
                val calculatedFee = calculateRekeyFee(params.fee, params.minFee)
                val formattedFee = calculatedFee.formatAsAlgoString().formatAsAlgoAmount()
                emit(preview.copy(formattedTransactionFee = formattedFee))
            },
            onFailed = { _, _ ->
                val formattedFee = MIN_FEE.formatAsAlgoString().formatAsAlgoAmount()
                emit(preview.copy(formattedTransactionFee = formattedFee))
            }
        )
    }

    fun updatePreviewWithLoadingState(
        preview: RekeyToStandardAccountConfirmationPreview
    ): RekeyToStandardAccountConfirmationPreview {
        return preview.copy(isLoading = true)
    }

    fun updatePreviewWithClearLoadingState(
        preview: RekeyToStandardAccountConfirmationPreview
    ): RekeyToStandardAccountConfirmationPreview {
        return preview.copy(isLoading = false)
    }

    fun updatePreviewWithRekeyConfirmationClick(
        accountAddress: String,
        preview: RekeyToStandardAccountConfirmationPreview
    ): RekeyToStandardAccountConfirmationPreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data ?: return preview
        return if (accountDetail.accountInformation.isRekeyed()) {
            preview.copy(navToRekeyedAccountConfirmationBottomSheetEvent = Event(Unit))
        } else {
            preview.copy(onSendTransactionEvent = Event(Unit))
        }
    }

    private fun createAccountRegardingByRekeyType(accountAddress: String, accountName: String): Account {
        val accountSecretKey = accountDetailUseCase.getCachedAccountDetail(accountAddress)
            ?.data
            ?.account
            ?.getSecretKey()
        val detail = Account.Detail.Rekeyed(accountSecretKey)
        return Account.create(
            publicKey = accountAddress,
            detail = detail,
            accountName = accountName
        )
    }
}
