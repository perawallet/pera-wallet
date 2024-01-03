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

package com.algorand.android.modules.accountdetail.removeaccount.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.modules.accountdetail.removeaccount.ui.mapper.RemoveAccountConfirmationPreviewMapper
import com.algorand.android.modules.accountdetail.removeaccount.ui.model.RemoveAccountConfirmationPreview
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject

class RemoveAccountConfirmationPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val removeAccountConfirmationPreviewMapper: RemoveAccountConfirmationPreviewMapper,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase
) {

    fun getRemoveAccountConfirmationPreview(): RemoveAccountConfirmationPreview {
        return removeAccountConfirmationPreviewMapper.mapToRemoveAccountConfirmationPreview()
    }

    fun getDescriptionResId(accountAddress: String): Int {
        return when (accountDetailUseCase.getAccountType(accountAddress)) {
            Account.Type.STANDARD, Account.Type.LEDGER, Account.Type.REKEYED, Account.Type.REKEYED_AUTH -> {
                R.string.you_are_about_to_remove_account
            }

            Account.Type.WATCH -> R.string.you_are_about_to_remove_watch_account
            else -> R.string.you_are_about_to_remove_account
        }
    }

    fun updatePreviewWithRemoveAccountConfirmation(
        preview: RemoveAccountConfirmationPreview,
        accountAddress: String
    ): RemoveAccountConfirmationPreview {
        val accountType = accountDetailUseCase.getAccountType(accountAddress)
        if (accountType == Account.Type.WATCH) {
            return preview.copy(navBackEvent = Event(true))
        }

        val hasAccountAnyRekeyedAccount = accountDetailUseCase.hasAccountAnyRekeyedAccount(accountAddress)
        if (!hasAccountAnyRekeyedAccount) {
            return preview.copy(navBackEvent = Event(true))
        }

        val rekeyedAccountAddresses = accountDetailUseCase.getRekeyedAccountAddresses(accountAddress)

        return preview.copy(
            showGlobalErrorEvent = Event(
                PluralAnnotatedString(
                    pluralStringResId = R.plurals.you_can_t_remove_this_account,
                    quantity = rekeyedAccountAddresses.count()
                )
            ),
            navBackEvent = Event(false)
        )
    }
}
