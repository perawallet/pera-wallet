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

package com.algorand.android.modules.walletconnectfallbackbrowser.ui

import android.widget.TextView
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserListItem
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectTransactionConfirmedSingleBrowserBottomSheet : BaseWalletConnectSingleBrowserFallbackBottomSheet() {

    val args by navArgs<WalletConnectTransactionConfirmedSingleBrowserBottomSheetArgs>()

    override val browserItem: FallbackBrowserListItem
        get() = args.browserItem

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.transaction_signed)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.text = getString(R.string.transaction_was_sent, args.peerMetaName)
    }
}
