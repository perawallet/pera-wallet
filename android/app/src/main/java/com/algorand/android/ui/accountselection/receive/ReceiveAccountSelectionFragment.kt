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

package com.algorand.android.ui.accountselection.receive

import android.content.Context
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ReceiveAccountSelectionFragment : BaseAccountSelectionFragment() {

    private var listener: ReceiveAccountSelectionFragmentListener? = null

    override fun onAccountSelected(publicKey: String) {
        navBack()
        listener?.onAccountSelected(publicKey)
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = activity as? ReceiveAccountSelectionFragmentListener
    }

    interface ReceiveAccountSelectionFragmentListener {
        fun onAccountSelected(publicKey: String)
    }
}
