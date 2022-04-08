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

package com.algorand.android.ui.verifiedassetinformation

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetVerifiedAssetInformationBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.PERA_SUPPORT_URL
import com.algorand.android.utils.openPeraSupportUrl
import com.algorand.android.utils.setXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

class VerifiedAssetInformationBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_verified_asset_information, true) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.verified_assets,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    private val binding by viewBinding(BottomSheetVerifiedAssetInformationBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(binding) {
            toolbar.configure(toolbarConfiguration)
            titleTextView.setXmlStyledString(R.string.what_does_asset)
            thirdParagraphTextView.setXmlStyledString(
                stringResId = R.string.verified_assets_third_paragraph,
                colorResId = R.color.error_text_color
            )
            supportUrlTextView.apply {
                text = PERA_SUPPORT_URL
                setOnClickListener { context?.openPeraSupportUrl() }
            }
        }
    }
}
