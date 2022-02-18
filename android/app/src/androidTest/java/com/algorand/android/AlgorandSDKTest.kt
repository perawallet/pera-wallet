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

import android.util.Base64
import com.algorand.algosdk.mobile.Mobile
import com.algorand.algosdk.mobile.SuggestedParams
import com.algorand.algosdk.mobile.Uint64
import org.junit.Test

class AlgorandSDKTest {

    @Test
    fun isMnemonicFromPrivateKeyWorks() {

        val privateKey = byteArrayOf(80, -73, 43, 100, -5, -58, -47, -107, 27, 92, -76, -99, 110, 7, -127, 61, -55, -15, 73, -26, 59, 30, -9, -15, 22, 70, -3, -69, -110, 93, 86, 47, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82)
        val mnemonic = Mobile.mnemonicFromPrivateKey(privateKey)

        val expectedMnemonic = "tube put rare hurry phone tornado this reform squirrel buffalo scene need toe mystery tennis bullet discover forward perfect save century number kingdom ability person"

        assert(mnemonic == expectedMnemonic)
    }

    @Test
    fun isMnemonicToPrivateKeyWorks() {

        val mnemonic = "tube put rare hurry phone tornado this reform squirrel buffalo scene need toe mystery tennis bullet discover forward perfect save century number kingdom ability person"
        val privateKey = Mobile.mnemonicToPrivateKey(mnemonic)

        val expectedPrivateKey = byteArrayOf(80, -73, 43, 100, -5, -58, -47, -107, 27, 92, -76, -99, 110, 7, -127, 61, -55, -15, 73, -26, 59, 30, -9, -15, 22, 70, -3, -69, -110, 93, 86, 47, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82)

        assert(privateKey.contentEquals(expectedPrivateKey))
    }

    @Test
    fun isGenerateAddressFromSecretKeyWorks() {

        val privateKey = byteArrayOf(80, -73, 43, 100, -5, -58, -47, -107, 27, 92, -76, -99, 110, 7, -127, 61, -55, -15, 73, -26, 59, 30, -9, -15, 22, 70, -3, -69, -110, 93, 86, 47, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82)
        val publicKey = Mobile.generateAddressFromSK(privateKey)

        val expectedPublicKey = "KFQMT4AK4ASIPAN23X36T3REP6D26LQDMAQNSAZM3DIEG2HTVKXEF76AP4"

        assert(publicKey == expectedPublicKey)
    }

    @Test
    fun isSignTransactionWorks() {

        val transaction = byteArrayOf(-119, -93, 97, 109, 116, -50, 0, 15, 66, 64, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, -97, 85, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, -93, 61, -93, 114, 99, 118, -60, 32, -18, -58, 52, -38, -17, -105, -115, 95, 66, -77, 101, 81, 2, 102, 18, -60, -123, -87, 87, 119, -96, 14, 89, -107, -26, 20, -38, -97, -2, 71, -57, -41, -93, 115, 110, 100, -60, 32, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82, -92, 116, 121, 112, 101, -93, 112, 97, 121)
        val secretKey = byteArrayOf(80, -73, 43, 100, -5, -58, -47, -107, 27, 92, -76, -99, 110, 7, -127, 61, -55, -15, 73, -26, 59, 30, -9, -15, 22, 70, -3, -69, -110, 93, 86, 47, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82)
        val signedTransaction = Mobile.signTransaction(secretKey, transaction)

        val expectedSignedTransaction = byteArrayOf(-126, -93, 115, 105, 103, -60, 64, -63, 85, 52, -91, 28, -119, -104, -74, -38, 56, -116, -74, 117, 102, -53, -104, -43, 41, 40, 34, -88, -26, -73, -95, 52, -56, 50, -127, 53, 82, 27, 68, -24, -47, -103, 22, 63, -84, 38, -31, -114, 7, -122, 44, -98, -93, -92, -90, -24, -81, 70, -14, 94, -125, -26, 55, 88, -37, 91, -64, 92, -54, -98, 15, -93, 116, 120, 110, -119, -93, 97, 109, 116, -50, 0, 15, 66, 64, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, -97, 85, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, -93, 61, -93, 114, 99, 118, -60, 32, -18, -58, 52, -38, -17, -105, -115, 95, 66, -77, 101, 81, 2, 102, 18, -60, -123, -87, 87, 119, -96, 14, 89, -107, -26, 20, -38, -97, -2, 71, -57, -41, -93, 115, 110, 100, -60, 32, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82, -92, 116, 121, 112, 101, -93, 112, 97, 121)

        assert(signedTransaction.contentEquals(expectedSignedTransaction))
    }

