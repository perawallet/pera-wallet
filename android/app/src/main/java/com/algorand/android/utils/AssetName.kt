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

import android.content.res.Resources
import android.os.Parcelable
import com.algorand.android.R
import com.algorand.android.utils.extensions.formatAsAvatarTextOrThrow
import java.util.Locale
import kotlinx.parcelize.Parcelize

@Parcelize
class AssetName private constructor(
    private val assetName: String?,
    private val assetNameResId: Int = DEFAULT_ASSET_NAME_RES_ID
) : Parcelable {

    /**
     * Checks if asset name is null or blank.
     * If null or blank, returns DEFAULT_ASSET_NAME_RES_ID as string value which is "Unnamed"
     */
    fun getName(resource: Resources): String {
        return assetName.takeIf { !it.isNullOrBlank() } ?: resource.getString(assetNameResId)
    }

    /**
     * Returns null if it is null or blank. Otherwise returns name.
     */
    fun getName(): String? {
        return assetName.takeIf { it?.isNotBlank() == true }
    }

    fun getAsAvatarNameOrDefault(resource: Resources): String {
        return try {
            getName(resource).formatAsAvatarTextOrThrow(ASSET_AVATAR_MAX_LETTER_COUNT)
        } catch (exception: Exception) {
            resource.getString(assetNameResId).formatAsAvatarTextOrThrow(ASSET_AVATAR_MAX_LETTER_COUNT)
        }
    }

    companion object {

        const val DEFAULT_ASSET_NAME_RES_ID = R.string.unnamed
        private const val ASSET_AVATAR_MAX_LETTER_COUNT = 3

        fun create(assetName: String?): AssetName {
            return AssetName(assetName)
        }

        fun createShortName(assetName: String?): AssetName {
            val formattedAssetName = assetName?.uppercase(Locale.ENGLISH)
            return AssetName(formattedAssetName)
        }

        fun create(assetNameResId: Int?): AssetName {
            return AssetName(null, assetNameResId ?: R.string.unnamed)
        }
    }
}
