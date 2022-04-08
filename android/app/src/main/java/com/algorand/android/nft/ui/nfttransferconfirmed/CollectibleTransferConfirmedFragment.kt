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
package com.algorand.android.nft.ui.nfttransferconfirmed

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.google.android.material.button.MaterialButton

class CollectibleTransferConfirmedFragment : BaseInfoFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    override fun setImageView(imageView: ImageView) {
        imageView.setImageResource(R.drawable.ic_check)
        imageView.setColorFilter(ContextCompat.getColor(requireContext(), R.color.info_image_color))
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.your_nft_transfer)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setText(R.string.transactions_can_take)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        materialButton.setText(R.string.got_it)
        materialButton.setOnClickListener { navigateToHomeNavigation() }
    }

    private fun navigateToHomeNavigation() {
        nav(
            CollectibleTransferConfirmedFragmentDirections
                .actionCollectibleTransferConfirmedFragmentToCollectiblesFragment()
        )
    }
}
