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

package com.algorand.android.ui.peraintroduction

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.core.view.doOnLayout
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.openPeraIntroductionBlog
import com.algorand.android.utils.setXmlStyledString
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class PeraIntroductionFragment : BaseInfoFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    private val peraIntroductionViewModel: PeraIntroductionViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        peraIntroductionViewModel.setPeraIntroductionShowed()
    }

    override fun setImageView(imageView: ImageView) {
        imageView.apply {
            setBackgroundColor(ContextCompat.getColor(context, R.color.yellow_400))
            setImageViewConstraints(this)
            doOnLayout {
                val padding = (it.width * IMAGE_PADDING_RATIO).toInt()
                setPadding(padding, padding, padding, padding)
                setImageResource(R.drawable.ic_pera_logo)
            }
        }
    }

    override fun setTopStartButton(materialButton: MaterialButton) {
        materialButton.apply {
            setOnClickListener { navBack() }
            show()
            setIconTintResource(R.color.black)
        }
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.algorand_wallet_is_now)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setXmlStyledString(R.string.we_are_very_excited, R.color.link_primary, ::onPeraWalletBlogClick)
    }

    private fun onPeraWalletBlogClick(url: String) {
        context?.openPeraIntroductionBlog()
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.start_using_pera)
            setOnClickListener { navBack() }
        }
    }

    private fun setImageViewConstraints(imageView: ImageView) {
        val imageViewId = imageView.id
        val rootId = rootConstraintLayout.id
        val constraintSet = ConstraintSet().apply {
            clone(rootConstraintLayout)
            connect(imageViewId, ConstraintSet.END, rootId, ConstraintSet.END, 0)
            connect(imageViewId, ConstraintSet.START, rootId, ConstraintSet.START, 0)
            connect(imageViewId, ConstraintSet.TOP, rootId, ConstraintSet.TOP, 0)
            setDimensionRatio(imageView.id, IMAGE_DIMENSION_RATIO)
        }
        constraintSet.applyTo(rootConstraintLayout)
    }

    companion object {
        private const val IMAGE_DIMENSION_RATIO = "3:2"
        private const val IMAGE_PADDING_RATIO = 0.16
    }
}
