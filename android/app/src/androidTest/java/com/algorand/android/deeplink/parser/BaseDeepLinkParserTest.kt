@file:Suppress("MaxLineLength")
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

import com.algorand.android.modules.deeplink.DeepLinkParser
import java.math.BigInteger

abstract class BaseDeepLinkParserTest {

    abstract val baseUrl: String
    abstract val walletConnectBaseUrl: String

    private val publicKey = "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM"
    private val assetId = 226701642L
    private val amount = BigInteger.valueOf(1000000L)
    private val xnote = "Uneditable_1_USDC_Transfer_Note"
    private val note = "Editable_1_USDC_Transfer_Note"
    private val walletConnectUrl = "wc:b562a118-0cbd-4f4f-92af-e58bf0a9dfb8@1?bridge=https://wallet-connect-d.perawallet.app&key=672a4fbd212bfdbf6e0c8a858d9ab1577df169e7eac74c7175b9a3fd0faea889"

    private val parser: DeepLinkParser = DeepLinkParser()

    private val accountOnlyDeeplink = "$baseUrl$publicKey"
    private val assetOptInDeeplink = "$baseUrl?amount=0&asset=$assetId"
    private val assetTransferDeeplink = "$baseUrl$publicKey?amount=1&asset=$assetId&xnote=$xnote"
    private val algoTransferDeeplink = "$baseUrl$publicKey?amount=$amount&note=$note"
    private val accountAndQueryDeeplink = "$baseUrl$publicKey?amount=1&asset=$assetId"
    private val walletConnectDeeplink = "$walletConnectBaseUrl$walletConnectUrl"

    abstract fun isParsingDeeplinkWithJustPublicKeyWorksTestFunction()
    abstract fun isParsingDeeplinkWithPublicKeyAndQueryWorksTestFunction()
    abstract fun isParsingWalletConnectUrlWorksTestFunction()
    abstract fun isParsingWalletConnectUrlWorksForQrCodeTestFunction()
    abstract fun isParsingAssetIdWorksTestFunction()
    abstract fun isParsingAmountWorksTestFunction()
    abstract fun isParsingAmountForAssetOptinWorksTestFunction()
    abstract fun isParsingNoteWorksTestFunction()
    abstract fun isParsingLockedNoteWorksTestFunction()

    protected fun isParsingDeeplinkWithJustPublicKeyWorks(): Boolean {
        return publicKey == parser.parseDeepLink(accountOnlyDeeplink).accountAddress
    }

    protected fun isParsingDeeplinkWithPublicKeyAndQueryWorks(): Boolean {
        return publicKey == parser.parseDeepLink(accountAndQueryDeeplink).accountAddress
    }

    protected fun isParsingWalletConnectUrlWorks(): Boolean {
        return walletConnectUrl == parser.parseDeepLink(walletConnectDeeplink).walletConnectUrl
    }

    protected fun isParsingAssetIdWorks(): Boolean {
        return assetId == parser.parseDeepLink(assetOptInDeeplink).assetId
    }

    protected fun isParsingAmountWorks(): Boolean {
        return amount.equals(parser.parseDeepLink(algoTransferDeeplink).amount)
    }

    protected fun isParsingAmountForAssetOptinWorks(): Boolean {
        val amount = BigInteger.ZERO
        val parsedAmount = parser.parseDeepLink(assetOptInDeeplink).amount
        return amount.equals(parsedAmount)
    }

    protected fun isParsingNoteWorks(): Boolean {
        return note == parser.parseDeepLink(algoTransferDeeplink).note
    }

    protected fun isParsingLockedNoteWorks(): Boolean {
        return xnote == parser.parseDeepLink(assetTransferDeeplink).xnote
    }

    protected fun isParsingWalletConnectUrlWorksForQrCode(): Boolean {
        return walletConnectUrl == parser.parseDeepLink(walletConnectUrl).walletConnectUrl
    }
}
