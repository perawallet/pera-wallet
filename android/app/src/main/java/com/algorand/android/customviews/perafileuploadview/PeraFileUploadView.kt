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

package com.algorand.android.customviews.perafileuploadview

import android.content.Context
import android.content.res.ColorStateList
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.customviews.perafileuploadview.model.FileUploadState
import com.algorand.android.databinding.CustomPeraFileUploadViewBinding
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

class PeraFileUploadView @JvmOverloads constructor(
    context: Context,
    attributeSet: AttributeSet? = null
) : ConstraintLayout(context, attributeSet) {

    private val binding = viewBinding(CustomPeraFileUploadViewBinding::inflate)

    private var listener: Listener? = null

    init {
        initRootView()
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun updateUploadState(fileUploadState: FileUploadState) {
        when (fileUploadState) {
            is FileUploadState.Initial -> initInitialState(fileUploadState)
            is FileUploadState.Uploading -> initUploadingState(fileUploadState)
            is FileUploadState.Successful -> initSuccessfulState(fileUploadState)
            is FileUploadState.Failure -> initFailureState(fileUploadState)
        }
    }

    private fun initInitialState(initialState: FileUploadState.Initial) {
        with(binding) {
            with(initialState) {
                uploadStateImageView.apply {
                    setImageDrawable(ContextCompat.getDrawable(root.context, uploadStatusIconResId))
                    imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context, uploadStatusIconTintResId))
                    setOnClickListener { listener?.onSelectFile() }
                }
                uploadStateProgressBar.hide()
                uploadStateTextView.apply {
                    setText(uploadStatusTextResId)
                    setOnClickListener { listener?.onSelectFile() }
                }
                uploadStateFileNameTextView.hide()
                uploadStateActionButton.hide()
            }
        }
    }

    private fun initUploadingState(uploadingState: FileUploadState.Uploading) {
        with(binding) {
            with(uploadingState) {
                uploadStateImageView.setImageDrawable(null)
                uploadStateProgressBar.show()
                uploadStateTextView.setText(uploadStatusTextResId)
                uploadStateFileNameTextView.apply {
                    text = fileName
                    show()
                }
                uploadStateActionButton.apply {
                    setText(uploadActionButtonTextResId)
                    setOnClickListener { listener?.onUploadCancel() }
                    show()
                }
            }
        }
    }

    private fun initSuccessfulState(successfulState: FileUploadState.Successful) {
        with(binding) {
            with(successfulState) {
                uploadStateImageView.apply {
                    setImageDrawable(ContextCompat.getDrawable(context, uploadStatusIconResId))
                    imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context, uploadStatusIconTintResId))
                }
                uploadStateProgressBar.hide()
                uploadStateTextView.setText(uploadStatusTextResId)
                uploadStateFileNameTextView.apply {
                    text = fileName
                    show()
                }
                uploadStateActionButton.apply {
                    setText(uploadActionButtonTextResId)
                    setOnClickListener { listener?.onReplaceFile() }
                    show()
                }
            }
        }
    }

    private fun initFailureState(failureState: FileUploadState.Failure) {
        with(binding) {
            with(failureState) {
                uploadStateImageView.apply {
                    setImageDrawable(ContextCompat.getDrawable(context, uploadStatusIconResId))
                    imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context, uploadStatusIconTintResId))
                }
                uploadStateProgressBar.hide()
                uploadStateTextView.text = context?.getXmlStyledString(errorStatusAnnotatedString)
                uploadStateFileNameTextView.apply {
                    text = fileName
                    isVisible = !fileName.isNullOrBlank()
                }
                uploadStateActionButton.apply {
                    setText(uploadActionButtonTextResId)
                    setOnClickListener { listener?.onSelectFile() }
                    show()
                }
            }
        }
    }

    private fun initRootView() {
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_large))
        backgroundTintList = ColorStateList.valueOf(ContextCompat.getColor(context, R.color.layer_gray_lightest))
        setBackgroundResource(R.drawable.bg_rectangle_radius_8)
    }

    interface Listener {
        fun onUploadCancel()
        fun onReplaceFile()
        fun onSelectFile()
    }
}
