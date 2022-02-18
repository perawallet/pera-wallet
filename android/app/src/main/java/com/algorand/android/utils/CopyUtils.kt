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

package com.algorand.android.utils

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipDescription.MIMETYPE_TEXT_HTML
import android.content.ClipDescription.MIMETYPE_TEXT_PLAIN
import android.content.ClipboardManager
import android.content.Context
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.algorand.android.R

fun Context.copyToClipboard(textToCopy: CharSequence, label: String = "") {
    val clipboard =
        ContextCompat.getSystemService<ClipboardManager>(this, ClipboardManager::class.java)
    val clip = ClipData.newPlainText(label, textToCopy)
    clipboard?.setPrimaryClip(clip)
    Toast.makeText(this, getString(R.string.copied_to_clipboard), Toast.LENGTH_SHORT).show()
}

fun Context.getTextFromClipboard(): CharSequence {
    val clipboard = ContextCompat.getSystemService(this, ClipboardManager::class.java)
    return clipboard.getTextFromClipboard()
}

fun ClipboardManager?.getTextFromClipboard(): CharSequence {
    return when {
        this == null -> ""
        hasPrimaryClip().not() -> ""
        isClipDescriptionMimeTypeValid(primaryClipDescription) -> primaryClip?.getItemAt(0)?.text ?: ""
        else -> ""
    }
}

private fun isClipDescriptionMimeTypeValid(clipDescription: ClipDescription?): Boolean {
    return clipDescription?.let {
        it.hasMimeType(MIMETYPE_TEXT_PLAIN) || it.hasMimeType(MIMETYPE_TEXT_HTML)
    } ?: false
}

fun TextView.enableClickToCopy() {
    enableClickToCopy(text.toString())
}

fun View.enableClickToCopy(text: String) {
    setOnClickListener {
        context.copyToClipboard(text)
    }
}
