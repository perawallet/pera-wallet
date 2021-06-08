/*
 * Copyright 2019 Algorand, Inc.
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
import android.view.LayoutInflater
import android.view.View
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentChoosePasswordInfoBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.lockpreference.ChoosePasswordInfoFragmentDirections.Companion.actionChoosePasswordInfoFragmentToChoosePasswordFragment
import com.algorand.android.utils.preference.setLockDontAskAgain
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class ChoosePasswordInfoFragment : DaggerBaseFragment(R.layout.fragment_choose_password_info) {

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val toolbarConfiguration = ToolbarConfiguration(backgroundColor = R.color.tertiaryBackground)

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentChoosePasswordInfoBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        binding.positiveButton.setOnClickListener { onPositiveClick() }
        binding.cancelButton.setOnClickListener { onCancelClick() }
    }

    private fun configureToolbar() {
        getAppToolbar()?.apply {
            val skipButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_text_tab_button, this, false) as MaterialButton

            skipButton.apply {
                setTextColor(ContextCompat.getColor(context, R.color.colorPrimary))
                setText(R.string.do_not_ask_again)
                setOnClickListener { onDontAskAgainClick() }
                addViewToEndSide(this)
            }
        }
    }

    private fun onDontAskAgainClick() {
        sharedPref.setLockDontAskAgain()
        navBack()
    }

    private fun onPositiveClick() {
        nav(actionChoosePasswordInfoFragmentToChoosePasswordFragment())
    }

    private fun onCancelClick() {
        navBack()
    }
}
