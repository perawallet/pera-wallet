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

package com.algorand.android.modules.walletconnect.launchback.base.ui.usecase

import android.content.Context
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.perapackagemanager.ui.PeraPackageManager
import com.algorand.android.modules.walletconnect.launchback.base.domain.usecase.LaunchBackBrowserSelectionUseCase
import com.algorand.android.modules.walletconnect.launchback.base.ui.mapper.LaunchBackBrowserListItemMapper
import com.algorand.android.modules.walletconnect.launchback.base.ui.model.LaunchBackBrowserListItem
import com.algorand.android.utils.emptyString
import dagger.hilt.android.qualifiers.ApplicationContext

open class WcLaunchBackBrowserPreviewUseCase constructor(
    private val peraPackageManager: PeraPackageManager,
    private val launchBackBrowserSelectionUseCase: LaunchBackBrowserSelectionUseCase,
    private val launchBackBrowserListItemMapper: LaunchBackBrowserListItemMapper,
    @ApplicationContext private val appContext: Context
) {

    protected fun createBrowserGroupList(browserGroup: String?): List<LaunchBackBrowserListItem>? {
        if (browserGroup.isNullOrBlank()) return null
        val installedApplicationPackageNameList = peraPackageManager.getInstalledAppsPackageNameList()
        return launchBackBrowserSelectionUseCase.getFilteredFallbackBrowserListByGroup(
            browserGroupResponse = browserGroup,
            installedApplicationPackageNameList = installedApplicationPackageNameList
        ).map {
            launchBackBrowserListItemMapper.mapTo(it)
        }
    }

    protected fun createPrimaryActionButtonAnnotatedString(
        launchBackBrowserList: List<LaunchBackBrowserListItem>?
    ): AnnotatedString? {
        return when (launchBackBrowserList?.size) {
            null, 0 -> null
            1 -> {
                val browserIconResId = launchBackBrowserList.firstOrNull()?.iconDrawableResId
                val nameStringResId = launchBackBrowserList.firstOrNull()?.nameStringResId
                val browserName = getLaunchBackBrowserName(nameStringResId)
                AnnotatedString(
                    stringResId = R.string.switch_back_to,
                    replacementList = listOf(
                        "browser_icon_res_id" to browserIconResId.toString(),
                        "browser_name" to browserName
                    )
                )
            }
            else -> null
        }
    }

    protected fun createSecondaryActionButtonTextResId(launchBackBrowserListSize: Int): Int? {
        return if (launchBackBrowserListSize <= 1) R.string.close else null
    }

    private fun getLaunchBackBrowserName(@StringRes nameStringResId: Int?): String {
        if (nameStringResId == null) return emptyString()
        return appContext.getString(nameStringResId)
    }
}
