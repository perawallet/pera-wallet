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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.view.isVisible
import androidx.core.widget.TextViewCompat
import com.algorand.android.R
import com.algorand.android.databinding.CustomToolbarBinding
import com.algorand.android.models.Node
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class CustomToolbar @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val addedViewsList = mutableListOf<View>()

    private var type by Delegates.observable<Type?>(null, { _, oldValue, newValue ->
        if (oldValue != newValue && newValue != null) {
            setupType(newValue)
        }
    })

    private val binding = viewBinding(CustomToolbarBinding::inflate)

    fun configure(toolbarConfiguration: ToolbarConfiguration?) {
        visibility = if (toolbarConfiguration == null) {
            View.GONE
        } else {
            removeAllAddedViews()
            with(toolbarConfiguration) {
                this@CustomToolbar.type = type
                setupBackground(backgroundColor)
                setupTitle(titleResId)
                configureStartButton(startIconResId, startIconClick)
                val isTestNetStatusActive = binding.nodeStatusTextView.text == TESTNET_NETWORK_SLUG
                binding.nodeStatusTextView.isVisible = showNodeStatus && isTestNetStatusActive
            }
            View.VISIBLE
        }
    }

    private fun setupTitle(titleResId: Int?) {
        if (titleResId != null) {
            binding.toolbarTitleTextView.setText(titleResId)
        } else {
            binding.toolbarTitleTextView.text = ""
        }
    }

    private fun setupBackground(newBackgroundColor: Int?) {
        if (newBackgroundColor != null) {
            setBackgroundResource(newBackgroundColor)
        } else {
            background = null
        }
    }

    fun changeTitle(title: String) {
        binding.toolbarTitleTextView.text = title
    }

    fun configureStartButton(resId: Int?, clickAction: (() -> Unit)?) {
        binding.startImageButton.apply {
            visibility = if (resId == null) {
                View.GONE
            } else {
                setImageResource(resId)
                setOnClickListener { clickAction?.invoke() }
                View.VISIBLE
            }
        }
    }

    private fun setupType(type: Type) {
        val titleAppearance: Int

        when (type) {
            Type.TAB_TOOLBAR -> {
                layoutParams = layoutParams.apply {
                    height = resources.getDimensionPixelSize(R.dimen.tab_toolbar_min_height)
                }
                ConstraintSet().apply {
                    clone(this@CustomToolbar)
                    setHorizontalBias(R.id.toolbarTitleTextView, 0f)
                    val titleStartMargin = resources.getDimensionPixelSize(R.dimen.page_horizontal_spacing)
                    setMargin(R.id.toolbarTitleTextView, ConstraintSet.START, titleStartMargin)
                    applyTo(this@CustomToolbar)
                }
                titleAppearance = R.style.TextAppearance_TabToolbarTitle
            }
            Type.DEFAULT_TOOLBAR -> {
                layoutParams = layoutParams.apply {
                    height = resources.getDimensionPixelSize(R.dimen.default_toolbar_height)
                }
                ConstraintSet().apply {
                    clone(this@CustomToolbar)
                    setHorizontalBias(R.id.toolbarTitleTextView, CENTER_BIAS)
                    val titleStartMargin = resources.getDimensionPixelSize(R.dimen.toolbar_navigation_item_width)
                    setMargin(R.id.toolbarTitleTextView, ConstraintSet.START, titleStartMargin)
                    applyTo(this@CustomToolbar)
                }
                titleAppearance = R.style.TextAppearance_ToolbarTitle
            }
        }

        TextViewCompat.setTextAppearance(binding.toolbarTitleTextView, titleAppearance)
    }

    private fun removeAllAddedViews() {
        addedViewsList.iterator().apply {
            while (hasNext()) {
                removeView(next())
                remove()
            }
        }
    }

    fun setNodeStatus(activatedNode: Node?) {
        binding.nodeStatusTextView.text = activatedNode?.networkSlug
    }

    fun addViewToEndSide(view: View, marginEnd: Int = 0): View {
        addView(view.apply { id = generateViewId() })

        val anchoredViewId = addedViewsList.lastOrNull()?.id ?: id
        val anchorSide: Int = if (addedViewsList.isEmpty()) ConstraintSet.END else ConstraintSet.START

        addedViewsList.add(view)

        ConstraintSet().apply {
            clone(this@CustomToolbar)
            connect(view.id, ConstraintSet.END, anchoredViewId, anchorSide, marginEnd)
            connect(view.id, ConstraintSet.TOP, id, ConstraintSet.TOP)
            connect(view.id, ConstraintSet.BOTTOM, id, ConstraintSet.BOTTOM)

            applyTo(this@CustomToolbar)
        }
        return view
    }

    enum class Type {
        TAB_TOOLBAR,
        DEFAULT_TOOLBAR
    }

    companion object {
        private const val CENTER_BIAS = 0.5f
    }
}
