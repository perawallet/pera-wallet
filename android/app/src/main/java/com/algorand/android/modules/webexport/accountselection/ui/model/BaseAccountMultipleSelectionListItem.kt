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
 */

package com.algorand.android.modules.webexport.accountselection.ui.model

import androidx.annotation.ColorRes
import androidx.annotation.DimenRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import com.algorand.android.R
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.customviews.accountasseticonnameitem.model.AccountAssetIconNameConfiguration
import com.algorand.android.models.RecyclerListItem

abstract class BaseAccountMultipleSelectionListItem : RecyclerListItem {

    enum class ItemType {
        TEXT,
        HEADER,
        ACCOUNT
    }

    abstract val itemType: ItemType
    abstract val topMarginResId: Int?

    data class TextItem(
        @StringRes val textResId: Int,
        @StyleRes val textAppearanceResId: Int = R.style.TextAppearance_Body,
        @ColorRes val textColorRestId: Int? = null,
        @DimenRes override val topMarginResId: Int? = null
    ) : BaseAccountMultipleSelectionListItem() {

        override val itemType
            get() = ItemType.TEXT

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TextItem && textResId == other.textResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TextItem && other == this
        }
    }

    data class HeaderItem(
        @PluralsRes val titleRes: Int,
        val accountCount: Int,
        val checkboxState: TriStatesCheckBox.CheckBoxState,
        @DimenRes override val topMarginResId: Int? = null
    ) : BaseAccountMultipleSelectionListItem() {

        override val itemType
            get() = ItemType.HEADER

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && titleRes == other.titleRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && other == this
        }
    }

    data class AccountItem(
        val address: String,
        val accountAssetIconNameConfiguration: AccountAssetIconNameConfiguration,
        val isChecked: Boolean,
        override val topMarginResId: Int?
    ) : BaseAccountMultipleSelectionListItem() {
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
