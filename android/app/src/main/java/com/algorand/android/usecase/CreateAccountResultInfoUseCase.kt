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

import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.mapper.BaseAccountAdditionResultInfoPreviewMapper
import com.algorand.android.models.BaseAccountAdditionResultInfoPreview.CreateAccountResultInfoPreview
import javax.inject.Inject

class CreateAccountResultInfoUseCase @Inject constructor(
    private val accountManager: AccountManager,
    private val baseAccountAdditionResultInfoPreviewMapper: BaseAccountAdditionResultInfoPreviewMapper
) {

    fun getCreateAccountResultInfoPreview(): CreateAccountResultInfoPreview {
        val isItFirstAccountThatAdded = accountManager.getAccounts().size == 1
        val titleTextRes = R.string.account_has_been_added
        val descriptionTextRes = if (isItFirstAccountThatAdded) {
            R.string.welcome_to_pera_your_account
        } else {
            R.string.congratulations_your_account
        }
        val firstButtonTextRes = R.string.buy_algo
        val secondButtonTextRes = if (isItFirstAccountThatAdded) R.string.start_using_pera else R.string.continue_text
        return baseAccountAdditionResultInfoPreviewMapper.mapToCreateAccountResultInfoPreview(
            titleTextRes = titleTextRes,
            descriptionTextRes = descriptionTextRes,
            firstButtonTextRes = firstButtonTextRes,
            secondButtonTextRes = secondButtonTextRes
        )
    }
}
