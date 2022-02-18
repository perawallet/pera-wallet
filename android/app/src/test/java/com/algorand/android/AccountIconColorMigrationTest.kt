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
import com.algorand.android.utils.AccountIconColorMigrationHelper
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import org.intellij.lang.annotations.Language
import org.junit.Test

class AccountIconColorMigrationTest {

    private val gson = GsonBuilder().registerTypeAdapter(Account::class.java, AccountDeserializer()).create()
    private val accountIconColorMigrationHelper = AccountIconColorMigrationHelper()

    @Test
    fun checkMigrationHelperNeedForAccountIconColor() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\"\n  }]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)

        assert(accountIconColorMigrationHelper.isMigrationNeeded(accountList))
    }

    @Test
    fun checkMigrationHelperNotNeedForAccountIconColor() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n \"accountIconColor\": \"BLUSH\" }]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)

        assert(!accountIconColorMigrationHelper.isMigrationNeeded(accountList))
    }

    @Test
    fun checkAddingAccountIconColorMigration() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\"\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"STANDARD\",\n    \"detail\": {\n      \"secretKey\": [\n        0,\n        0,\n        0,\n        1,\n        0,\n        0,\n        0,\n        0,\n        3,\n        0\n      ]\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"LEDGER\",\n    \"detail\": {\n      \"bluetoothAddress\": \"Test\"\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED\",\n    \"detail\": {}\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED_AUTH\",\n    \"detail\": {\n      \"authDetail\": {\n        \"bluetoothAddress\": \"addressX2\",\n        \"bluetoothName\": \"bluetoothNameX2\"\n      },\n      \"authDetailType\": \"LEDGER\",\n      \"rekeyedAuthDetail\": {\n        \"X2\": {\n          \"bluetoothAddress\": \"addressX2\",\n          \"positionInLedger\": 0\n        },\n        \"Y3\": {\n          \"bluetoothAddress\": \"addressY3\",\n          \"positionInLedger\": 0 \n        }\n      }\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED_AUTH\",\n    \"detail\": {\n      \"authDetail\": {\n        \"secretKey\": [\n          0,\n          2\n        ]\n      },\n      \"authDetailType\": \"STANDARD\",\n      \"rekeyedAuthDetail\": {\n        \"X2\": {\n          \"bluetoothAddress\": \"addressX2\",\n          \"positionInLedger\": 0\n        },\n        \"Y3\": {\n          \"bluetoothAddress\": \"addressY3\",\n          \"positionInLedger\": 0\n        }\n      }\n    }\n  }\n]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)

        val migratedAccounts = accountIconColorMigrationHelper.getMigratedValues(accountList)

        var isEverythingTheSameButColor = true
        accountList.forEachIndexed { index, account ->
            isEverythingTheSameButColor = isEverythingTheSameButColor && (
                account.type == migratedAccounts[index].type &&
                    account.address == migratedAccounts[index].address &&
                    account.detail == migratedAccounts[index].detail &&
                    account.name == migratedAccounts[index].name
                )
        }

        val isMigrationSuccessful = isEverythingTheSameButColor &&
            migratedAccounts.all { it.accountIconColor != Account.AccountIconColor.UNDEFINED }
        assert(isMigrationSuccessful)
    }
}
