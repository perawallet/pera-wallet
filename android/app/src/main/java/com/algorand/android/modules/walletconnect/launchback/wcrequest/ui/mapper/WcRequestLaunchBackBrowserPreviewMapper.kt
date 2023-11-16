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

package com.algorand.android.modules.walletconnect.launchback.wcrequest.ui.mapper

import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnect.launchback.base.ui.model.LaunchBackBrowserListItem
import com.algorand.android.modules.walletconnect.launchback.wcrequest.ui.model.WcRequestLaunchBackBrowserPreview
import javax.inject.Inject

class WcRequestLaunchBackBrowserPreviewMapper @Inject constructor() {

    fun mapToWcRequestLaunchBackBrowserPreview(
        iconResId: Int,
        iconTintResId: Int,
        titleAnnotatedString: AnnotatedString,
        descriptionAnnotatedString: AnnotatedString,
        launchBackBrowserList: List<LaunchBackBrowserListItem>?,
        primaryActionButtonAnnotatedString: AnnotatedString?,
        secondaryButtonTextResId: Int?
    ): WcRequestLaunchBackBrowserPreview {
        return WcRequestLaunchBackBrowserPreview(
            iconResId = iconResId,
            iconTintResId = iconTintResId,
            titleAnnotatedString = titleAnnotatedString,
            descriptionAnnotatedString = descriptionAnnotatedString,
            launchBackBrowserList = launchBackBrowserList,
            primaryActionButtonAnnotatedString = primaryActionButtonAnnotatedString,
            secondaryActionButtonTextResId = secondaryButtonTextResId
        )
    }
}
