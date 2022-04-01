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

package com.algorand.android.banner.domain.usecase

import android.content.SharedPreferences
import com.algorand.android.banner.domain.mapper.BannerMapper
import com.algorand.android.banner.domain.model.BannerDetailDTO
import com.algorand.android.banner.domain.model.BannerType
import com.algorand.android.banner.domain.model.BaseBanner
import com.algorand.android.banner.domain.repository.BannerRepository
import com.algorand.android.utils.preference.getNotificationUserId
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.map

class BannersUseCase @Inject constructor(
    @Named(BannerRepository.BANNER_REPOSITORY_INJECTION_NAME) private val bannerRepository: BannerRepository,
    private val bannerMapper: BannerMapper,
    private val sharedPreferences: SharedPreferences
) {

    suspend fun getBanners() = bannerRepository.getCachedBanners().map { bannerDetailDtoList ->
        val dismissedBannerIdList = bannerRepository.getDismissedBannerIdList()
        val filteredList = bannerDetailDtoList.filterNot { dismissedBannerIdList.contains(it.bannerId) }
        getMappedAndFilteredBanners(filteredList)
    }

    // TODO create notification user id local source
    suspend fun cacheBanners(deviceId: String? = null) {
        val safeDeviceId = deviceId ?: sharedPreferences.getNotificationUserId() ?: return
        bannerRepository.cacheBanners(safeDeviceId)
    }

    suspend fun dismissBanner(bannerId: Long) {
        with(bannerRepository) {
            setBannerDismissed(bannerId)
            removeDismissedBannerFromCache(bannerId)
        }
    }

    suspend fun clearBannerCacheAndDismissedBannerIdList() {
        with(bannerRepository) {
            clearBannerCache()
            clearDismissedBannerIds()
        }
    }

    suspend fun clearBannerCache() {
        bannerRepository.clearBannerCache()
    }

    private fun getMappedAndFilteredBanners(bannerDtoList: List<BannerDetailDTO>): List<BaseBanner> {
        return bannerDtoList.map {
            when (it.type) {
                BannerType.GOVERNANCE -> bannerMapper.mapToGovernanceBanner(it)
                BannerType.GENERIC -> bannerMapper.mapToGenericBanner(it)
                else -> bannerMapper.mapToGenericBanner(it)
            }
        }
    }
}
