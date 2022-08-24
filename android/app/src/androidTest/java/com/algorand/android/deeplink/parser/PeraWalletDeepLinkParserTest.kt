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

import com.algorand.android.deeplink.PERA_WALLET_BASE_URL
import com.algorand.android.deeplink.PERA_WALLET_WC_URL
import org.junit.Test

class PeraWalletDeepLinkParserTest : BaseDeepLinkParserTest() {

    override val baseUrl: String
        get() = PERA_WALLET_BASE_URL

    override val walletConnectBaseUrl: String
        get() = PERA_WALLET_WC_URL

    @Test
    override fun isParsingDeeplinkWithJustPublicKeyWorksTestFunction() {
        assert(isParsingDeeplinkWithJustPublicKeyWorks())
    }

    @Test
    override fun isParsingDeeplinkWithPublicKeyAndQueryWorksTestFunction() {
        assert(isParsingDeeplinkWithPublicKeyAndQueryWorks())
    }

    @Test
    override fun isParsingWalletConnectUrlWorksTestFunction() {
        assert(isParsingWalletConnectUrlWorks())
    }

    @Test
    override fun isParsingAssetIdWorksTestFunction() {
        assert(isParsingAssetIdWorks())
    }

    @Test
    override fun isParsingAmountWorksTestFunction() {
        assert(isParsingAmountWorks())
    }

    @Test
    override fun isParsingAmountForAssetOptinWorksTestFunction() {
        assert(isParsingAmountForAssetOptinWorks())
    }

    @Test
    override fun isParsingNoteWorksTestFunction() {
        assert(isParsingNoteWorks())
    }

    @Test
    override fun isParsingLockedNoteWorksTestFunction() {
        assert(isParsingLockedNoteWorks())
    }

    @Test
    override fun isParsingWalletConnectUrlWorksForQrCodeTestFunction() {
        assert(isParsingWalletConnectUrlWorksForQrCode())
    }
}
