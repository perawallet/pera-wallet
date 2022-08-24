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

package com.algorand.android.customviews.accountandassetitem.assetitem

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.customviews.accountandassetitem.BaseAccountAndAssetItemView
import com.algorand.android.models.BaseItemConfiguration
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

class AssetItemView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : BaseAccountAndAssetItemView<BaseItemConfiguration.AssetItemConfiguration>(context, attrs) {

    private val assetItemAction = object : AssetItemAction {
        override fun initAssetIconDrawable(assetDrawableProvider: BaseAssetDrawableProvider?, assetName: AssetName?) {
            val isAssetIconDrawableVisible = assetDrawableProvider != null
            if (assetDrawableProvider == null || assetName == null) return
            binding.iconImageView.apply {
                isVisible = isAssetIconDrawableVisible
                val assetDrawable = assetDrawableProvider.provideAssetDrawable(context, assetName)
                setImageDrawable(assetDrawable)
            }
        }

        override fun initPrimaryAssetName(assetName: AssetName?) {
            val isPrimaryAssetNameVisible = assetName != null
            if (assetName == null) return
            binding.titleTextView.apply {
                isVisible = isPrimaryAssetNameVisible
                text = assetName.getName(resources)
            }
        }

        override fun initSecondaryAssetName(assetName: AssetName?, assetId: Long) {
            val isSecondaryAssetNameVisible = assetName != null
            if (assetName == null) return
            binding.descriptionTextView.apply {
                isVisible = isSecondaryAssetNameVisible
                text = resources.getString(R.string.pair_value_format_with_coma, assetName.getName(resources), assetId)
            }
        }

        override fun initSecondaryAssetName(assetName: AssetName?) {
            val isSecondaryAssetNameVisible = assetName != null
            if (assetName == null) return
            binding.descriptionTextView.apply {
                isVisible = isSecondaryAssetNameVisible
                text = assetName.getName(resources)
            }
        }

        override fun initItemStatusDrawable(itemStatusDrawable: Drawable?) {
            val isItemStatusDrawableVisible = itemStatusDrawable != null
            if (itemStatusDrawable == null) return
            binding.itemStatusImageView.apply {
                isVisible = isItemStatusDrawableVisible
                setImageDrawable(itemStatusDrawable)
            }
        }

        override fun initVerifiedStatusDrawable(isVerified: Boolean?) {
            if (isVerified != true) return
            val itemStatusDrawable = ContextCompat.getDrawable(context, R.drawable.ic_asa_verified)
            initItemStatusDrawable(itemStatusDrawable)
        }
    }

    override fun initItemView(itemConfig: BaseItemConfiguration.AssetItemConfiguration) {
        with(itemConfig) {
            with(assetItemAction) {
                initAssetIconDrawable(assetIconDrawableProvider, primaryAssetName)
                initPrimaryAssetName(primaryAssetName)
                initItemStatusDrawable(itemStatusDrawable)
                initVerifiedStatusDrawable(isVerified)
                if (showWithAssetId == true) {
                    initSecondaryAssetName(secondaryAssetName, assetId)
                } else {
                    initSecondaryAssetName(secondaryAssetName)
                }
            }
            initPrimaryValue(primaryValueText)
            initSecondaryValue(secondaryValueText)
            initActionButton(actionButtonConfiguration)
            initCheckButton(checkButtonConfiguration)
            initDragButton(dragButtonConfiguration)
        }
    }
}
