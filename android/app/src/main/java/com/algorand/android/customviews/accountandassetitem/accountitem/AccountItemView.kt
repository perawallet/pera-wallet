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

package com.algorand.android.customviews.accountandassetitem.accountitem

import android.content.Context
import android.util.AttributeSet
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.customviews.accountandassetitem.BaseAccountAndAssetItemView
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.BaseItemConfiguration
import com.algorand.android.models.GovernorIconResource
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.extensions.setAccountIconDrawable
import com.algorand.android.utils.extensions.setGovernorIconDrawable

class AccountItemView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : BaseAccountAndAssetItemView<BaseItemConfiguration.AccountItemConfiguration>(context, attrs) {

    private val accountItemAction = object : AccountItemAction {
        override fun initIconDrawable(accountIconResource: AccountIconResource?) {
            val isIconDrawableVisible = accountIconResource != null
            if (accountIconResource == null) return
            binding.iconImageView.apply {
                isVisible = isIconDrawableVisible
                setAccountIconDrawable(accountIconResource, R.dimen.account_icon_size_large)
            }
        }

        override fun initGovernorIconDrawable(governorIconResource: GovernorIconResource?) {
            val isIconDrawableVisible = governorIconResource != null
            if (governorIconResource == null) return
            binding.governorIconImageView.apply {
                isVisible = isIconDrawableVisible
                setGovernorIconDrawable(governorIconResource, R.dimen.governor_icon_size_large)
            }
        }

        override fun initTitleText(accountDisplayName: AccountDisplayName?) {
            val primaryAccountName = accountDisplayName?.getDisplayTextOrAccountShortenedAddress()
            val isTitleTextVisible = !primaryAccountName.isNullOrBlank()
            binding.titleTextView.apply {
                isVisible = isTitleTextVisible
                text = primaryAccountName
            }
        }

        override fun initDescriptionText(accountDisplayName: AccountDisplayName?) {
            val secondaryAccountName = accountDisplayName?.getAccountShortenedAddressOrAccountType(resources)
            val isTitleTextVisible = !secondaryAccountName.isNullOrBlank()
            binding.descriptionTextView.apply {
                isVisible = isTitleTextVisible
                text = secondaryAccountName
            }
        }

        override fun initWarningImageView(showWarning: Boolean?) {
            val isWarningImageViewVisible = showWarning != null && showWarning == true
            binding.warningIconImageView.isVisible = isWarningImageViewVisible
        }
    }

    override fun initItemView(itemConfig: BaseItemConfiguration.AccountItemConfiguration) {
        with(itemConfig) {
            with(accountItemAction) {
                initIconDrawable(accountIconResource)
                initGovernorIconDrawable(governorIconResource)
                initTitleText(accountDisplayName)
                initDescriptionText(accountDisplayName)
                initWarningImageView(showWarning)
            }
            initPrimaryValue(primaryValueText)
            initSecondaryValue(secondaryValueText)
            initActionButton(actionButtonConfiguration)
            initCheckButton(checkButtonConfiguration)
            initDragButton(dragButtonConfiguration)
        }
    }
}
