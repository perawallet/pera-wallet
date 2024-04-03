/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.ui.register.createaccount.passphraseverified

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class PassphraseVerifiedInfoFragment : BaseInfoFragment() {
    override val fragmentConfiguration = FragmentConfiguration()

    private val args: PassphraseVerifiedInfoFragmentArgs by navArgs()

    override fun setImageView(imageView: ImageView) {
        with(imageView) {
            setImageResource(R.drawable.ic_shield_check_large)
            setColorFilter(ContextCompat.getColor(requireContext(), R.color.info_image_color))
        }
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.passphrase_verified)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setText(R.string.keep_this_recovery)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        with(materialButton) {
            setText(
                if (args.accountCreation != null) {
                    R.string.next
                } else {
                    R.string.done
                }
            )
            setOnClickListener { handleNextNavigation() }
        }
    }

    private fun handleNextNavigation() {
        args.accountCreation?.let { accountCreation ->
            nav(
                PassphraseVerifiedInfoFragmentDirections
                    .actionPassphraseVerifiedInfoFragmentToBackupPassphraseAccountNameNavigation(
                        accountCreation.copy(
                            tempAccount = accountCreation.tempAccount.copy(isBackedUp = true)
                        )
                    )
            )
        } ?: navToHomeNavigation()
    }

    private fun navToHomeNavigation() {
        nav(PassphraseVerifiedInfoFragmentDirections.actionPassphraseVerifiedInfoFragmentToHomeNavigation())
    }
}
