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

package com.algorand.android.banner.domain.model

sealed class BaseBanner {

    abstract val bannerId: Long
    abstract val title: String?
    abstract val description: String?
    abstract val buttonTitle: String?
    abstract val buttonUrl: String?

    data class GovernanceBanner(
        override val bannerId: Long,
        override val title: String?,
        override val description: String?,
        override val buttonTitle: String?,
        override val buttonUrl: String?
    ) : BaseBanner()

    data class GenericBanner(
        override val bannerId: Long,
        override val title: String?,
        override val description: String?,
        override val buttonTitle: String?,
        override val buttonUrl: String?
    ) : BaseBanner()
}
