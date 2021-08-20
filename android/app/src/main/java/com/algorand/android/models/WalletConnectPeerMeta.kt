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

package com.algorand.android.models

import android.net.Uri
import android.os.Parcelable
import androidx.core.net.toUri
import kotlinx.parcelize.Parcelize

@Parcelize
data class WalletConnectPeerMeta(
    val name: String,
    val url: String,
    val description: String? = null,
    val icons: List<String> = listOf("")
) : Parcelable {

    val peerIconUri: Uri?
        get() = icons.firstOrNull()?.toUri()

    val hasDescription: Boolean
        get() = description != null && description.isNotBlank()
}
