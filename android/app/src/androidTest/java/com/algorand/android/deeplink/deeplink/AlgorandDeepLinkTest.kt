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

import com.algorand.android.deeplink.ALGORAND_BASE_URL
import com.algorand.android.deeplink.ALGORAND_WC_URL
import org.junit.Test

class AlgorandDeepLinkTest : BaseDeepLinkTest() {

    override val baseUrl: String
        get() = ALGORAND_BASE_URL

    override val walletConnectBaseUrl: String
        get() = ALGORAND_WC_URL

    @Test
    override fun isCreatingAddContactDeeplinkWorksTestFunction() {
        assert(isCreatingAddContactDeeplinkWorks())
    }

    @Test
    override fun isCreatingAddWatchAccountDeeplinkWorksTestFunction() {
        assert(isCreatingAddWatchAccountDeeplinkWorks())
    }

    @Test
    override fun isCreatingAssetOptInDeeplinkWorksTestFunction() {
        assert(isCreatingAssetOptInDeeplinkWorks())
    }

    @Test
    override fun isCreatingSendTransactionDeeplinkWorksTestFunction() {
        assert(isCreatingSendTransactionDeeplinkWorks())
    }

    @Test
    override fun isCreatingAlgoTransferDeeplinkWorksTestFunction() {
        assert(isCreatingAlgoTransferDeeplinkWorks())
    }

    @Test
    override fun isCreatingAssetTransferDeeplinkWorksTestFunction() {
        assert(isCreatingAssetTransferDeeplinkWorks())
    }

    @Test
    override fun isCreatingWalletConnectConnectionDeeplinkWorksTestFunction() {
        assert(isCreatingWalletConnectConnectionDeeplinkWorks())
    }

    @Test
    override fun isCreatingMnemonicDeeplinkWorksTestFunction() {
        assert(isCreatingMnemonicDeeplinkWorks())
    }

    @Test
    override fun isCreatingUndefinedDeeplinkWorksTestFunction() {
        assert(isCreatingUndefinedDeeplinkWorks())
    }
}
