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

package com.algorand.android.utils

import android.util.Base64
import com.google.crypto.tink.Aead

const val KEYSET_HANDLE = "ALGORAND_KEYSET"
const val ENCRYPTED_SHARED_PREF_NAME = "ALGORAND_ENCR_ACCOUNTS"
const val ALGORAND_KEYSTORE_URI = "android-keystore://algorand_keystore_key"

fun Aead.encryptString(value: String?): String? {
    return try {
        if (value == null) {
            null
        } else {
            Base64.encodeToString(encrypt(value.toByteArray(Charsets.UTF_8), null), Base64.DEFAULT)
        }
    } catch (exception: Exception) {
        exception.printStackTrace()
        null
    }
}

fun Aead.decrpytString(value: String?): String? {
    return try {
        if (value == null) {
            null
        } else {
            String(decrypt(Base64.decode(value, Base64.DEFAULT), null), Charsets.UTF_8)
        }
    } catch (exception: Exception) {
        exception.printStackTrace()
        null
    }
}
