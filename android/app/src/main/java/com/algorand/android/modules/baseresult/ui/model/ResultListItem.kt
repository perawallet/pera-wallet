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

package com.algorand.android.modules.baseresult.ui.model

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName

sealed class ResultListItem : RecyclerListItem {

    enum class ItemType {
        RESULT_ICON_ITEM,
        RESULT_TITLE_ITEM,
        RESULT_DESCRIPTION_ITEM,
        RESULT_INFO_BOX_ITEM,
        RESULT_ACCOUNT_ITEM
    }

    abstract val itemType: ItemType

    data class IconItem(
        @ColorRes val iconTintColorResId: Int,
        @DrawableRes val iconResId: Int
    ) : ResultListItem() {
        override val itemType: ItemType
            get() = ItemType.RESULT_ICON_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is IconItem && iconResId == other.iconTintColorResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is IconItem && this == other
        }
    }

    sealed class TitleItem : ResultListItem() {

        override val itemType: ItemType
            get() = ItemType.RESULT_TITLE_ITEM

        abstract val titleTextResId: Int

        data class Plural(@PluralsRes override val titleTextResId: Int, val quantity: Int) : TitleItem()

        data class Singular(@StringRes override val titleTextResId: Int) : TitleItem()

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && titleTextResId == other.titleTextResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && this == other
        }
    }

    sealed class DescriptionItem : ResultListItem() {

        override val itemType: ItemType
            get() = ItemType.RESULT_DESCRIPTION_ITEM

        data class Plural(
            val pluralAnnotatedString: PluralAnnotatedString,
            val isClickable: Boolean
        ) : DescriptionItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is Plural && pluralAnnotatedString == other.pluralAnnotatedString
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Plural && this == other
            }
        }

        data class Singular(
            val annotatedString: AnnotatedString,
            val isClickable: Boolean
        ) : DescriptionItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is Singular && annotatedString == other.annotatedString
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Singular && this == other
            }
        }
    }

    sealed class InfoBoxItem : ResultListItem() {

        override val itemType: ItemType
            get() = ItemType.RESULT_INFO_BOX_ITEM

        abstract val infoBoxTintColorResId: Int
        abstract val infoIconResId: Int
        abstract val infoIconTintResId: Int
        abstract val infoTitleTextResId: Int
        abstract val infoTitleTintResId: Int
        abstract val infoDescriptionTintResId: Int

        data class Plural(
            val infoDescriptionPluralAnnotatedString: PluralAnnotatedString,
            @DrawableRes override val infoIconResId: Int,
            @ColorRes override val infoIconTintResId: Int,
            @StringRes override val infoTitleTextResId: Int,
            @ColorRes override val infoTitleTintResId: Int,
            @ColorRes override val infoDescriptionTintResId: Int,
            @ColorRes override val infoBoxTintColorResId: Int
        ) : InfoBoxItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is Plural &&
                    infoDescriptionPluralAnnotatedString == other.infoDescriptionPluralAnnotatedString
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Plural && this == other
            }
        }

        data class Singular(
            val infoDescriptionAnnotatedString: AnnotatedString,
            @DrawableRes override val infoIconResId: Int,
            @ColorRes override val infoIconTintResId: Int,
            @StringRes override val infoTitleTextResId: Int,
            @ColorRes override val infoTitleTintResId: Int,
            @ColorRes override val infoDescriptionTintResId: Int,
            @ColorRes override val infoBoxTintColorResId: Int
        ) : InfoBoxItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is Singular && infoDescriptionAnnotatedString == other.infoDescriptionAnnotatedString
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Singular && this == other
            }
        }
    }

    data class AccountItem(
        val accountDisplayName: AccountDisplayName,
        val accountIconDrawablePreview: AccountIconDrawablePreview,
    ) : ResultListItem() {
        override val itemType: ItemType
            get() = ItemType.RESULT_ACCOUNT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem &&
                accountDisplayName.getRawAccountAddress() == other.accountDisplayName.getRawAccountAddress()
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && this == other
        }
    }
}
