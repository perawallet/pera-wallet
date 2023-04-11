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

package com.algorand.android.utils.extensions

import android.util.Base64
import java.nio.charset.StandardCharsets

fun String.encodeBase64(): String? {
    return try {
        Base64.encodeToString(toByteArray(StandardCharsets.UTF_8), Base64.NO_WRAP)
    } catch (exception: Exception) {
        null
    }
}

fun ByteArray.encodeBase64(): String? {
    return try {
        Base64.encodeToString(this, Base64.NO_WRAP)
    } catch (exception: Exception) {
        null
    }
}

fun String.decodeBase64ToByteArray(): ByteArray? {
    return try {
        Base64.decode(this, Base64.NO_WRAP)
    } catch (exception: Exception) {
        null
    }
}

fun ByteArray.decodeBase64ToByteArray(): ByteArray? {
    return try {
        Base64.decode(this, Base64.NO_WRAP)
    } catch (exception: Exception) {
        null
    }
}

fun String.decodeBase64ToString(): String? {
    return try {
        val stringInByteArray = Base64.decode(this, Base64.NO_WRAP)
        String(stringInByteArray, Charsets.UTF_8)
    } catch (exception: Exception) {
        null
    }
}

fun ByteArray.decodeBase64ToString(): String? {
    return try {
        val stringInByteArray = Base64.decode(this, Base64.NO_WRAP)
        String(stringInByteArray, Charsets.UTF_8)
    } catch (exception: Exception) {
        null
    }
}
