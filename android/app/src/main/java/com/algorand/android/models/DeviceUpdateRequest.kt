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

import com.google.gson.annotations.SerializedName
import java.util.Locale

data class DeviceUpdateRequest(
    @SerializedName("id") val id: String? = null,
    @SerializedName("push_token") val pushToken: String,
    @SerializedName("accounts") val accountPublicKeys: List<String>,
    @SerializedName("application") val application: String,
    @SerializedName("platform") val platform: String = "android",
    @SerializedName("locale") val locale: String = Locale.getDefault().language ?: Locale.ENGLISH.language
)
