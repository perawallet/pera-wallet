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

package com.algorand.android.modules.webimport.result.ui.model

import androidx.annotation.ColorRes
import androidx.annotation.DimenRes
import androidx.annotation.DrawableRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import com.algorand.android.R
import com.algorand.android.customviews.accountasseticonnameitem.model.AccountAssetIconNameConfiguration
import com.algorand.android.models.RecyclerListItem

abstract class BaseAccountResultListItem : RecyclerListItem {

    enum class ItemType {
        IMAGE,
        TEXT,
        WARNING_BOX,
        ACCOUNT
    }

    abstract val itemType: ItemType

    data class ImageItem(
        @DrawableRes val drawableResId: Int,
        @DimenRes val width: Int,
        @DimenRes val height: Int,
        @ColorRes val drawableTintResId: Int? = null
    ) : BaseAccountResultListItem() {

        override val itemType
            get() = ItemType.IMAGE

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ImageItem &&
                drawableResId == other.drawableResId &&
                drawableTintResId == other.drawableTintResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ImageItem && other == this
        }
    }

    data class TextItem(
        @StringRes @PluralsRes
        val textResId: Int,
        val textIntParam: Int? = null,
        @StyleRes val textAppearanceResId: Int = R.style.TextAppearance_Body,
        @ColorRes val textColorResId: Int? = null
    ) : BaseAccountResultListItem() {

        override val itemType
            get() = ItemType.TEXT

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TextItem && textResId == other.textResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TextItem && other == this
        }
    }

    data class WarningBoxItem(
        @StringRes val titleResId: Int,
        @StringRes @PluralsRes
        val descriptionResId: Int,
        @DrawableRes val iconResId: Int,
        val textIntParam: Int? = null,
        @StyleRes val titleTextAppearanceResId: Int = R.style.TextAppearance_Body,
        @StyleRes val descriptionTextAppearanceResId: Int = R.style.TextAppearance_Body,
        @ColorRes val iconColorResId: Int? = null,
        @ColorRes val backgroundColorResId: Int? = null,
        @ColorRes val textColorResId: Int? = null
    ) : BaseAccountResultListItem() {

        override val itemType
            get() = ItemType.WARNING_BOX

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is WarningBoxItem && titleResId == other.titleResId &&
                descriptionResId == other.descriptionResId &&
                iconResId == other.iconResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is WarningBoxItem && other == this
        }
    }

    data class AccountItem(
        val address: String,
        val accountAssetIconNameConfiguration: AccountAssetIconNameConfiguration
    ) : BaseAccountResultListItem() {
        override val itemType
            get() = ItemType.ACCOUNT

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && address == other.address
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && other == this
        }
    }
}
