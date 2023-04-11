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

const val MNEMONIC_DELIMITER_REGEX = "[, ]+"
const val MNEMONIC_SEPARATOR = " "

fun String.splitMnemonic(): List<String> {
    return this.trim().split(Regex(MNEMONIC_DELIMITER_REGEX))
}

fun List<String>.joinMnemonics(): String {
    return joinToString(MNEMONIC_SEPARATOR)
}
