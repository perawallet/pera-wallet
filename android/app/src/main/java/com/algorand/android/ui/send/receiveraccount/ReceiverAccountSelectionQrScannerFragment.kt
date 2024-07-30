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

package com.algorand.android.ui.send.receiveraccount

import com.algorand.android.R
import com.algorand.android.models.AssetTransaction
import com.algorand.android.modules.deeplink.domain.model.BaseDeepLink
import com.algorand.android.modules.qrscanning.BaseQrScannerFragment
import com.algorand.android.utils.setNavigationResult

class ReceiverAccountSelectionQrScannerFragment : BaseQrScannerFragment(
    R.id.receiverAccountSelectionQrScannerFragment
) {

    override val titleTextResId: Int
        get() = R.string.scan_an_algorand

    override fun onDeepLinkNotHandled(deepLink: BaseDeepLink) {
        showGlobalError(getString(R.string.the_scanned_qr_is_not))
    }

    override fun onAccountAddressDeeplink(accountAddress: String, label: String?): Boolean {
        setNavigationResult(ACCOUNT_ADDRESS_SCAN_RESULT_KEY, accountAddress)
        return true.also { navBack() }
    }

    override fun onAssetTransferDeepLink(assetTransaction: AssetTransaction): Boolean {
        setNavigationResult(ACCOUNT_ADDRESS_SCAN_RESULT_KEY, assetTransaction.receiverUser?.publicKey)
        return true.also { navBack() }
    }

    companion object {
        const val ACCOUNT_ADDRESS_SCAN_RESULT_KEY = "account_address_scan_result_key"
    }
}