    @Test
    fun isMakeAssetTransferTransactionWorks() {

        val suggestedParams = SuggestedParams().apply {
            fee = 0
            genesisID = ""
            genesisHash = Base64.decode("SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=", Base64.DEFAULT)
            firstRoundValid = 14954213L
            lastRoundValid = 14955213L
        }

        val transactionAmount = 1L
        val transactionAmountUint64 = Uint64().apply {
            upper = transactionAmount.shr(Int.SIZE_BITS)
            lower = transactionAmount.and(Int.MAX_VALUE.toLong())
        }

        val assetTransferTransaction = Mobile.makeAssetTransferTxn(
            "53DDJWXPS6GV6QVTMVIQEZQSYSC2SV3XUAHFTFPGCTNJ77SHY7L3WSK5E4",
            "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            "",
            transactionAmountUint64,
            null,
            suggestedParams,
            11711
        )

        val expectedAssetTransferTransaction = byteArrayOf(-119, -92, 97, 97, 109, 116, 1, -92, 97, 114, 99, 118, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 46, -27, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 50, -51, -93, 115, 110, 100, -60, 32, -18, -58, 52, -38, -17, -105, -115, 95, 66, -77, 101, 81, 2, 102, 18, -60, -123, -87, 87, 119, -96, 14, 89, -107, -26, 20, -38, -97, -2, 71, -57, -41, -92, 116, 121, 112, 101, -91, 97, 120, 102, 101, 114, -92, 120, 97, 105, 100, -51, 45, -65)

        assert(assetTransferTransaction.contentEquals(expectedAssetTransferTransaction))
    }

    @Test
    fun isMakePaymentTransactionWorks() {

        val suggestedParams = SuggestedParams().apply {
            fee = 0
            genesisID = "testnet-v1.0"
            genesisHash = Base64.decode("SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=", Base64.DEFAULT)
            firstRoundValid = 14954171
            lastRoundValid = 14955171
        }

        val transactionAmount = 1000000L
        val transactionAmountUint64 = Uint64().apply {
            upper = transactionAmount.shr(Int.SIZE_BITS)
            lower = transactionAmount.and(Int.MAX_VALUE.toLong())
        }

        val algoPaymentTransaction = Mobile.makePaymentTxn(
            "53DDJWXPS6GV6QVTMVIQEZQSYSC2SV3XUAHFTFPGCTNJ77SHY7L3WSK5E4",
            "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            transactionAmountUint64,
            null,
            "",
            suggestedParams
        )

        val expectedAlgoPaymentTransaction = byteArrayOf(-119, -93, 97, 109, 116, -50, 0, 15, 66, 64, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 46, -69, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 50, -93, -93, 114, 99, 118, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -93, 115, 110, 100, -60, 32, -18, -58, 52, -38, -17, -105, -115, 95, 66, -77, 101, 81, 2, 102, 18, -60, -123, -87, 87, 119, -96, 14, 89, -107, -26, 20, -38, -97, -2, 71, -57, -41, -92, 116, 121, 112, 101, -93, 112, 97, 121)

        assert(algoPaymentTransaction.contentEquals(expectedAlgoPaymentTransaction))
    }

    @Test
    fun isAddHipoCoinTransactionWorks() {

        val suggestedParams = SuggestedParams().apply {
            fee = 0
            genesisID = "testnet-v1.0"
            genesisHash = Base64.decode("SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=", Base64.DEFAULT)
            firstRoundValid = 14954294L
            lastRoundValid = 14955294L
        }

        val addHipoCoinTransaction = Mobile.makeAssetAcceptanceTxn(
            "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            null,
            suggestedParams,
            11711
        )

        val expectedAddHipoCoinTransaction = byteArrayOf(-119, -92, 97, 114, 99, 118, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 47, 54, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 51, 30, -93, 115, 110, 100, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -92, 116, 121, 112, 101, -91, 97, 120, 102, 101, 114, -92, 120, 97, 105, 100, -51, 45, -65)

        assert(addHipoCoinTransaction.contentEquals(expectedAddHipoCoinTransaction))
    }

