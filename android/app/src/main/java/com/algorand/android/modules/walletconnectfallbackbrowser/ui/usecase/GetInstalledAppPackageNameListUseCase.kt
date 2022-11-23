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

package com.algorand.android.modules.walletconnectfallbackbrowser.ui.usecase

import android.content.pm.PackageManager
import com.algorand.android.core.BaseUseCase
import javax.inject.Inject

class GetInstalledAppPackageNameListUseCase @Inject constructor() : BaseUseCase() {

    fun getInstalledAppsPackageNameListOrEmpty(packageManager: PackageManager?): List<String> {
        return packageManager?.let { safePackageManager ->
            safePackageManager.getInstalledApplications(PackageManager.GET_META_DATA).mapNotNull { applicationInfo ->
                applicationInfo?.packageName
            }
        } ?: emptyList()
    }
}
