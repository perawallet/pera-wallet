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

package com.algorand.android.models

import com.algorand.android.R

enum class LineChartTheme(val markerDrawableResId: Int, val lineColorResId: Int) {
    GREEN(R.drawable.bg_chart_mark_green_oval, R.color.green_0D),
    RED(R.drawable.bg_chart_mark_red_oval, R.color.red_E9),
    GRAY(R.drawable.bg_chart_mark_gray_oval, R.color.gray_A4)
}
