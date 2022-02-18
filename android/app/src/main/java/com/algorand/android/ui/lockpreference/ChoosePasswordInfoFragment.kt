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

package com.algorand.android.ui.lockpreference

import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.algorand.android.utils.preference.setLockDontAskAgain
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class ChoosePasswordInfoFragment : BaseInfoFragment() {

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val toolbarConfiguration = ToolbarConfiguration(backgroundColor = R.color.tertiaryBackground)

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val args by navArgs<ChoosePasswordInfoFragmentArgs>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
    }

    private fun setupToolbar() {
        getAppToolbar()?.addButtonToEnd(TextButton(R.string.do_not_ask_again, onClick = ::onDontAskAgainClick))
    }

    override fun setImageView(imageView: ImageView) {
        val icon = R.drawable.ic_locked
        imageView.apply {
            setImageResource(icon)
            setColorFilter(ContextCompat.getColor(requireContext(), R.color.infoImageColor))
        }
    }

    override fun setTitleText(textView: TextView) {
        val title = R.string.increase_your_security
        textView.setText(title)
    }

    override fun setDescriptionText(textView: TextView) {
        val description = R.string.this_6_digit_pin
        textView.setText(description)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        val buttonText = R.string.set_pin_code
        materialButton.apply {
            setText(buttonText)
            setOnClickListener { navigateToChoosePasswordFragment() }
        }
    }

    override fun setSecondButton(materialButton: MaterialButton) {
        val buttonText = R.string.not_now
        materialButton.apply {
            setText(buttonText)
            visibility = MaterialButton.VISIBLE
            setOnClickListener { onCancelClick() }
        }
    }

    private fun onDontAskAgainClick() {
        sharedPref.setLockDontAskAgain()
        onCancelClick()
    }

    private fun navigateToChoosePasswordFragment() {
        nav(ChoosePasswordInfoFragmentDirections.actionChoosePasswordInfoFragmentToChoosePasswordFragment())
    }

    private fun onCancelClick() {
        if (args.shouldNavigateHome) {
            nav(ChoosePasswordInfoFragmentDirections.actionChoosePasswordInfoFragmentToHomeNavigation())
        } else {
            navBack()
        }
    }
}
