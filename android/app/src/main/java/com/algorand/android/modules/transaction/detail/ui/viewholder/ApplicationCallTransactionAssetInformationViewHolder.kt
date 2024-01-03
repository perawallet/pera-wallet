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

package com.algorand.android.modules.transaction.detail.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.databinding.ItemTransactionApplicationCallAssetInformationBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.domain.usecase.ApplicationCallTransactionDetailPreviewUseCase.Companion.MAX_ASSET_COUNT_TO_SHOW
import com.algorand.android.modules.transaction.detail.ui.model.ApplicationCallAssetInformation
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.setAssetNameTextColorByVerificationTier
import com.algorand.android.utils.setDrawable

class ApplicationCallTransactionAssetInformationViewHolder(
    private val binding: ItemTransactionApplicationCallAssetInformationBinding,
    private val listener: ApplicationCallTransactionAssetInformationListener
) : BaseViewHolder<TransactionDetailItem>(binding.root) {

    private val assetIdsOfCreatedViews = mutableSetOf<Long>()

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.ApplicationCallItem.AppCallAssetInformationItem) return
        binding.assetLabelTextView.text = binding.root.resources.getQuantityString(
            item.labelTextRes,
            item.assetInformationList.count(),
            item.assetInformationList.count()
        )
        initAssetsInformationGroup(item.assetInformationList, item.showMoreButton, item.showMoreAssetCount)
    }

    private fun initAssetsInformationGroup(
        assetInformationList: List<ApplicationCallAssetInformation>,
        showMoreButton: Boolean,
        showMoreAssetCount: Int
    ) {
        with(binding.assetInformationLinearLayout) {
            assetInformationList.take(MAX_ASSET_COUNT_TO_SHOW)
                .filterNot { assetIdsOfCreatedViews.contains(it.assetId) }
                .forEach {
                    addView(
                        inflatePrimaryTextView(it.assetFullName, it.verificationTierConfiguration),
                        ViewGroup.LayoutParams(
                            ViewGroup.LayoutParams.WRAP_CONTENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                        )
                    )
                    addView(inflateSecondaryTextView(it.assetId, it.assetShortName))
                    assetIdsOfCreatedViews.add(it.assetId)
                }
        }
        initShowMoreButton(assetInformationList, showMoreButton, showMoreAssetCount)
    }

    private fun inflatePrimaryTextView(
        assetName: AssetName,
        verificationTierConfiguration: VerificationTierConfiguration
    ): AppCompatTextView {
        return AppCompatTextView(binding.root.context).apply {
            text = assetName.getName(resources)
            changeTextAppearance(R.style.TextAppearance_Body_Sans)
            updatePadding(top = resources.getDimensionPixelSize(R.dimen.spacing_small))
            compoundDrawablePadding = resources.getDimensionPixelSize(R.dimen.spacing_xsmall)
            with(verificationTierConfiguration) {
                setDrawable(end = drawableResId?.run { AppCompatResources.getDrawable(context, this) })
                setAssetNameTextColorByVerificationTier(this)
            }
        }
    }

    private fun inflateSecondaryTextView(assetId: Long, assetName: AssetName): AppCompatTextView {
        return AppCompatTextView(binding.root.context).apply {
            text = context.getString(
                R.string.pair_value_format_with_coma,
                assetName.getName(resources),
                assetId
            )
            changeTextAppearance(R.style.TextAppearance_Footnote_Sans)
            setTextColor(ContextCompat.getColor(context, R.color.text_gray_lighter))
            updatePadding(top = resources.getDimensionPixelSize(R.dimen.spacing_xxxsmall))
        }
    }

    private fun initShowMoreButton(
        assetInformationList: List<ApplicationCallAssetInformation>,
        showMoreButton: Boolean,
        showMoreAssetCount: Int
    ) {
        binding.showMoreButton.apply {
            isVisible = showMoreButton
            text = resources.getQuantityString(
                R.plurals.show_count_more_assets,
                showMoreAssetCount,
                showMoreAssetCount
            )
            setOnClickListener { listener.onShowMoreButtonClick(assetInformationList) }
        }
    }

    fun interface ApplicationCallTransactionAssetInformationListener {
        fun onShowMoreButtonClick(assetInformationList: List<ApplicationCallAssetInformation>)
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: ApplicationCallTransactionAssetInformationListener
        ): ApplicationCallTransactionAssetInformationViewHolder {
            val binding = ItemTransactionApplicationCallAssetInformationBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return ApplicationCallTransactionAssetInformationViewHolder(binding, listener)
        }
    }
}
