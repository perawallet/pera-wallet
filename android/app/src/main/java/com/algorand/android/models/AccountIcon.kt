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
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.models.Account.Companion.defaultAccountIconColor
import com.algorand.android.models.Account.Companion.defaultAccountType
import kotlinx.parcelize.Parcelize

@Parcelize
data class AccountIcon private constructor(
    @ColorRes val backgroundColorResId: Int,
    @ColorRes val iconTintResId: Int,
    @DrawableRes val iconDrawable: Int,
) : Parcelable {

    companion object {
        @DrawableRes
        private val DEFAULT_ACCOUNT_ICON_RES = defaultAccountType.iconResId
        private val DEFAULT_ACCOUNT_ICON_BG_COLOR = defaultAccountIconColor.backgroundColorResId
        private val DEFAULT_ACCOUNT_ICON_TINT_COLOR = defaultAccountIconColor.iconTintResId

        fun create(
            accountIconColor: Account.AccountIconColor?,
            @DrawableRes iconDrawable: Int?,
        ): AccountIcon {
            return AccountIcon(
                backgroundColorResId = accountIconColor?.backgroundColorResId ?: DEFAULT_ACCOUNT_ICON_BG_COLOR,
                iconTintResId = accountIconColor?.iconTintResId ?: DEFAULT_ACCOUNT_ICON_TINT_COLOR,
                iconDrawable = iconDrawable ?: DEFAULT_ACCOUNT_ICON_RES,
            )
        }
    }
}
