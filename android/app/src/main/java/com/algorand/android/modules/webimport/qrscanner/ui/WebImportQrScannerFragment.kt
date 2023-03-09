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

package com.algorand.android.modules.webimport.qrscanner.ui

import com.algorand.android.R
import com.algorand.android.modules.qrscanning.BaseQrScannerFragment
import com.algorand.android.modules.webimport.common.data.model.WebImportQrCode
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WebImportQrScannerFragment : BaseQrScannerFragment(R.id.accountsQrScannerFragment) {

    override val titleTextResId: Int
        get() = R.string.scan_qr_code_on_web

    override fun onWebImportQrCodeDeepLink(webImportQrCode: WebImportQrCode): Boolean {
        return true.also {
            nav(
                WebImportQrScannerFragmentDirections
                    .actionWebImportQrScannerFragmentToWebImportLoadingFragment(webImportQrCode)
            )
        }
    }
}
