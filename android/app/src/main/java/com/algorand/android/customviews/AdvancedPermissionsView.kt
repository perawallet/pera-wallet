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

package com.algorand.android.customviews

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import androidx.core.view.isVisible
import com.algorand.android.databinding.CustomAdvancedPermissionsBinding
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.viewbinding.viewBinding

class AdvancedPermissionsView(context: Context, attrs: AttributeSet?) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomAdvancedPermissionsBinding::inflate)
    private var containerHeight = 0
    private var containerCollapsedTranslationY = 0f

    init {
        orientation = VERTICAL
        setContainerHeight()
        containerCollapsedTranslationY = containerHeight / CONTAINER_TRANSLATION_Y_DIVIDER
        binding.contentContainerLayout.apply {
            alpha = COLLAPSED_STATE_ALPHA
            scaleY = COLLAPSED_STATE_SCALE_Y
            translationY = -containerCollapsedTranslationY
        }
    }

    fun setOnTitleClickListener(onClick: () -> Unit) {
        binding.titleContainerLayout.setOnClickListener { onClick() }
    }

    fun setOnInfoTextClickListener(onClick: () -> Unit) {
        binding.titleTextView.setOnClickListener { onClick() }
    }

    fun expandContainer() {
        binding.contentContainerLayout.apply {
            show()
            animate().apply {
                alpha(1f)
                scaleY(1f)
                translationY(0f)
                setListener(object : AnimatorListenerAdapter() {
                    override fun onAnimationStart(animation: Animator) {
                        animateArrow(UP_ARROW_POSITION)
                    }
                })
            }.start()
        }
    }

    fun collapseContainer() {
        binding.contentContainerLayout.animate().apply {
            alpha(COLLAPSED_STATE_ALPHA)
            scaleY(COLLAPSED_STATE_SCALE_Y)
            translationY(-containerCollapsedTranslationY)
            setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationStart(animation: Animator) {
                    animateArrow(DOWN_ARROW_POSITION)
                }

                override fun onAnimationEnd(animation: Animator) {
                    binding.contentContainerLayout.hide()
                }
            })
        }.start()
    }

    fun setSupportedMethods(supportedMethods: String, isVisible: Boolean) {
        with(binding) {
            supportedMethodsGroup.isVisible = isVisible
            supportedMethodsTextView.text = supportedMethods
        }
    }

    fun setSupportedEvents(supportedEvents: String, isVisible: Boolean) {
        with(binding) {
            supportedEventsGroup.isVisible = isVisible
            supportedEventsTextView.text = supportedEvents
        }
    }

    fun isDividerVisible(isVisible: Boolean) {
        binding.supportedMethodsDividerView.isVisible = isVisible
    }

    private fun animateArrow(rotation: Float) {
        binding.arrowImageView.animate().rotation(rotation).start()
    }

    private fun setContainerHeight() {
        binding.contentContainerLayout.measure(
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
        )
        containerHeight = binding.contentContainerLayout.measuredHeight
    }

    companion object {
        private const val UP_ARROW_POSITION = 180f
        private const val DOWN_ARROW_POSITION = 0f
        private const val COLLAPSED_STATE_ALPHA = 0f
        private const val COLLAPSED_STATE_SCALE_Y = 0f
        private const val CONTAINER_TRANSLATION_Y_DIVIDER = 8f
    }
}
