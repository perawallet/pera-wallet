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

package com.algorand.android.deeplink.parser

import com.algorand.android.deeplink.RANDOM_MNEMONIC
import com.algorand.android.deeplink.RAW_MNEMONIC_JSON
import com.algorand.android.modules.deeplink.DeepLinkParser
import com.algorand.android.modules.deeplink.domain.model.RawDeepLink
import org.junit.Test

class MnemonicParserTest {

    private val parser = DeepLinkParser()

    @Test
    fun isParsingMnemonicWorks() {
        val expectedDeeplink = RawDeepLink(
            mnemonic = RANDOM_MNEMONIC
        )

        val parsedDeeplink = parser.parseDeepLink(RAW_MNEMONIC_JSON)

        assert(expectedDeeplink == parsedDeeplink)
    }
}
