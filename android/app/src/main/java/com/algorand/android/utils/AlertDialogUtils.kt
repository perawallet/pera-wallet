/*
 * Copyright 2019 Algorand, Inc.
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

import android.content.Context
import androidx.appcompat.app.AlertDialog
import com.algorand.android.R

inline fun Context.alertDialog(dialogConfig: AlertDialog.Builder.() -> Unit): AlertDialog {
    return AlertDialog.Builder(this)
        .apply(dialogConfig)
        .create()
}

fun Context.showAlertDialog(title: String, message: String?) {
    AlertDialog.Builder(this)
        .setTitle(title)
        .setPositiveButton(R.string.ok) { dialog, _ -> dialog.dismiss() }
        .apply {
            if (message != null) {
                setMessage(message)
            } else {
                setMessage(R.string.an_error_occured)
            }
        }.show()
}

fun Context.showLedgerScanErrorDialog() {
    alertDialog {
        setTitle(R.string.error_connection_title)
        setMessage(R.string.having_ledger_nano_connection)
        setPositiveButton(R.string.ok) { dialog, _ -> dialog.dismiss() }
    }.show()
}
