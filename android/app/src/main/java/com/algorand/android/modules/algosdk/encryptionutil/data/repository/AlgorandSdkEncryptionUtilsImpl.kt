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

package com.algorand.android.modules.algosdk.encryptionutil.data.repository

import com.algorand.algosdk.mobile.Mobile
import com.algorand.android.modules.algosdk.encryptionutil.domain.repository.AlgorandSdkEncryptionUtils
import com.algorand.android.utils.SDK_RESULT_SUCCESS
import com.algorand.android.utils.extensions.decodeBase64ToByteArray
import com.algorand.android.utils.extensions.encodeBase64

class AlgorandSdkEncryptionUtilsImpl : AlgorandSdkEncryptionUtils {

    override fun encryptContent(content: ByteArray, key: ByteArray): String? {
        return try {
            val encryption = Mobile.encrypt(content, key)
            return if (encryption.errorCode == SDK_RESULT_SUCCESS) {
                encryption.encryptedData.encodeBase64()
            } else {
                null
            }
        } catch (exception: Exception) {
            null
        }
    }

    override fun decryptContent(encryptedContent: String, key: ByteArray): String? {
        return try {
            val decodedContent = encryptedContent.decodeBase64ToByteArray()
            val decryption = Mobile.decrypt(decodedContent, key)
            return if (decryption.errorCode == SDK_RESULT_SUCCESS) {
                String(decryption.decryptedData)
            } else {
                null
            }
        } catch (exception: Exception) {
            null
        }
    }
}
