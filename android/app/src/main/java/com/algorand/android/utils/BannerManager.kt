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

package com.algorand.android.utils

import com.algorand.android.repository.BannerRepository
import javax.inject.Inject

class BannerManager @Inject constructor(
    private val bannerRepository: BannerRepository
) {

    fun setBannerVisible() {
        bannerRepository.setBannerVisible()
    }

    fun setBannerInvisible() {
        bannerRepository.setBannerInvisible()
    }

    fun shouldShowBanner(): Boolean {
        val isBannerVisible = bannerRepository.getBannerVisibility()
        return isBannerVisible && isCurrentTimeInVisibilityDateRange()
    }

    private fun isCurrentTimeInVisibilityDateRange(): Boolean {
        return getCurrentTimeAsSec() in BANNER_VISIBILITY_DATE_RANGE
    }

    companion object {
        // 1 Jan 2022 00:00:00 - 1640995200
        // 15 Jan 2022 23:59:59 - 1642291199
        private val BANNER_VISIBILITY_DATE_RANGE = 1640995200..1642291199
    }
}
