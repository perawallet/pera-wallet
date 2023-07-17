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

package com.algorand.android.modules.rekey.rekeytoledgeraccount.confirmation.ui.usecase

import com.algorand.android.R
import com.algorand.android.mapper.AccountDisplayNameMapper
import com.algorand.android.models.Account
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.accounticon.ui.mapper.AccountIconDrawablePreviewMapper
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.rekey.domain.usecase.SendSignedTransactionUseCase
import com.algorand.android.modules.rekey.rekeytoledgeraccount.confirmation.ui.decider.RekeyToLedgerAccountConfirmationPreviewDecider
import com.algorand.android.modules.rekey.rekeytoledgeraccount.confirmation.ui.mapper.RekeyToLedgerAccountConfirmationPreviewMapper
import com.algorand.android.modules.rekey.rekeytoledgeraccount.confirmation.ui.model.RekeyToLedgerAccountConfirmationPreview
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountAdditionUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.Event
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.calculateRekeyFee
import com.algorand.android.utils.emptyString
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.toShortenedAddress
import kotlinx.coroutines.flow.flow
import javax.inject.Inject

@SuppressWarnings("LongParameterList")
class RekeyToLedgerAccountConfirmationPreviewUseCase @Inject constructor(
    private val rekeyToLedgerAccountConfirmationPreviewMapper: RekeyToLedgerAccountConfirmationPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val transactionsRepository: TransactionsRepository,
    private val accountAdditionUseCase: AccountAdditionUseCase,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    private val rekeyToLedgerAccountConfirmationPreviewDecider: RekeyToLedgerAccountConfirmationPreviewDecider,
    private val accountDisplayNameMapper: AccountDisplayNameMapper,
    private val accountIconDrawablePreviewMapper: AccountIconDrawablePreviewMapper
) {

    fun getInitialRekeyToStandardAccountConfirmationPreview(
        accountAddress: String,
        authAccountAddress: String
    ): RekeyToLedgerAccountConfirmationPreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data
        val accountDisplayName = accountDisplayNameUseCase.invoke(accountAddress)
        val accountIconResource = createAccountIconDrawableUseCase.invoke(accountAddress)
        val (authAccountDisplayName, authAccountIconResource) = createAccountDisplayNameAndDrawablePair(
            accountAddress = authAccountAddress
        )
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

        return rekeyToLedgerAccountConfirmationPreviewMapper.mapToRekeyToLedgerAccountConfirmationPreview(
            isLoading = false,
            descriptionAnnotatedString = rekeyToLedgerAccountConfirmationPreviewDecider
                .decideDescriptionAnnotatedString(accountDetail = accountDetail),
            rekeyedAccountDisplayName = accountDisplayName,
            rekeyedAccountIconResource = accountIconResource,
            authAccountDisplayName = authAccountDisplayName,
            authAccountIconResource = authAccountIconResource,
            currentlyRekeyedAccountDisplayName = currentlyRekeyedAccountDisplayName,
            currentlyRekeyedAccountIconDrawable = currentlyRekeyAccountIconDrawable,
            formattedTransactionFee = emptyString(),
            titleTextResId = R.string.confirm_rekeying,
            subtitleTextResId = R.string.summary_of_rekey
        )
    }

    suspend fun updatePreviewWithTransactionFee(preview: RekeyToLedgerAccountConfirmationPreview) = flow {
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

    fun sendRekeyToLedgerAccountTransaction(
        preview: RekeyToLedgerAccountConfirmationPreview,
        transactionDetail: SignedTransactionDetail.RekeyOperation
    ) = flow {
        emit(preview.copy(isLoading = true))
        sendSignedTransactionUseCase.invoke(transactionDetail).useSuspended(
            onSuccess = {
                val tempAccount = with(transactionDetail) {
                    createRekeyedAuthAccount(
                        accountDetail = accountDetail,
                        rekeyAdminAddress = rekeyAdminAddress,
                        ledgerDetail = ledgerDetail,
                        accountAddress = accountAddress,
                        rekeyedAccountDetail = rekeyedAccountDetail,
                        accountName = accountName
                    )
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

    fun createRekeyToLedgerAccountTransaction(
        accountAddress: String,
        authAccountAddress: String,
        ledgerDetail: Account.Detail.Ledger
    ): TransactionData.Rekey? {
        val senderAccountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data ?: return null
        return TransactionData.Rekey(
            senderAccountAddress = senderAccountDetail.account.address,
            senderAccountDetail = senderAccountDetail.account.detail,
            senderAccountType = senderAccountDetail.account.type,
            senderAuthAddress = senderAccountDetail.accountInformation.rekeyAdminAddress,
            senderAccountName = senderAccountDetail.account.name,
            isSenderRekeyedToAnotherAccount = senderAccountDetail.accountInformation.isRekeyed(),
            rekeyAdminAddress = authAccountAddress,
            ledgerDetail = ledgerDetail,
            senderAccountAuthTypeAndDetail = senderAccountDetail.account.getAuthTypeAndDetail()
        )
    }

    fun updatePreviewWithLoadingState(
        preview: RekeyToLedgerAccountConfirmationPreview
    ): RekeyToLedgerAccountConfirmationPreview {
        return preview.copy(isLoading = true)
    }

    fun updatePreviewWithClearLoadingState(
        preview: RekeyToLedgerAccountConfirmationPreview
    ): RekeyToLedgerAccountConfirmationPreview {
        return preview.copy(isLoading = false)
    }

    fun updatePreviewWithRekeyConfirmationClick(
        accountAddress: String,
        preview: RekeyToLedgerAccountConfirmationPreview
    ): RekeyToLedgerAccountConfirmationPreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data ?: return preview
        return if (accountDetail.accountInformation.isRekeyed()) {
            preview.copy(navToRekeyedAccountConfirmationBottomSheetEvent = Event(Unit))
        } else {
            preview.copy(onSendTransactionEvent = Event(Unit))
        }
    }

    private fun createRekeyedAuthAccount(
        accountDetail: Account.Detail?,
        rekeyAdminAddress: String,
        ledgerDetail: Account.Detail.Ledger,
        accountAddress: String,
        rekeyedAccountDetail: Account.Detail?,
        accountName: String
    ): Account {
        val newRekeyedAuthDetailMap = mutableMapOf<String, Account.Detail.Ledger>().apply {
            if (accountDetail is Account.Detail.RekeyedAuth) {
                putAll(accountDetail.rekeyedAuthDetail)
            }
            put(rekeyAdminAddress, ledgerDetail)
        }
        val accountSecretKey = accountDetailUseCase.getCachedAccountSecretKey(accountAddress)
        return Account.create(
            publicKey = accountAddress,
            detail = Account.Detail.RekeyedAuth.create(
                authDetail = rekeyedAccountDetail,
                rekeyedAuthDetail = newRekeyedAuthDetailMap,
                secretKey = accountSecretKey
            ),
            accountName = accountName
        )
    }

    private fun createAccountDisplayNameAndDrawablePair(
        accountAddress: String
    ): Pair<AccountDisplayName, AccountIconDrawablePreview> {
        val isThereAnyAccountWithAddress = accountDetailUseCase.isThereAnyAccountWithPublicKey(accountAddress)
        return if (isThereAnyAccountWithAddress) {
            val accountDisplayName = accountDisplayNameUseCase.invoke(accountAddress)
            val accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(accountAddress)
            accountDisplayName to accountIconDrawablePreview
        } else {
            val accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                accountAddress = accountAddress,
                accountName = accountAddress.toShortenedAddress(),
                nfDomainName = null,
                type = Account.Type.LEDGER
            )
            val accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                backgroundColorResId = R.color.wallet_3,
                iconTintResId = R.color.wallet_3_icon,
                iconResId = R.drawable.ic_ledger
            )
            accountDisplayName to accountIconDrawablePreview
        }
    }
}
