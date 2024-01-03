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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.utils.extensions.changeTabTextAppearance
import com.google.android.material.tabs.TabLayout

class AlgorandTabLayout @JvmOverloads constructor(
    context: Context,
    private val attrs: AttributeSet? = null
) : TabLayout(context, attrs) {

    private val leftTab by lazy { newTab() }
    private val rightTab by lazy { newTab() }

    private var leftTabText: String? = null
    private var rightTabText: String? = null

    private var listener: Listener? = null

    private val tabSelectedListener = object : OnTabSelectedListener {
        override fun onTabSelected(tab: Tab?) {
            when (tab?.position) {
                0 -> listener?.onLeftTabSelected()
                else -> listener?.onRightTabSelected()
            }
            tab.changeTabTextAppearance(R.style.TextAppearance_Body_Sans_Medium)
        }

        override fun onTabUnselected(tab: Tab?) {
            tab.changeTabTextAppearance(R.style.TextAppearance_Body_Sans)
        }

        override fun onTabReselected(tab: Tab?) {
            // no-op
        }
    }

    init {
        loadAttrs()
        addOnTabSelectedListener(tabSelectedListener)
    }

    private fun loadAttrs() {
        context?.obtainStyledAttributes(attrs, R.styleable.AlgorandTabLayout)?.use { attr ->
            leftTabText = attr.getString(R.styleable.AlgorandTabLayout_leftTabText).orEmpty()
            rightTabText = attr.getString(R.styleable.AlgorandTabLayout_rightTabText).orEmpty()
        }
        setTabs(leftTabText, rightTabText)
    }

    fun setTabs(leftTabText: String?, rightTabText: String?) {
        if (tabCount >= 0) {
            this.removeAllTabs()
        }
        leftTab.apply {
            text = leftTabText
            contentDescription = leftTabText
        }
        rightTab.apply {
            text = rightTabText
            contentDescription = rightTabText
        }
        addTab(leftTab)
        addTab(rightTab)
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    interface Listener {
        fun onLeftTabSelected()
        fun onRightTabSelected()
    }
}
