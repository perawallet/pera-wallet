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

package com.algorand.android.customviews

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomAssetNameViewBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import java.util.Locale

class AlgorandAssetNameTextView @JvmOverloads constructor(
    context: Context,
    val attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomAssetNameViewBinding::inflate)

    fun setupUI(showVerified: Boolean?, shortName: String?, fullName: String?, assetId: Long?, isAlgorand: Boolean?) {
        with(binding) {
            mainTextView.setTextAndVisibility(fullName)
            subTextView.setTextAndVisibility(shortName?.uppercase(Locale.ENGLISH))
            assetVerifiedImageView.isVisible = showVerified != null && showVerified != false
            if (isAlgorand == true) {
                algorandAssetAvatarView.setAlgorandAvatar()
            } else {
                algorandAssetAvatarView.setOtherAssetAvatar(fullName)
            }
        }
    }

    fun setupUIAssetWithIdInDescription(assetInformation: AssetInformation) {
        with(assetInformation) {
            with(binding) {
                mainTextView.setTextAndVisibility(fullName)
                assetVerifiedImageView.isVisible = isVerified
                if (isAlgo()) {
                    subTextView.setTextAndVisibility(shortName?.uppercase(Locale.ENGLISH))
                    algorandAssetAvatarView.setAlgorandAvatar()
                } else {
                    val subTextRes = context.getString(
                        R.string.pair_value_format_with_coma,
                        shortName?.uppercase(Locale.ENGLISH),
                        assetId
                    )
                    subTextView.setTextAndVisibility(subTextRes)
                    algorandAssetAvatarView.setOtherAssetAvatar(fullName)
                }
            }
        }
    }

    fun setupUIWithId(
        isVerified: Boolean,
        fullName: String?,
        assetId: Long,
        isAlgo: Boolean
    ) {
        with(binding) {
            assetVerifiedImageView.isVisible = isVerified
            if (isAlgo) {
                mainTextView.setTextAndVisibility(ALGOS_SHORT_NAME)
                subTextView.setTextAndVisibility(fullName)
                algorandAssetAvatarView.setAlgorandAvatar()
            } else {
                mainTextView.setTextAndVisibility(fullName)
                val subTextRes = context?.getXmlStyledString(
                    stringResId = R.string.asset_id,
                    replacementList = listOf("asset_id" to assetId.toString())
                ).toString()
                subTextView.setTextAndVisibility(subTextRes)
                algorandAssetAvatarView.setOtherAssetAvatar(fullName)
            }
        }
    }

    fun setupUiWithDrawable(
        isVerified: Boolean,
        fullName: String?,
        assetId: Long,
        drawable: Drawable,
        isOwnedByUser: Boolean
    ) {
        with(binding) {
            assetVerifiedImageView.isVisible = isVerified
            mainTextView.setTextAndVisibility(fullName)
            val subTextRes = context?.getXmlStyledString(
                stringResId = R.string.asset_id,
                replacementList = listOf("asset_id" to assetId.toString())
            ).toString()
            subTextView.setTextAndVisibility(subTextRes)
            algorandAssetAvatarView.hide()
            collectibleImageView.apply {
                showImage(drawable, !isOwnedByUser)
                show()
            }
        }
    }

    fun showProgressBar() {
        binding.algorandAssetAvatarView.showProgressBar()
    }

    fun hideProgressBar() {
        binding.algorandAssetAvatarView.hideProgressBar()
    }
}
