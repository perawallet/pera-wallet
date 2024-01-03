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

package com.algorand.android.modules.rekey.undorekey.confirmation.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountOriginalStateIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.rekey.domain.usecase.SendSignedTransactionUseCase
import com.algorand.android.modules.rekey.undorekey.confirmation.ui.mapper.UndoRekeyConfirmationPreviewMapper
import com.algorand.android.modules.rekey.undorekey.confirmation.ui.model.UndoRekeyConfirmationPreview
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
import com.algorand.android.utils.recordException
import kotlinx.coroutines.flow.flow
import javax.inject.Inject

class UndoRekeyConfirmationPreviewUseCase @Inject constructor(
    private val undoRekeyConfirmationPreviewMapper: UndoRekeyConfirmationPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val transactionsRepository: TransactionsRepository,
    private val accountAdditionUseCase: AccountAdditionUseCase,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    private val createAccountOriginalStateIconDrawableUseCase: CreateAccountOriginalStateIconDrawableUseCase,
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    fun getInitialUndoRekeyConfirmationPreview(accountAddress: String): UndoRekeyConfirmationPreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data
        val accountDisplayName = accountDisplayNameUseCase.invoke(accountAddress)

        val authAccountAddress = accountDetail?.accountInformation?.rekeyAdminAddress.orEmpty()
        val authAccountDisplayName = accountDisplayNameUseCase.invoke(authAccountAddress)
        val authAccountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(authAccountAddress)

        return undoRekeyConfirmationPreviewMapper.mapToUndoRekeyConfirmationPreview(
            isLoading = false,
            descriptionAnnotatedString = AnnotatedString(stringResId = R.string.you_are_about_to_undo_this),
            rekeyedAccountDisplayName = accountDisplayName,
            rekeyedAccountIconResource = createAccountIconDrawableUseCase.invoke(accountAddress),
            authAccountDisplayName = accountDisplayName,
            authAccountIconResource = createAccountOriginalStateIconDrawableUseCase.invoke(accountAddress),
            currentlyRekeyedAccountDisplayName = authAccountDisplayName,
            currentlyRekeyedAccountIconDrawable = authAccountIconDrawablePreview,
            formattedTransactionFee = emptyString(),
            titleTextResId = R.string.undo_rekey,
            subtitleTextResId = R.string.undo_rekey
        )
    }

    suspend fun updatePreviewWithTransactionFee(preview: UndoRekeyConfirmationPreview) = flow {
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

    fun sendUndoRekeyTransaction(
        preview: UndoRekeyConfirmationPreview,
        transactionDetail: SignedTransactionDetail
    ) = flow {
        emit(preview.copy(isLoading = true))
        sendSignedTransactionUseCase.invoke(transactionDetail).useSuspended(
            onSuccess = {
                val tempAccount = createRekeyedAccount(transactionDetail)
                if (tempAccount == null) {
                    emit(preview.copy(isLoading = false))
                    return@useSuspended
                }
                accountAdditionUseCase.addNewAccount(
                    tempAccount = tempAccount,
                    creationType = CreationType.REKEYED
                )
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

    fun createUndoRekeyTransaction(accountAddress: String): TransactionData? {
        val account = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data?.account ?: return null
        return when (account.type) {
            Account.Type.STANDARD, Account.Type.LEDGER, Account.Type.WATCH, null -> null
            Account.Type.REKEYED -> createRekeyToStandardAccountTransaction(accountAddress)
            Account.Type.REKEYED_AUTH -> {
                val hasAccountValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasAccountValidSecretKey) {
                    createRekeyToStandardAccountTransaction(accountAddress)
                } else {
                    createRekeyTransaction(accountAddress) ?: createRekeyToStandardAccountTransaction(accountAddress)
                }
            }
        }
    }

    fun updatePreviewWithLoadingState(preview: UndoRekeyConfirmationPreview): UndoRekeyConfirmationPreview {
        return preview.copy(isLoading = true)
    }

    fun updatePreviewWithClearLoadingState(preview: UndoRekeyConfirmationPreview): UndoRekeyConfirmationPreview {
        return preview.copy(isLoading = false)
    }

    fun updatePreviewWithRekeyConfirmationClick(
        accountAddress: String,
        preview: UndoRekeyConfirmationPreview
    ): UndoRekeyConfirmationPreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data ?: return preview
        return if (accountDetail.accountInformation.isRekeyed()) {
            preview.copy(navToRekeyedAccountConfirmationBottomSheetEvent = Event(Unit))
        } else {
            preview.copy(onSendTransactionEvent = Event(Unit))
        }
    }

    fun getAccountAuthAddress(accountAddress: String): String {
        return accountDetailUseCase.getAuthAddress(accountAddress).orEmpty()
    }

    private fun createRekeyedAccount(signedTransactionDetail: SignedTransactionDetail): Account? {
        return when (signedTransactionDetail) {
            is SignedTransactionDetail.AssetOperation,
            is SignedTransactionDetail.ExternalTransaction,
            is SignedTransactionDetail.Group,
            is SignedTransactionDetail.Send -> null

            is SignedTransactionDetail.RekeyOperation -> createStandardAccount(signedTransactionDetail)
            is SignedTransactionDetail.RekeyToStandardAccountOperation -> createStandardAccount(signedTransactionDetail)
        }
    }

    private fun createStandardAccount(signedTransactionDetail: SignedTransactionDetail.RekeyOperation): Account {
        val accountAddress = signedTransactionDetail.accountAddress
        val accountName = signedTransactionDetail.accountName
        val accountSecretKey = accountDetailUseCase.getCachedAccountDetail(accountAddress)
            ?.data
            ?.account
            ?.getSecretKey()
        if (accountSecretKey == null) {
            recordException(IllegalArgumentException("IMPORTANT! Account secret key is null in $className"))
        }
        return Account.create(
            publicKey = accountAddress,
            detail = Account.Detail.Standard(accountSecretKey ?: byteArrayOf()),
            accountName = accountName
        )
    }

    private fun createStandardAccount(
        signedTransactionDetail: SignedTransactionDetail.RekeyToStandardAccountOperation
    ): Account {
        val accountAddress = signedTransactionDetail.accountAddress
        val accountName = signedTransactionDetail.accountName
        val accountSecretKey = accountDetailUseCase.getCachedAccountDetail(accountAddress)
            ?.data
            ?.account
            ?.getSecretKey()
        return Account.create(
            publicKey = accountAddress,
            detail = Account.Detail.Standard(accountSecretKey ?: byteArrayOf()),
            accountName = accountName
        )
    }

    private fun createRekeyTransaction(accountAddress: String): TransactionData.Rekey? {
        val senderAccountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data ?: return null
        val senderAccountAccountDetail = senderAccountDetail.account.detail
        if (senderAccountAccountDetail !is Account.Detail.RekeyedAuth) {
            return null
        }
        val authAccountAddress = senderAccountDetail.accountInformation.rekeyAdminAddress.orEmpty()
        val ledgerDetail = senderAccountAccountDetail.rekeyedAuthDetail[authAccountAddress] ?: return null
        return TransactionData.Rekey(
            senderAccountAddress = senderAccountDetail.account.address,
            senderAccountDetail = senderAccountDetail.account.detail,
            senderAccountType = senderAccountDetail.account.type,
            senderAuthAddress = senderAccountDetail.accountInformation.rekeyAdminAddress,
            senderAccountName = senderAccountDetail.account.name,
            isSenderRekeyedToAnotherAccount = senderAccountDetail.accountInformation.isRekeyed(),
            rekeyAdminAddress = accountAddress,
            ledgerDetail = ledgerDetail,
            senderAccountAuthTypeAndDetail = senderAccountDetail.account.getAuthTypeAndDetail()
        )
    }

    private fun createRekeyToStandardAccountTransaction(
        accountAddress: String
    ): TransactionData.RekeyToStandardAccount? {
        val senderAccountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data ?: return null
        return TransactionData.RekeyToStandardAccount(
            senderAccountAddress = senderAccountDetail.account.address,
            senderAccountDetail = senderAccountDetail.account.detail,
            senderAccountType = senderAccountDetail.account.type,
            senderAuthAddress = senderAccountDetail.accountInformation.rekeyAdminAddress,
            senderAccountName = senderAccountDetail.account.name,
            isSenderRekeyedToAnotherAccount = senderAccountDetail.accountInformation.isRekeyed(),
            rekeyAdminAddress = accountAddress,
            senderAccountAuthTypeAndDetail = senderAccountDetail.account.getAuthTypeAndDetail()
        )
    }

    companion object {
        private val className = UndoRekeyConfirmationPreviewUseCase::class.java.simpleName
    }
}
