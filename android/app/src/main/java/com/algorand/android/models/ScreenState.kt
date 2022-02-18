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

package com.algorand.android.models

import com.algorand.android.R

sealed class ScreenState(
    open val icon: Int,
    open val title: Int,
    open val description: Int,
    open val buttonText: Int,
) {
    data class CustomState(
        override var icon: Int = -1,
        override var title: Int = -1,
        override var description: Int = -1,
        override var buttonText: Int = -1
    ) : ScreenState(icon, title, description, buttonText)

    data class ConnectionError(
        override val icon: Int = R.drawable.ic_cloud_no_connection,
        override val title: Int = R.string.connect_to_internet,
        override val description: Int = R.string.we_couldn_t_reach,
        override val buttonText: Int = R.string.try_again,
    ) : ScreenState(icon, title, description, buttonText)

    data class DefaultError(
        override val icon: Int = R.drawable.ic_info,
        override val title: Int = R.string.something_went_wrong,
        override val description: Int = R.string.sorry_something_went,
        override val buttonText: Int = R.string.try_again,
    ) : ScreenState(icon, title, description, buttonText)
}
