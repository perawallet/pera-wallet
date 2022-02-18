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

package com.algorand.android.utils

import androidx.annotation.DrawableRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R

// TODO remove addDivider and use addCustomDivider in refactor
fun RecyclerView.addDivider(@DrawableRes dividerResId: Int) {
    addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL).apply {
        AppCompatResources.getDrawable(context, R.drawable.horizontal_divider_20dp)?.let { setDrawable(it) }
    })
}

fun RecyclerView.addCustomDivider(
    @DrawableRes drawableResId: Int,
    showLastDivider: Boolean = true,
    orientation: Int = RecyclerView.VERTICAL
) {
    AppCompatResources.getDrawable(context, drawableResId)?.let { dividerDrawable ->
        addItemDecoration(CustomDividerItemDecoration(orientation, dividerDrawable, showLastDivider))
    }
}
