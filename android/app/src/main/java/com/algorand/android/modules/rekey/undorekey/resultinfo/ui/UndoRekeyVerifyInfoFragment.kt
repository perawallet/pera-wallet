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

package com.algorand.android.modules.rekey.undorekey.resultinfo.ui

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class UndoRekeyVerifyInfoFragment : BaseInfoFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    private val undoRekeyVerifyInfoViewModel by viewModels<UndoRekeyVerifyInfoViewModel>()

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            popUndoRekeyNavigationUp()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    override fun setImageView(imageView: ImageView) {
        with(imageView) {
            setImageResource(R.drawable.ic_check)
            setColorFilter(ContextCompat.getColor(requireContext(), R.color.info_image_color))
        }
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.rekey_successfully_undone)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.text = context?.getString(
            R.string.the_account_has_been_reverted,
            undoRekeyVerifyInfoViewModel.accountDisplayName.getAccountPrimaryDisplayName()
        )
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        with(materialButton) {
            setText(R.string.done)
            setOnClickListener { popUndoRekeyNavigationUp() }
        }
    }

    private fun popUndoRekeyNavigationUp() {
        nav(UndoRekeyVerifyInfoFragmentDirections.actionRekeyUndoNavigationPop())
    }
}
