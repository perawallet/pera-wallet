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

package com.algorand.android.modules.transactionhistory.ui

import android.content.Context
import android.graphics.Canvas
import android.view.LayoutInflater
import android.view.View
import android.view.View.MeasureSpec
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountHistoryTitleBinding

class StickyAccountHistoryHeaderDecoration(
    private val accountHistoryAdapter: AccountHistoryAdapter,
    private val pendingTransactionAdapter: PendingTransactionAdapter,
    context: Context,
) : RecyclerView.ItemDecoration() {

    private val headerBinding by lazy { ItemAccountHistoryTitleBinding.inflate(LayoutInflater.from(context)) }
    private val headerView: View
        get() = headerBinding.root

    override fun onDrawOver(canvas: Canvas, parent: RecyclerView, state: RecyclerView.State) {
        super.onDrawOver(canvas, parent, state)
        if (pendingTransactionAdapter.itemCount != 0) return
        val topItemView = parent.getChildAt(0) ?: return
        val secondItemView = parent.getChildAt(1)

        parent.getChildAdapterPosition(topItemView).let { topPosition ->
            accountHistoryAdapter.getTitleForPosition(topPosition)?.let {
                headerBinding.titleTextView.text = it
                configureHeaderView(topItemView)
                drawHeaderView(canvas = canvas, topItemView = topItemView, secondItemView = secondItemView)
            }
        }
    }

    private fun configureHeaderView(topView: View) {
        headerView.measure(
            MeasureSpec.makeMeasureSpec(topView.width, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED)
        )
        headerView.layout(topView.left, 0, topView.right, headerView.measuredHeight)
    }

    private fun drawHeaderView(canvas: Canvas, topItemView: View, secondItemView: View?) {
        with(canvas) {
            save()
            headerView.apply {
                setBackgroundColor(context.getColor(R.color.primary_background))
                translate(
                    resources.getDimensionPixelSize(R.dimen.spacing_xlarge).toFloat(),
                    calculateHeaderTop(topItemView, secondItemView)
                )
            }
            headerView.draw(this)
            restore()
        }
    }

    private fun calculateHeaderTop(topItemView: View, secondItemView: View?): Float {
        if (secondItemView != null) {
            val threshold = headerView.height
            if (secondItemView.id == R.id.accountHistoryTitleItemConstraintLayout && secondItemView.top <= threshold) {
                return (secondItemView.top - threshold).toFloat()
            }
        }
        return maxOf(topItemView.top, 0).toFloat()
    }
}
