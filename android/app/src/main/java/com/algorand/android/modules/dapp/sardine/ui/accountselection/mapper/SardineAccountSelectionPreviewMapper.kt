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

package com.algorand.android.modules.dapp.sardine.ui.accountselection.mapper

import com.algorand.android.modules.dapp.sardine.ui.accountselection.SardineAccountSelectionFragmentDirections
import com.algorand.android.modules.dapp.sardine.ui.accountselection.model.SardineAccountSelectionPreview
import com.algorand.android.modules.dapp.sardine.ui.getFullSardineUrl
import com.algorand.android.utils.Event
import javax.inject.Inject

class SardineAccountSelectionPreviewMapper @Inject constructor() {

    fun mapToInitialPreview(): SardineAccountSelectionPreview {
        return SardineAccountSelectionPreview()
    }

    fun mapToAccountSelectedPreview(
        previousState: SardineAccountSelectionPreview,
        accountAddress: String,
        isMainnet: Boolean
    ): SardineAccountSelectionPreview {
        return previousState.copy(
            finalizeAccountSelectionEvent = Event(
                SardineAccountSelectionFragmentDirections
                    .actionSardineAccountSelectionFragmentToSardineBrowserFragment(
                        url = getFullSardineUrl(accountAddress, isMainnet)
                    )
            )
        )
    }
}
