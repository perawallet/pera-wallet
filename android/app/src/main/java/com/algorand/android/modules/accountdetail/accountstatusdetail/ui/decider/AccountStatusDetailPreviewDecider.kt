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

package com.algorand.android.modules.accountdetail.accountstatusdetail.ui.decider

import android.content.Context
import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

class AccountStatusDetailPreviewDecider @Inject constructor(
    @ApplicationContext private val context: Context,
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    fun decideTitleString(account: Account?): String {
        val typeResId = when (account?.type) {
            Account.Type.LEDGER -> R.string.ledger
            Account.Type.WATCH -> R.string.watch
            Account.Type.STANDARD -> {
                val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasValidSecretKey) R.string.standard else R.string.no_auth
            }
            Account.Type.REKEYED, Account.Type.REKEYED_AUTH, null -> {
                val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account)
                if (hasAccountAuthority) R.string.rekeyed else R.string.no_auth
            }
        }
        val accountTypeString = context.getString(typeResId)
        return context.getString(R.string.account_type_account, accountTypeString)
    }

    fun decideAccountTypeString(account: Account?): String {
        val accountTypeString = when (account?.type) {
            Account.Type.LEDGER -> context.getString(R.string.ledger)
            Account.Type.WATCH -> context.getString(R.string.watch)
            Account.Type.STANDARD -> {
                val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                val accountTypeResId = if (hasValidSecretKey) R.string.standard else R.string.no_auth
                context.getString(accountTypeResId)
            }
            Account.Type.REKEYED -> {
                val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account)
                if (hasAccountAuthority) {
                    val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                    val accountOriginalState = if (hasValidSecretKey) R.string.standard else R.string.unknown
                    val accountStateString = context.getString(R.string.rekeyed)
                    val accountOriginalStateString = context.getString(accountOriginalState)
                    val authAccountState = context.getString(R.string.standard)
                    context.getString(
                        R.string.account_state_transition,
                        accountStateString,
                        accountOriginalStateString,
                        authAccountState
                    )
                } else {
                    context.getString(R.string.no_auth)
                }
            }
            Account.Type.REKEYED_AUTH -> {
                val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account)
                if (hasAccountAuthority) {
                    val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                    val accountOriginalState = if (hasValidSecretKey) R.string.standard else R.string.unknown
                    val accountStateString = context.getString(R.string.rekeyed)
                    val accountOriginalStateString = context.getString(accountOriginalState)
                    val authAccountState = context.getString(R.string.ledger)
                    context.getString(
                        R.string.account_state_transition,
                        accountStateString,
                        accountOriginalStateString,
                        authAccountState
                    )
                } else {
                    context.getString(R.string.no_auth)
                }
            }
            null -> context.getString(R.string.no_auth)
        }
        return accountTypeString
    }

    fun decideDescriptionAnnotatedString(account: Account?): AnnotatedString {
        val descriptionStringResId = when (account?.type) {
            Account.Type.LEDGER -> R.string.your_account_is_a_Ledger
            Account.Type.WATCH -> R.string.this_account_was_not
            Account.Type.STANDARD -> {
                val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasValidSecretKey) R.string.your_account_is_a_standard else R.string.your_account_doesn_t
            }
            Account.Type.REKEYED -> {
                val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account)
                if (hasAccountAuthority) {
                    val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                    if (hasValidSecretKey) {
                        R.string.your_account_is_rekeyed_to_another
                    } else {
                        R.string.no_record_of_original_account
                    }
                } else {
                    R.string.your_account_is_rekeyed_to_an
                }
            }
            Account.Type.REKEYED_AUTH, null -> {
                val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account)
                if (hasAccountAuthority) {
                    val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                    if (hasValidSecretKey) {
                        R.string.your_account_is_rekeyed_to_an_account_on
                    } else {
                        R.string.no_record_of_original_account_type
                    }
                } else {
                    R.string.your_account_is_rekeyed_to_an
                }
            }
        }
        return AnnotatedString(descriptionStringResId)
    }

    fun decideAuthAccountActionButtonState(account: Account?): AccountAssetItemButtonState? {
        return when (account?.type) {
            Account.Type.LEDGER, Account.Type.WATCH -> null
            Account.Type.STANDARD -> {
                val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasValidSecretKey) null else AccountAssetItemButtonState.WARNING
            }
            Account.Type.REKEYED, Account.Type.REKEYED_AUTH, null -> {
                val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account)
                if (hasAccountAuthority) AccountAssetItemButtonState.UNDO_REKEY else AccountAssetItemButtonState.WARNING
            }
        }
    }
}
