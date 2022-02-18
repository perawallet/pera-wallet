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
 *
 */

package com.algorand.android.ui.register.recover

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.google.android.material.button.MaterialButton

class RecoverPassphraseVerifiedFragment : BaseInfoFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun setImageView(imageView: ImageView) {
        imageView.setImageResource(R.drawable.ic_check)
        imageView.setColorFilter(ContextCompat.getColor(requireContext(), R.color.infoImageColor))
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.account_is_verified)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setText(R.string.welcome_to_pera_your_account)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.start_using_pera)
            setOnClickListener { handleNextNavigation() } // TODO Double check recover acc with passphrase
        }
    }

    private fun handleNextNavigation() {
        nav(RecoverWithPassphraseFragmentDirections.actionGlobalToHomeNavigation())
    }
}
