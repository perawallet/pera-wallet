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

package com.algorand.android.ui.rekey

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.toShortenedAddress
import com.google.android.material.button.MaterialButton

class VerifyRekeyInfoFragment : BaseInfoFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    private val args: VerifyRekeyInfoFragmentArgs by navArgs()

    override fun setImageView(imageView: ImageView) {
        with(imageView) {
            setImageResource(R.drawable.ic_check)
            setColorFilter(ContextCompat.getColor(requireContext(), R.color.info_image_color))
        }
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.account_successfully_rekeyed)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.text = context?.getXmlStyledString(
            stringResId = R.string.the_account_name,
            replacementList = listOf("account_name" to args.publicKey.toShortenedAddress())
        )
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        with(materialButton) {
            text = getString(R.string.go_to_home)
            setOnClickListener {
                nav(VerifyRekeyInfoFragmentDirections.actionVerifyRekeyInfoFragmentToHomeNavigation())
            }
        }
    }
}