    @Test
    fun isRemoveHipoCoinTransactionWorks() {

        val suggestedParams = SuggestedParams().apply {
            fee = 0
            genesisID = ""
            genesisHash = Base64.decode("SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=", Base64.DEFAULT)
            firstRoundValid = 14954300L
            lastRoundValid = 14955300L
        }

        val transactionAmount = 0L
        val transactionAmountUint64 = Uint64().apply {
            upper = transactionAmount.shr(Int.SIZE_BITS)
            lower = transactionAmount.and(Int.MAX_VALUE.toLong())
        }

        val removeHipoCoinTransaction = Mobile.makeAssetTransferTxn(
            "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            "ANC4BH2C6QJTCXZMEMCB7XEW7TFZVNSAH3RJ5YTMNUPNXU4DKD2BHAAZSU",
            "ANC4BH2C6QJTCXZMEMCB7XEW7TFZVNSAH3RJ5YTMNUPNXU4DKD2BHAAZSU",
            transactionAmountUint64,
            null,
            suggestedParams,
            11711
        )

        val expectedRemoveHipoCoinTransaction = byteArrayOf(-119, -90, 97, 99, 108, 111, 115, 101, -60, 32, 3, 69, -64, -97, 66, -12, 19, 49, 95, 44, 35, 4, 31, -36, -106, -4, -53, -102, -74, 64, 62, -30, -98, -30, 108, 109, 30, -37, -45, -125, 80, -12, -92, 97, 114, 99, 118, -60, 32, 3, 69, -64, -97, 66, -12, 19, 49, 95, 44, 35, 4, 31, -36, -106, -4, -53, -102, -74, 64, 62, -30, -98, -30, 108, 109, 30, -37, -45, -125, 80, -12, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 47, 60, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 51, 36, -93, 115, 110, 100, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -92, 116, 121, 112, 101, -91, 97, 120, 102, 101, 114, -92, 120, 97, 105, 100, -51, 45, -65)

        assert(removeHipoCoinTransaction.contentEquals(expectedRemoveHipoCoinTransaction))
    }

    @Test
    fun isRekeyTransactionWorks() {

        val suggestedParams = SuggestedParams().apply {
            fee = 0
            genesisID = "testnet-v1.0"
            genesisHash = Base64.decode("SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=", Base64.DEFAULT)
            firstRoundValid = 14957693L
            lastRoundValid = 14958693L
        }

        val rekeyTransaction = Mobile.makeRekeyTxn(
            "KFQMT4AK4ASIPAN23X36T3REP6D26LQDMAQNSAZM3DIEG2HTVKXEF76AP4",
            "PSFS47IHURFRHYPQIXWHNRFGA2GQMBJVF4KJSYVKIX35YIZTS2JJZA4W5Y",
            suggestedParams
        )

        val expectedRekeyTransaction = byteArrayOf(-119, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 60, 125, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 64, 101, -93, 114, 99, 118, -60, 32, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82, -91, 114, 101, 107, 101, 121, -60, 32, 124, -117, 46, 125, 7, -92, 75, 19, -31, -16, 69, -20, 118, -60, -90, 6, -115, 6, 5, 53, 47, 20, -103, 98, -86, 69, -9, -36, 35, 51, -106, -110, -93, 115, 110, 100, -60, 32, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82, -92, 116, 121, 112, 101, -93, 112, 97, 121)

        assert(rekeyTransaction.contentEquals(expectedRekeyTransaction))
    }

    @Test
    fun isMsgPackToJsonWorks() {
        val transactionMsgPack = "iqNhbXTOAAGGoKNmZWXNA+iiZnbOAOA1S6NnZW6sbWFpbm5ldC12MS4womdoxCDAYcTY/B293tLXYEvkVo4/bQQZh6w3veS2ILWrOSSK36Jsds4A4DkzpG5vdGXEEmV4YW1wbGUgbm90ZSB2YWx1ZaNyY3bEIGtpDtrpSU5mJJEvKaoCmL40NlS8xDz/fhybP0aS83rAo3NuZMQgUWDJ8ArgJIeBut336e4kf4evLgNgINkDLNjQQ2jzqq6kdHlwZaNwYXk="
        val decodedTransactionByteArray = Base64.decode(transactionMsgPack, Base64.DEFAULT)
        val transactionJson = Mobile.transactionMsgpackToJson(decodedTransactionByteArray)

        val expectedPayload = """
            {
              "amt": 100000,
              "fee": 1000,
              "fv": 14693707,
              "gen": "mainnet-v1.0",
              "gh": "wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=",
              "lv": 14694707,
              "note": "ZXhhbXBsZSBub3RlIHZhbHVl",
              "rcv": "a2kO2ulJTmYkkS8pqgKYvjQ2VLzEPP9+HJs/RpLzesA=",
              "snd": "UWDJ8ArgJIeBut336e4kf4evLgNgINkDLNjQQ2jzqq4=",
              "type": "pay"
            }
        """.trimIndent()

        assert(transactionJson == expectedPayload)
    }
}
