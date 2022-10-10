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

package com.algorand.android.modules.walletconnectfallbackbrowser.ui

import android.widget.ImageView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserListItem
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.startActivityWithPackageNameIfPossible
import com.google.android.material.button.MaterialButton

abstract class BaseWalletConnectSingleBrowserFallbackBottomSheet : BaseDoubleButtonBottomSheet() {

    abstract val browserItem: FallbackBrowserListItem

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            text = context?.getXmlStyledString(
                R.string.switch_back_to,
                listOf(
                    "browserIconResId" to browserItem.iconDrawableResId.toString(),
                    "browser_name" to context.getString(browserItem.nameStringResId)
                )
            )
            setOnClickListener {
                if (context?.startActivityWithPackageNameIfPossible(browserItem.packageName) == true) {
                    dismissAllowingStateLoss()
                } else {
                    navBack()
                }
            }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            text = getString(R.string.close)
            setOnClickListener { navBack() }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.apply {
            setImageResource(R.drawable.ic_check_72dp)
            imageTintList = ContextCompat.getColorStateList(requireContext(), R.color.positive)
        }
    }
}
