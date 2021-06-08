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
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import androidx.core.content.res.use
import androidx.core.view.ViewCompat
import androidx.core.view.isInvisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomSelectionViewBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SelectionView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs), AdapterView.OnItemSelectedListener {

    private lateinit var pairList: MutableList<Pair<String, Any?>>
    private val emptySelection: Pair<String, Any?> = Pair("", null)
    private var selectedPair = emptySelection
    private var spinnerAdapter: ArrayAdapter<String>? = null

    private var binding = viewBinding(CustomSelectionViewBinding::inflate)

    init {
        initView(attrs)
    }

    private fun initView(attrs: AttributeSet?) {
        ViewCompat.setBackgroundTintList(
            binding.spinner,
            ContextCompat.getColorStateList(context, R.color.gray_A4)
        )
        setCustomAttributes(attrs)
    }

    fun setListItems(pairList: List<Pair<String, Any?>>) {
        this.pairList = pairList.toMutableList()
        this.pairList.add(0, emptySelection)
        binding.spinner.onItemSelectedListener = this
        spinnerAdapter = ArrayAdapter(context, R.layout.custom_selection_spinner_item,
            this.pairList.map { pair -> pair.first })
        binding.spinner.adapter = spinnerAdapter
    }

    fun getSelectedPair(): Pair<String, Any?> {
        return selectedPair
    }

    private fun setCustomAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.SelectionView).use {
            binding.hintTextView.text = it.getText(R.styleable.SelectionView_hintText)
        }
    }

    override fun onNothingSelected(p0: AdapterView<*>?) {
        // nothing to do
    }

    override fun onItemSelected(p0: AdapterView<*>?, p1: View?, selectedItemPosition: Int, p3: Long) {
        selectedPair = pairList[selectedItemPosition]
        binding.hintTextView.isInvisible = selectedItemPosition != 0
    }
}
