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

package com.algorand.android.tutorialdialog.ui

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.ViewGroup
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.databinding.DialogTutorialBinding
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getDisplaySize
import com.algorand.android.utils.viewbinding.viewBinding

class TutorialDialog private constructor(context: Context) : Dialog(context) {

    private val binding = viewBinding(DialogTutorialBinding::inflate)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setCanceledOnTouchOutside(false)
        updateDialogWindow()
        updateDialogDecorView()
        setContentView(binding.root)
    }

    private fun updateDialogWindow() {
        window?.apply {
            setGravity(Gravity.CENTER_HORIZONTAL or Gravity.BOTTOM)
            attributes = attributes?.apply { width = ViewGroup.LayoutParams.MATCH_PARENT }
            setBackgroundDrawableResource(R.drawable.bg_tutorial_dialog)
            setDimAmount(DIALOG_DIM_AMOUNT)
        }
    }

    private fun updateDialogDecorView() {
        window?.decorView?.apply {
            val displayMetrics = DisplayMetrics().apply { context.getDisplaySize() }
            minimumWidth = displayMetrics.widthPixels
        }
    }

    fun applyParams(tutorialDialogParams: TutorialDialogParams) {
        with(tutorialDialogParams) {
            setImageView(tutorialImageRes)
            setTitleTextView(tutorialTitleRes)
            setDescriptionTextView(tutorialDescriptionRes)
            setNeutralButton(tutorialNeutralButtonTextRes, neutralButtonClickListener)
        }
    }

    private fun setImageView(@DrawableRes imageRes: Int?) {
        if (imageRes == null) return
        with(binding.dialogImageView) {
            setImageResource(imageRes)
            show()
        }
    }

    private fun setTitleTextView(@StringRes textRes: Int?) {
        if (textRes == null) return
        with(binding.dialogTitleTextView) {
            setText(textRes)
            show()
        }
    }

    private fun setDescriptionTextView(@StringRes textRes: Int?) {
        if (textRes == null) return
        with(binding.dialogDescriptionTextView) {
            setText(textRes)
            show()
        }
    }

    private fun setNeutralButton(@StringRes textRes: Int?, onClick: (() -> Unit)?) {
        if (textRes == null) return
        with(binding.dialogNeutralButton) {
            setText(textRes)
            setOnClickListener {
                onClick?.invoke()
                this@TutorialDialog.dismiss()
            }
            show()
        }
    }

    companion object {
        private const val DIALOG_DIM_AMOUNT = 0.3f

        fun create(context: Context): TutorialDialog {
            return TutorialDialog(context)
        }
    }
}
