/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android

import com.algorand.android.modules.webexport.createWebExportContent
import com.algorand.android.modules.webexport.createWebExportEncryptedContent
import com.algorand.android.modules.webexport.model.WebBackupRequestBody
import com.algorand.android.network.MobileAlgorandApi
import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import org.junit.Test
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class WebExportTest {

    @Test
    fun encryptionWorks() {
        val backupId = "223c9bbb-0b9d-456a-b6d7-a7bc82a2bd80"
        val modificationKey = "s+=ozZXaRJa}Qe5T"
        val encryptionKey = "24,67,88,84,203,126,13,172,3,151,80,223,20,146,160,37,143,244,143,243,0,30,183,247,93,25,28,167,85,34,71,129"
        val deviceId = "3467659723611582688"
        val accountName = "testenrico"
        val bytePkey = byteArrayOf(80, -73, 43, 100, -5, -58, -47, -107, 27, 92, -76, -99, 110, 7, -127, 61, -55, -15, 73, -26, 59, 30, -9, -15, 22, 70, -3, -69, -110, 93, 86, 47, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82)

        val content = createWebExportContent(deviceId, listOf(Pair(accountName, bytePkey)))

        val retrofit = Retrofit.Builder()
            .addConverterFactory(GsonConverterFactory.create())
            .baseUrl(BuildConfig.MOBILE_ALGORAND_BASE_URL)
            .client(OkHttpClient.Builder().build())
            .build()

        val api = retrofit.create(MobileAlgorandApi::class.java)

        val encryptionResult = createWebExportEncryptedContent(content, encryptionKey)

        encryptionResult.encryptedString?.let {
            val check = runBlocking {
                api.putBackup(
                    id = backupId,
                    modificationKey = modificationKey,
                    encryptedContent = WebBackupRequestBody(
                        encryptedContent = it
                    )
                )
            }
            assert(check.isSuccessful)
        }
    }

    @Test
    fun privateKeyToStringFromByteArray() {
        val stringPkey = "80,-73,43,100,-5,-58,-47,-107,27,92,-76,-99,110,7,-127,61,-55,-15,73,-26,59,30,-9,-15,22,70,-3,-69,-110,93,86,47,81,96,-55,-16,10,-32,36,-121,-127,-70,-35,-9,-23,-18,36,127,-121,-81,46,3,96,32,-39,3,44,-40,-48,67,104,-13,-86,-82"
        val bytePkey = byteArrayOf(80, -73, 43, 100, -5, -58, -47, -107, 27, 92, -76, -99, 110, 7, -127, 61, -55, -15, 73, -26, 59, 30, -9, -15, 22, 70, -3, -69, -110, 93, 86, 47, 81, 96, -55, -16, 10, -32, 36, -121, -127, -70, -35, -9, -23, -18, 36, 127, -121, -81, 46, 3, 96, 32, -39, 3, 44, -40, -48, 67, 104, -13, -86, -82)
        assert(bytePkey.joinToString(separator = ",").equals(stringPkey))
    }

    @OptIn(ExperimentalUnsignedTypes::class)
    @Test
    fun encryptionKeyToStringFromByteArray() {
        val stringPkey = "24,67,88,84,203,126,13,172,3,151,80,223,20,146,160,37,143,244,143,243,0,30,183,247,93,25,28,167,85,34,71,129"
        val bytePkey = ubyteArrayOf(24u, 67u, 88u, 84u, 203u, 126u, 13u, 172u, 3u, 151u, 80u, 223u, 20u, 146u, 160u, 37u, 143u, 244u, 143u, 243u, 0u, 30u, 183u, 247u, 93u, 25u, 28u, 167u, 85u, 34u, 71u, 129u)
        assert(
            stringPkey.split(",").map {
                it.toUByte()
            }.toUByteArray().filterIndexed { index, uByte -> uByte != bytePkey[index] }.isEmpty()
        )
    }
}
