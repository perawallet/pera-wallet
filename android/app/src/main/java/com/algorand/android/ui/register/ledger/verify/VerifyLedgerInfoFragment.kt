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

package com.algorand.android.ui.register.ledger.verify

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.algorand.android.utils.extensions.show
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class VerifyLedgerInfoFragment : BaseInfoFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    private val verifyLedgerInfoViewModel: VerifyLedgerInfoViewModel by viewModels()

    override fun setImageView(imageView: ImageView) {
        with(imageView) {
            setImageResource(R.drawable.ic_check)
            setColorFilter(ContextCompat.getColor(requireContext(), R.color.info_image_color))
        }
    }

    override fun setTitleText(textView: TextView) {
        textView.text = getString(R.string.ledger_successfully_connected)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.text = getString(R.string.congratulations_your_account)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        with(materialButton) {
            text = getString(R.string.start_using_pera)
            val action = if (verifyLedgerInfoViewModel.shouldForceLockNavigation()) {
                LoginNavigationDirections.actionToLockPreferenceNavigation(shouldNavigateHome = true)
            } else {
                LoginNavigationDirections.actionGlobalToHomeNavigation()
            }
            setOnClickListener { nav(action) }
        }
    }

    override fun setSecondButton(materialButton: MaterialButton) {
        with(materialButton) {
            text = getString(R.string.buy_algo)
            show()
            setOnClickListener { navToMoonpayNavigation() }
        }
    }

    private fun navToMoonpayNavigation() {
        nav(VerifyLedgerInfoFragmentDirections.actionVerifyLedgerInfoFragmentToMoonpayNavigation())
    }
}
