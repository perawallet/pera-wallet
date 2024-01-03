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

package com.algorand.android.deeplink.deeplink

import com.algorand.android.deeplink.RAW_MNEMONIC_JSON
import com.algorand.android.modules.deeplink.DeepLinkParser
import com.algorand.android.modules.deeplink.domain.model.BaseDeepLink
import com.algorand.android.modules.deeplink.domain.model.RawDeepLink
import java.math.BigInteger

abstract class BaseDeepLinkTest {

    abstract val baseUrl: String
    abstract val walletConnectBaseUrl: String

    private val publicKey = "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM"
    private val assetId = 226701642L
    private val amount = BigInteger.valueOf(1000000L)
    private val xnote = "Uneditable_1_USDC_Transfer_Note"
    private val note = "Editable_1_USDC_Transfer_Note"
    private val walletConnectUrl =
        "wc:b562a118-0cbd-4f4f-92af-e58bf0a9dfb8@1?bridge=https://wallet-connect-d.perawallet.app&key=672a4fbd212bfdbf6e0c8a858d9ab1577df169e7eac74c7175b9a3fd0faea889"

    private val accountOnlyDeeplink = "$baseUrl$publicKey"
    private val assetOptInDeeplink = "$baseUrl?amount=0&asset=$assetId"
    private val assetTransferDeeplink = "$baseUrl$publicKey?amount=1&asset=$assetId&xnote=$xnote"
    private val algoTransferDeeplink = "$baseUrl$publicKey?amount=$amount&note=$note"
    private val walletConnectDeeplink = "$walletConnectBaseUrl$walletConnectUrl"

    private val deepLinkParser = DeepLinkParser()

    abstract fun isCreatingAddContactDeeplinkWorksTestFunction()
    abstract fun isCreatingAddWatchAccountDeeplinkWorksTestFunction()
    abstract fun isCreatingAssetOptInDeeplinkWorksTestFunction()
    abstract fun isCreatingSendTransactionDeeplinkWorksTestFunction()
    abstract fun isCreatingAlgoTransferDeeplinkWorksTestFunction()
    abstract fun isCreatingAssetTransferDeeplinkWorksTestFunction()
    abstract fun isCreatingWalletConnectConnectionDeeplinkWorksTestFunction()
    abstract fun isCreatingMnemonicDeeplinkWorksTestFunction()
    abstract fun isCreatingUndefinedDeeplinkWorksTestFunction()

    protected fun isCreatingAddContactDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(accountOnlyDeeplink) { rawDeeplink ->
            BaseDeepLink.AccountAddressDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingAddWatchAccountDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(accountOnlyDeeplink) { rawDeeplink ->
            BaseDeepLink.AccountAddressDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingAssetOptInDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(assetOptInDeeplink) { rawDeeplink ->
            BaseDeepLink.AssetOptInDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingSendTransactionDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(accountOnlyDeeplink) { rawDeeplink ->
            BaseDeepLink.AccountAddressDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingAlgoTransferDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(algoTransferDeeplink) { rawDeeplink ->
            BaseDeepLink.AssetTransferDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingAssetTransferDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(assetTransferDeeplink) { rawDeeplink ->
            BaseDeepLink.AssetTransferDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingWalletConnectConnectionDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(walletConnectDeeplink) { rawDeeplink ->
            BaseDeepLink.WalletConnectConnectionDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingMnemonicDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(RAW_MNEMONIC_JSON) { rawDeeplink ->
            BaseDeepLink.MnemonicDeepLink.createDeepLink(rawDeeplink)
        }
    }

    protected fun isCreatingUndefinedDeeplinkWorks(): Boolean {
        return isCreatingDeeplinkWorks(baseUrl) { rawDeeplink ->
            BaseDeepLink.UndefinedDeepLink.create(rawDeeplink)
        }
    }

    private fun isCreatingDeeplinkWorks(
        deeplinkUrl: String,
        createDeeplinkAction: (RawDeepLink) -> BaseDeepLink
    ): Boolean {
        val rawDeeplink = deepLinkParser.parseDeepLink(deeplinkUrl)
        val expectedDeeplink = createDeeplinkAction(rawDeeplink)

        val deeplinkList = BaseDeepLink.create(rawDeeplink)

        return deeplinkList == expectedDeeplink
    }
}
