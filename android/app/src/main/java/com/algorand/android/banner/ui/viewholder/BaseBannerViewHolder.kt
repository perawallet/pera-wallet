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

package com.algorand.android.banner.ui.viewholder

import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.view.isVisible
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.google.android.material.button.MaterialButton

abstract class BaseBannerViewHolder(
    private val listener: BannerListener,
    itemView: View
) : BaseViewHolder<BaseAccountListItem>(itemView) {

    protected open val actionButton: MaterialButton? = null
    protected open val closeButton: MaterialButton? = null
    protected open val titleTextView: TextView? = null
    protected open val descriptionTextView: TextView? = null

    override fun bind(item: BaseAccountListItem) {
        if (item !is BaseAccountListItem.BaseBannerItem) return
        initActionButton(item)
        initCloseButton(item)
        initTitleTextView(item)
        initDescriptionTextView(item)
    }

    private fun initActionButton(item: BaseAccountListItem.BaseBannerItem) {
        actionButton?.apply {
            setOnClickListener { listener.onActionButtonClick(item.buttonUrl.orEmpty()) }
            text = item.buttonText
            isVisible = item.isButtonVisible
        }
    }

    private fun initCloseButton(item: BaseAccountListItem.BaseBannerItem) {
        closeButton?.setOnClickListener { listener.onCloseBannerClick(item.bannerId) }
    }

    private fun initTitleTextView(item: BaseAccountListItem.BaseBannerItem) {
        titleTextView?.apply {
            text = item.title.orEmpty()
            isVisible = item.isTitleVisible
        }
    }

    private fun initDescriptionTextView(item: BaseAccountListItem.BaseBannerItem) {
        descriptionTextView?.apply {
            text = item.description.orEmpty()
            isVisible = item.isDescriptionVisible
        }
    }

    interface BannerListener {
        fun onCloseBannerClick(bannerId: Long) {}
        fun onActionButtonClick(url: String) {}
    }

    protected interface BannerViewHolderCreator {
        fun create(listener: BannerListener, parent: ViewGroup): BaseBannerViewHolder
    }
}
