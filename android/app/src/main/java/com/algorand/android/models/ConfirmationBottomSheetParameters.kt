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

package com.algorand.android.models

import android.os.Parcelable
import com.algorand.android.R
import kotlinx.parcelize.Parcelize

@Parcelize
data class ConfirmationBottomSheetParameters(
    val confirmationIdentifier: Long, // This field will be used as unique identifier for confirmation request
    val titleResId: Int,
    val descriptionText: String,
    val iconDrawableResId: Int = R.drawable.ic_info,
    val imageTintResId: Int = R.color.negative,
    val confirmButtonTextResId: Int = R.string.accept,
    val rejectButtonTextResId: Int = R.string.cancel
) : Parcelable
