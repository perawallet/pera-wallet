/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectNoteCardBinding
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectNoteCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectNoteCardBinding::inflate)

    init {
        initRootLayout()
    }

    fun initNoteInfo(noteInfo: TransactionRequestNoteInfo?) {
        if (noteInfo == null) return
        with(noteInfo) {
            initNote(note)
            initMetadataHash(assetMetadata)
        }
    }

    private fun initNote(note: String?) {
        with(binding) {
            noteTextView.text = note
            noteGroup.isVisible = !note.isNullOrBlank()
        }
    }

    private fun initMetadataHash(metadataHash: String?) {
        with(binding) {
            metadataHashGroup.isVisible = !metadataHash.isNullOrBlank()
            metadataHashTextView.text = metadataHash
        }
    }

    private fun initRootLayout() {
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_large))
    }
}
