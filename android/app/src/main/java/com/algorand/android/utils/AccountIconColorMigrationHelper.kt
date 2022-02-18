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

package com.algorand.android.utils

import com.algorand.android.models.Account
import com.algorand.android.models.Account.AccountIconColor
import javax.inject.Inject

class AccountIconColorMigrationHelper @Inject constructor() : BaseMigrationHelper<List<Account>> {

    override fun isMigrationNeeded(values: List<Account>): Boolean {
        return values.any { it.accountIconColor == AccountIconColor.UNDEFINED }
    }

    override fun getMigratedValues(values: List<Account>): List<Account> {
        return values.map {
            if (it.accountIconColor == AccountIconColor.UNDEFINED) {
                it.copy(accountIconColor = AccountIconColor.getRandomColor())
            } else {
                it
            }
        }
    }
}
