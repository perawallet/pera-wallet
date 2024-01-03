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

package com.algorand.android.modules.accounticon.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.accounticon.ui.mapper.AccountIconDrawablePreviewMapper
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject

class CreateAccountOriginalStateIconDrawableUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountIconDrawablePreviewMapper: AccountIconDrawablePreviewMapper,
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    operator fun invoke(accountAddress: String): AccountIconDrawablePreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data
        val accountIconResId = getAccountIconResId(accountDetail?.account)
        val accountIconTintResId = getAccountIconTintResId(accountDetail?.account)
        val accountIconBackgroundColorResId = getAccountIconBackgroundColorResId(accountDetail?.account)
        return accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
            backgroundColorResId = accountIconBackgroundColorResId,
            iconResId = accountIconResId,
            iconTintResId = accountIconTintResId
        )
    }

    private fun getAccountIconBackgroundColorResId(account: Account?): Int {
        return when (account?.type) {
            Account.Type.LEDGER -> AccountIconResource.LEDGER.backgroundColorResId
            Account.Type.WATCH -> AccountIconResource.WATCH.backgroundColorResId
            Account.Type.STANDARD, Account.Type.REKEYED_AUTH, Account.Type.REKEYED, null -> {
                val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasValidSecretKey) AccountIconResource.STANDARD.backgroundColorResId else R.color.layer_gray_lighter
            }
        }
    }

    private fun getAccountIconTintResId(account: Account?): Int {
        return when (account?.type) {
            Account.Type.LEDGER -> AccountIconResource.LEDGER.iconTintResId
            Account.Type.WATCH -> AccountIconResource.WATCH.iconTintResId
            Account.Type.STANDARD, Account.Type.REKEYED_AUTH, Account.Type.REKEYED, null -> {
                val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasValidSecretKey) AccountIconResource.STANDARD.iconTintResId else R.color.text_gray_lighter
            }
        }
    }

    private fun getAccountIconResId(account: Account?): Int {
        return when (account?.type) {
            Account.Type.LEDGER -> AccountIconResource.LEDGER.iconResId
            Account.Type.WATCH -> AccountIconResource.WATCH.iconResId
            Account.Type.STANDARD, Account.Type.REKEYED, Account.Type.REKEYED_AUTH, null -> {
                val hasValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasValidSecretKey) AccountIconResource.STANDARD.iconResId else R.drawable.ic_question
            }
        }
    }
}
