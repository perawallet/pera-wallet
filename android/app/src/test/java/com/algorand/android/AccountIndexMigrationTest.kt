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

package com.algorand.android

import com.algorand.android.models.Account
import com.algorand.android.models.AccountDeserializer
import com.algorand.android.utils.AccountIndexMigrationHelper
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import org.intellij.lang.annotations.Language
import org.junit.Test

class AccountIndexMigrationTest {

    private val gson = GsonBuilder().registerTypeAdapter(Account::class.java, AccountDeserializer()).create()
    private val accountIndexMigrationHelper = AccountIndexMigrationHelper()

    @Test
    fun checkMigrationHelperNeedForAccountIndexWhenItsNull() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\" \n }]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)

        assert(accountIndexMigrationHelper.isMigrationNeeded(accountList))
    }

    @Test
    fun checkMigrationHelperNeedForAccountIndexWhenItsNotAssigned() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\" \n,    \"index\": -1  }]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)

        assert(accountIndexMigrationHelper.isMigrationNeeded(accountList))
    }

    @Test
    fun checkMigrationHelperNeedForAccountIndexWhenItIsAssigned() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\" \n,    \"index\": 1  }]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)

        assert(!accountIndexMigrationHelper.isMigrationNeeded(accountList))
    }

    @Test
    fun checkMigrationHelperIfItsMigrationSuccessfully() {
        val accountList = listOf<Account>(
            Account.create("watch1", Account.Detail.Watch),
            Account.create("standard1", Account.Detail.Standard(byteArrayOf())),
            Account.create("watch2", Account.Detail.Watch),
            Account.create("standard2", Account.Detail.Standard(byteArrayOf())),
            Account.create("watch3", Account.Detail.Watch),
        )

        val migratedAccounts = accountIndexMigrationHelper.getMigratedValues(accountList)

        val expectedListResult = listOf<Account>(
            Account.create("standard1", Account.Detail.Standard(byteArrayOf()), index = 0),
            Account.create("standard2", Account.Detail.Standard(byteArrayOf()), index = 1),
            Account.create("watch1", Account.Detail.Watch, index = 10000),
            Account.create("watch2", Account.Detail.Watch, index = 10001),
            Account.create("watch3", Account.Detail.Watch, index = 10002),
        )

        var isSuccessfullyMigrated = true
        migratedAccounts.forEachIndexed { index, account ->
            isSuccessfullyMigrated = expectedListResult[index].index == account.index && isSuccessfullyMigrated
        }
        assert(isSuccessfullyMigrated)
    }
}
