package com.algorand.android

import com.algorand.android.models.Account
import com.algorand.android.models.AccountDeserializer
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import org.intellij.lang.annotations.Language
import org.junit.Test

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
class AccountMigrationUnitTest {

    private val gson = GsonBuilder().registerTypeAdapter(Account::class.java, AccountDeserializer()).create()

    @Test
    fun testJsonConversion() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\"\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"STANDARD\",\n    \"detail\": {\n      \"secretKey\": [\n        0,\n        0,\n        0,\n        1,\n        0,\n        0,\n        0,\n        0,\n        3,\n        0\n      ]\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"LEDGER\",\n    \"detail\": {\n      \"bluetoothAddress\": \"Test\"\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED\",\n    \"detail\": {}\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED_AUTH\",\n    \"detail\": {\n      \"authDetail\": {\n        \"bluetoothAddress\": \"addressX2\",\n        \"bluetoothName\": \"bluetoothNameX2\"\n      },\n      \"authDetailType\": \"LEDGER\",\n      \"rekeyedAuthDetail\": {\n        \"X2\": {\n          \"bluetoothAddress\": \"addressX2\",\n          \"positionInLedger\": 0\n        },\n        \"Y3\": {\n          \"bluetoothAddress\": \"addressY3\",\n          \"positionInLedger\": 0 \n        }\n      }\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED_AUTH\",\n    \"detail\": {\n      \"authDetail\": {\n        \"secretKey\": [\n          0,\n          2\n        ]\n      },\n      \"authDetailType\": \"STANDARD\",\n      \"rekeyedAuthDetail\": {\n        \"X2\": {\n          \"bluetoothAddress\": \"addressX2\",\n          \"positionInLedger\": 0\n        },\n        \"Y3\": {\n          \"bluetoothAddress\": \"addressY3\",\n          \"positionInLedger\": 0\n        }\n      }\n    }\n  }\n]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)
        accountList.forEach { println(it) }
        assert(accountList.size == 6)
    }

    @Test
    fun serializeAndDeserializeStandard() {
        val standardAccount = Account.create("X2..", Account.Detail.Standard(byteArrayOf(2, 3)), "name")
        val decodedStandardAccount = gson.fromJson(gson.toJson(standardAccount), Account::class.java)
        compareFields(standardAccount, decodedStandardAccount)
    }

    @Test
    fun serializeAndDeserializeLedger() {
        val standardAccount = Account.create(
            "X2..",
            Account.Detail.Ledger(bluetoothAddress = "bluetoothAddress", bluetoothName = ""),
            "name"
        )
        val decodedStandardAccount = gson.fromJson(gson.toJson(standardAccount), Account::class.java)
        compareFields(standardAccount, decodedStandardAccount)
    }

    @Test
    fun serializeAndDeserializeWatch() {
        val standardAccount = Account.create(
            "X2..",
            Account.Detail.Watch,
            "name"
        )
        val decodedStandardAccount = gson.fromJson(gson.toJson(standardAccount), Account::class.java)
        compareFields(standardAccount, decodedStandardAccount)
    }

    @Test
    fun serializeAndDeserializeRekeyed() {
        val standardAccount = Account.create(
            "X2..",
            Account.Detail.Rekeyed,
            "name"
        )
        val decodedStandardAccount = gson.fromJson(gson.toJson(standardAccount), Account::class.java)
        compareFields(standardAccount, decodedStandardAccount)
    }

    @Test
    fun serializeAndDeserializeRekeyedAuth() {
        val ledgerAccount = Account.create(
            "X2..",
            Account.Detail.Ledger(bluetoothAddress = "bluetoothAddress", bluetoothName = ""),
            "name"
        )
        val standardAccount = Account.create("X2..", Account.Detail.Standard(byteArrayOf(2, 3)), "name")
        val rekeyedAccount = Account.create(
            "X2..",
            Account.Detail.RekeyedAuth.create(
                standardAccount.detail,
                mapOf("X2" to ledgerAccount.detail as Account.Detail.Ledger)
            ),
            "name"
        )
        val decodedStandardAccount = gson.fromJson(gson.toJson(rekeyedAccount), Account::class.java)
        compareFields(rekeyedAccount, decodedStandardAccount)
    }

    @Test
    fun serializeAndDeserializeRekeyedAuthWithoutAuth() {
        val ledgerAccount = Account.create(
            "X2..",
            Account.Detail.Ledger(bluetoothAddress = "bluetoothAddress", bluetoothName = ""),
            "name"
        )
        val rekeyedAccount = Account.create(
            "X2..",
            Account.Detail.RekeyedAuth.create(null, mapOf("X2" to ledgerAccount.detail as Account.Detail.Ledger)),
            "name"
        )
        val decodedStandardAccount = gson.fromJson(gson.toJson(rekeyedAccount), Account::class.java)
        compareFields(rekeyedAccount, decodedStandardAccount)
    }

    private fun compareFields(account: Account, otherAccount: Account) {
        assert(account.address == otherAccount.address)
        assert(account.type == otherAccount.type)
        assert(account.name == otherAccount.name)
    }

    @Test
    fun deserializeAfterAddingAccountIconColor() {
        @Language("JSON") val standardJson =
            "[\n  {\n    \"secretKey\": [\n      0,\n      0,\n      0,\n      0,\n      3,\n      0,\n      2,\n      0,\n      0,\n      0\n    ],\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\"\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"STANDARD\",\n    \"detail\": {\n      \"secretKey\": [\n        0,\n        0,\n        0,\n        1,\n        0,\n        0,\n        0,\n        0,\n        3,\n        0\n      ]\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"LEDGER\",\n    \"detail\": {\n      \"bluetoothAddress\": \"Test\"\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED\",\n    \"detail\": {}\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED_AUTH\",\n    \"detail\": {\n      \"authDetail\": {\n        \"bluetoothAddress\": \"addressX2\",\n        \"bluetoothName\": \"bluetoothNameX2\"\n      },\n      \"authDetailType\": \"LEDGER\",\n      \"rekeyedAuthDetail\": {\n        \"X2\": {\n          \"bluetoothAddress\": \"addressX2\",\n          \"positionInLedger\": 0\n        },\n        \"Y3\": {\n          \"bluetoothAddress\": \"addressY3\",\n          \"positionInLedger\": 0 \n        }\n      }\n    }\n  },\n  {\n    \"publicKey\": \"X2...\",\n    \"accountName\": \"test\",\n    \"type\": \"REKEYED_AUTH\",\n    \"detail\": {\n      \"authDetail\": {\n        \"secretKey\": [\n          0,\n          2\n        ]\n      },\n      \"authDetailType\": \"STANDARD\",\n      \"rekeyedAuthDetail\": {\n        \"X2\": {\n          \"bluetoothAddress\": \"addressX2\",\n          \"positionInLedger\": 0\n        },\n        \"Y3\": {\n          \"bluetoothAddress\": \"addressY3\",\n          \"positionInLedger\": 0\n        }\n      }\n    }\n  }\n]"
        val listType = object : TypeToken<List<Account>>() {}.type
        val accountList = gson.fromJson<List<Account>>(standardJson, listType)
        assert(accountList.all { it.accountIconColor == Account.AccountIconColor.UNDEFINED })
    }
}
