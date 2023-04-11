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
import androidx.core.text.HtmlCompat
import com.algorand.android.R

fun Context.copyToClipboard(textToCopy: CharSequence, label: String = "", showToast: Boolean = true) {
    val clipboard =
        ContextCompat.getSystemService<ClipboardManager>(this, ClipboardManager::class.java)
    val clip = ClipData.newPlainText(label, textToCopy)
    clipboard?.setPrimaryClip(clip)
    if (showToast) Toast.makeText(this, getString(R.string.copied_to_clipboard), Toast.LENGTH_SHORT).show()
}

// TODO: Delete these extension functions after all clipboard related operations are managed by PeraClipboardModule
//  and move related logic into [PeraClipboardManager] function
fun Context.getTextFromClipboard(): String? {
    val clipboard = ContextCompat.getSystemService(this, ClipboardManager::class.java) ?: return emptyString()
    return clipboard.getTextFromClipboard()
}

fun ClipboardManager.getTextFromClipboard(): String? {
    val firstClip = primaryClip?.getItemAt(0)?.text?.toString().orEmpty()
    return when (getClipboardMimeType(primaryClipDescription)) {
        MIMETYPE_TEXT_PLAIN -> firstClip
        MIMETYPE_TEXT_HTML -> HtmlCompat.fromHtml(firstClip, HtmlCompat.FROM_HTML_MODE_COMPACT).toString()
        else -> null
    }
}

private fun getClipboardMimeType(clipDescription: ClipDescription?): String? {
    return clipDescription?.let { safeClipDescription ->
        when {
            safeClipDescription.hasMimeType(MIMETYPE_TEXT_HTML) -> MIMETYPE_TEXT_HTML
            safeClipDescription.hasMimeType(MIMETYPE_TEXT_PLAIN) -> MIMETYPE_TEXT_PLAIN
            else -> null
        }
    }
}

fun TextView.enableClickToCopy() {
    enableClickToCopy(text.toString())
}

fun View.enableClickToCopy(text: String) {
    setOnClickListener {
        context.copyToClipboard(text)
    }
}

fun TextView.enableLongPressToCopyText() {
    setOnLongClickListener {
        enableLongPressToCopyText(text.toString())
        true
    }
}

fun View.enableLongPressToCopyText(text: String) {
    setOnLongClickListener {
        context.copyToClipboard(text)
        true
    }
}
