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

package com.algorand.android.models

import android.os.Parcelable
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.ui.qr.QrCodeScannerFragment
import kotlinx.parcelize.Parcelize

@Parcelize
data class QrScanner(
    val scanTypes: Array<QrCodeScannerFragment.ScanReturnType>,
    val isShowingWCSessionsButton: Boolean = false,
    @StringRes val titleRes: Int = R.string.find_a_code_to_scan
) : Parcelable
