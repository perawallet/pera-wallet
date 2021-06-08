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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.appcompat.content.res.AppCompatResources
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomCollapsibleAccountViewBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding

class CollapsibleAccountView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var collapsedListSize = DEFAULT_COLLAPSED_LIST_SIZE

    private val binding = viewBinding(CustomCollapsibleAccountViewBinding::inflate)

    init {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(
            resources.getDimensionPixelOffset(R.dimen.smallshadow_start_padding_4dp),
            resources.getDimensionPixelOffset(R.dimen.smallshadow_top_padding_4dp),
            resources.getDimensionPixelOffset(R.dimen.smallshadow_end_padding_4dp),
            resources.getDimensionPixelOffset(R.dimen.smallshadow_bottom_padding_4dp)
        )
        initAttributes(attrs)
    }

    fun setAccountBalanceInformation(name: String, accountIconResId: Int, assetsInformation: List<AssetInformation>) {
        setupHeader(name, accountIconResId)
        setupAssets(assetsInformation)
    }

    fun setAccountBalanceInformation(accountCacheData: AccountCacheData) {
        val accountIconResId = accountCacheData.getImageResource()
        val accountName = accountCacheData.account.name
        setupHeader(accountName, accountIconResId)
        setupAssets(accountCacheData.assetsInformation)
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.CollapsibleAccountView).use {
            collapsedListSize =
                it.getInt(R.styleable.CollapsibleAccountView_collapsedListSize, DEFAULT_COLLAPSED_LIST_SIZE)
        }
    }

    private fun setupHeader(name: String, accountIconResId: Int) {
        binding.collapsibleAccountTextView.apply {
            setDrawable(start = AppCompatResources.getDrawable(context, accountIconResId))
            text = name
        }
    }

    private fun setupAssets(assetInformationList: List<AssetInformation>) {
        val collapsedAssets = mutableListOf<AssetInformation>()
        assetInformationList.forEachIndexed { index, assetInformation ->
            if (index + 1 > collapsedListSize) {
                collapsedAssets.add(assetInformation)
            } else {
                addAssetBalanceView(assetInformation, addDividerToTop = index != 0)
            }
        }
        setActionButton(collapsedAssets)
    }

    private fun setActionButton(collapsedAssets: List<AssetInformation>) {
        if (collapsedAssets.isEmpty()) {
            return
        }
        binding.collapsibleActionButton.apply {
            text = resources.getString(R.string.plus_more_assets, collapsedAssets.count())
            setOnClickListener {
                visibility = View.GONE
                collapsedAssets.forEach { assetInformation -> addAssetBalanceView(assetInformation) }
            }
            visibility = View.VISIBLE
        }
    }

    private fun addAssetBalanceView(assetInformation: AssetInformation, addDividerToTop: Boolean = true) {
        binding.collapsibleAccountAssetBalanceLayout.addAssetBalanceView(
            assetInformation,
            addDividerToTop = addDividerToTop
        )
    }

    companion object {
        private const val DEFAULT_COLLAPSED_LIST_SIZE = Int.MAX_VALUE
    }
}
