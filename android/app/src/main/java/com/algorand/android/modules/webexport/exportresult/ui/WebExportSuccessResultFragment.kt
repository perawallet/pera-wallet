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

package com.algorand.android.modules.webexport.exportresult.ui

import android.widget.ImageView
import android.widget.TextView
import com.algorand.android.R
import com.algorand.android.WebExportNavigationDirections
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WebExportSuccessResultFragment : BaseInfoFragment() {
    override val fragmentConfiguration = FragmentConfiguration()

    override fun setImageView(imageView: ImageView) {
        imageView.setImageResource(R.drawable.ic_check_72dp)
    }

    override fun setTitleText(textView: TextView) {
        textView.text = getText(R.string.accounts_exported_successfully)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.text = getText(R.string.you_can_now_use_these)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        materialButton.text = getString(R.string.close)
        materialButton.setOnClickListener {
            nav(WebExportNavigationDirections.actionWebExportNavigationPop())
        }
    }
}
