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

package com.algorand.android.ui.send.transferamount

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetAddNoteBinding
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding

class AddNoteBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_add_note) {

    private val binding by viewBinding(BottomSheetAddNoteBinding::bind)

    private val args by navArgs<AddNoteBottomSheetArgs>()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.add_note,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        configureInputLayout()
    }

    private fun configureInputLayout() {
        binding.noteInputLayout.apply {
            text = args.note.orEmpty()
            addByteLimiter(NOTE_MAX_SIZE_IN_BYTE)
            // If transaction note is xnote(locked note) then we should non-editable this area
            if (!args.isInputFieldEnabled) {
                setAsNonFocusable()
                return
            }
            requestFocus()
        }
    }

    private fun configureToolbar() {
        binding.toolbar.apply {
            configure(toolbarConfiguration)
            addButtonToEnd(TextButton(stringResId = R.string.done, onClick = ::onDoneClick))
        }
    }

    private fun onDoneClick() {
        setNavigationResult(ADD_NOTE_RESULT_KEY, binding.noteInputLayout.text)
        navBack()
    }

    companion object {
        private const val NOTE_MAX_SIZE_IN_BYTE = 1024
        const val ADD_NOTE_RESULT_KEY = "add_note_result"
    }
}
