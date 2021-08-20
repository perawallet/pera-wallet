/*
 * Copyright 2019 Algorand, Inc.
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
import com.algorand.algosdk.mobile.SuggestedParams
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.TransactionParams
import com.algorand.android.utils.makeAddAssetTx
import com.algorand.android.utils.makeRekeyTx
import com.algorand.android.utils.makeRemoveAssetTx
import com.algorand.android.utils.makeTx
import com.algorand.android.utils.toSuggestedParams
import org.junit.Test

class AlgorandTransactionTest {

    @Test
    fun isAlgoTransactionWorks() {
        val transactionParams = TransactionParams(
            minFee = 1000,
            fee = 0,
            genesisId = "testnet-v1.0",
            genesisHash = "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            lastRound = 14954171
        )
        val algoTransaction = transactionParams.makeTx(
            senderAddress = "53DDJWXPS6GV6QVTMVIQEZQSYSC2SV3XUAHFTFPGCTNJ77SHY7L3WSK5E4",
            receiverAddress = "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            amount = 1000000,
            assetId = AssetInformation.ALGORAND_ID,
            isMax = false,
            note = null
        )

        val expectedAlgoTransactionResult = byteArrayOf(-119, -93, 97, 109, 116, -50, 0, 15, 66, 64, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 46, -69, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 50, -93, -93, 114, 99, 118, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -93, 115, 110, 100, -60, 32, -18, -58, 52, -38, -17, -105, -115, 95, 66, -77, 101, 81, 2, 102, 18, -60, -123, -87, 87, 119, -96, 14, 89, -107, -26, 20, -38, -97, -2, 71, -57, -41, -92, 116, 121, 112, 101, -93, 112, 97, 121)

        assert(algoTransaction.contentEquals(expectedAlgoTransactionResult))
    }

    @Test
    fun isAssetTransactionWorks() {
        val transactionParams = TransactionParams(
            minFee = 1000,
            fee = 0,
            genesisId = "testnet-v1.0",
            genesisHash = "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            lastRound = 14954213L
        )

        val hipoCoinTransaction = transactionParams.makeTx(
            senderAddress = "53DDJWXPS6GV6QVTMVIQEZQSYSC2SV3XUAHFTFPGCTNJ77SHY7L3WSK5E4",
            receiverAddress = "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            amount = 1,
            assetId = 11711, // HipoCoin Asset ID
            isMax = false,
            note = null
        )

        val expectedHipoCoinTransactionResult = byteArrayOf(-119, -92, 97, 97, 109, 116, 1, -92, 97, 114, 99, 118, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 46, -27, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 50, -51, -93, 115, 110, 100, -60, 32, -18, -58, 52, -38, -17, -105, -115, 95, 66, -77, 101, 81, 2, 102, 18, -60, -123, -87, 87, 119, -96, 14, 89, -107, -26, 20, -38, -97, -2, 71, -57, -41, -92, 116, 121, 112, 101, -91, 97, 120, 102, 101, 114, -92, 120, 97, 105, 100, -51, 45, -65)

        assert(hipoCoinTransaction.contentEquals(expectedHipoCoinTransactionResult))
    }

    @Test
    fun isAddHipoCoinTransactionWorks() {
        val transactionParams = TransactionParams(
            minFee = 1000,
            fee = 0,
            genesisId = "testnet-v1.0",
            genesisHash = "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            lastRound = 14954294L
        )

        val addHipoCoinTransaction = transactionParams.makeAddAssetTx(
            publicKey = "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            assetId = 11711 // HipoCoin Asset ID
        )

        val expectedAddHipoCoinTransactionResult = byteArrayOf(-119, -92, 97, 114, 99, 118, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 47, 54, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 51, 30, -93, 115, 110, 100, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -92, 116, 121, 112, 101, -91, 97, 120, 102, 101, 114, -92, 120, 97, 105, 100, -51, 45, -65)

        assert(addHipoCoinTransaction.contentEquals(expectedAddHipoCoinTransactionResult))
    }

    @Test
    fun isRemoveHipoCoinTransactionWorks() {
        val transactionParams = TransactionParams(
            minFee = 1000,
            fee = 0,
            genesisId = "testnet-v1.0",
            genesisHash = "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            lastRound = 14954300L
        )

        val removeHipoCoinTransaction = transactionParams.makeRemoveAssetTx(
            senderAddress = "5KYQMJHCDW6CJNLZPZCB6IBWO7FTEDYAH3U7DH3JWWPJP7NXH3BSGAGUUM",
            creatorPublicKey = "ANC4BH2C6QJTCXZMEMCB7XEW7TFZVNSAH3RJ5YTMNUPNXU4DKD2BHAAZSU",
            assetId = 11711 // HipoCoin Asset ID
        )

        val expectedRemoveHipoCoinTransactionResult = byteArrayOf(-119, -90, 97, 99, 108, 111, 115, 101, -60, 32, 3, 69, -64, -97, 66, -12, 19, 49, 95, 44, 35, 4, 31, -36, -106, -4, -53, -102, -74, 64, 62, -30, -98, -30, 108, 109, 30, -37, -45, -125, 80, -12, -92, 97, 114, 99, 118, -60, 32, 3, 69, -64, -97, 66, -12, 19, 49, 95, 44, 35, 4, 31, -36, -106, -4, -53, -102, -74, 64, 62, -30, -98, -30, 108, 109, 30, -37, -45, -125, 80, -12, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 47, 60, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 51, 36, -93, 115, 110, 100, -60, 32, -22, -79, 6, 36, -30, 29, -68, 36, -75, 121, 126, 68, 31, 32, 54, 119, -53, 50, 15, 0, 62, -23, -15, -97, 105, -75, -98, -105, -3, -73, 62, -61, -92, 116, 121, 112, 101, -91, 97, 120, 102, 101, 114, -92, 120, 97, 105, 100, -51, 45, -65)

        assert(removeHipoCoinTransaction.contentEquals(expectedRemoveHipoCoinTransactionResult))
    }

    @Test
    fun isRekeyTransactionWorks() {
        val transactionParams = TransactionParams(
            minFee = 1000,
            fee = 0,
            genesisId = "testnet-v1.0",
            genesisHash = "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            lastRound = 14957693
        )

        val rekeyTransaction = transactionParams.makeRekeyTx(
            rekeyAddress = "KFQMT4AK4ASIPAN23X36T3REP6D26LQDMAQNSAZM3DIEG2HTVKXEF76AP4",
            rekeyAdminAddress = "PSFS47IHURFRHYPQIXWHNRFGA2GQMBJVF4KJSYVKIX35YIZTS2JJZA4W5Y"
        )

        val expectedRekeyTransactionResult = byteArrayOf(-119, -93, 102, 101, 101, -51, 3, -24, -94, 102, 118, -50, 0, -28, 60, 125, -93, 103, 101, 110, -84, 116, 101, 115, 116, 110, 101, 116, 45, 118, 49, 46, 48, -94, 103, 104, -60, 32, 72, 99, -75, 24, -92, -77, -56, 78, -56, 16, -14, 45, 79, 16, -127, -53, 15, 113, -16, 89, -89, -84, 32, -34, -58, 47, 127, 112, -27, 9, 58, 34, -94, 108, 118, -50, 0, -28, 64, 101, -93, 114, 99, 118, -60, 32, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82, -91, 114, 101, 107, 101, 121, -60, 32, 124, -117, 46, 125, 7, -92, 75, 19, -31, -16, 69, -20, 118, -60, -90, 6, -115, 6, 5, 53, 47, 20, -103, 98, -86, 69, -9, -36, 35, 51, -106, -110, -93, 115, 110, 100, -60, 32, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82, -92, 116, 121, 112, 101, -93, 112, 97, 121)

        assert(rekeyTransaction.contentEquals(expectedRekeyTransactionResult))
    }

    @Test
    fun isTransactionParamsToSuggestedParamsWithGenesisIdWorks() {

        val transactionParams = TransactionParams(
            minFee = 1000,
            fee = 0,
            genesisId = "testnet-v1.0",
            genesisHash = "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            lastRound = 14957693L
        )

        val suggestedParams = transactionParams.toSuggestedParams()

        val expectedSuggestedParams = SuggestedParams().apply {
            fee = 0
            genesisID = "testnet-v1.0"
            genesisHash = Base64.decode("SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=", Base64.DEFAULT)
            firstRoundValid = 14957693L
            lastRoundValid = 14958693L
        }

        assert(
            suggestedParams.fee == expectedSuggestedParams.fee &&
                suggestedParams.genesisID == expectedSuggestedParams.genesisID &&
                suggestedParams.genesisHash.contentEquals(expectedSuggestedParams.genesisHash) &&
                suggestedParams.firstRoundValid == expectedSuggestedParams.firstRoundValid &&
                suggestedParams.lastRoundValid == expectedSuggestedParams.lastRoundValid
        )
    }

    @Test
    fun isTransactionParamsToSuggestedParamsWithoutGenesisIdWorks() {

        val transactionParams = TransactionParams(
            minFee = 1000,
            fee = 0,
            genesisId = "testnet-v1.0",
            genesisHash = "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            lastRound = 14957693L
        )

        val suggestedParams = transactionParams.toSuggestedParams(addGenesisId = false)

        val expectedSuggestedParams = SuggestedParams().apply {
            fee = 0
            genesisID = ""
            genesisHash = Base64.decode("SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=", Base64.DEFAULT)
            firstRoundValid = 14957693L
            lastRoundValid = 14958693L
        }

        assert(
            suggestedParams.fee == expectedSuggestedParams.fee &&
                suggestedParams.genesisID == expectedSuggestedParams.genesisID &&
                suggestedParams.genesisHash.contentEquals(expectedSuggestedParams.genesisHash) &&
                suggestedParams.firstRoundValid == expectedSuggestedParams.firstRoundValid &&
                suggestedParams.lastRoundValid == expectedSuggestedParams.lastRoundValid
        )
    }
}
