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

package com.algorand.android.models

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.R
import com.algorand.android.notification.domain.model.NotificationMetadata

sealed class AlertMetadata(
    @DrawableRes open val iconRes: Int? = null,
    @ColorRes open val iconTintRes: Int? = null,
    @ColorRes open val backgroundColorRes: Int = R.color.white,
    open val title: String? = null,
    @ColorRes open val titleColorRes: Int = R.color.gray_900,
    open val description: String? = null,
    @ColorRes open val descriptionColorRes: Int = R.color.gray_500,
    open val metadata: Any? = null,
    open val tag: String? = null,
) {
    class AlertNotification(
        override val title: String? = null,
        override val description: String? = null,
        override val metadata: NotificationMetadata,
        override val tag: String? = null
    ) : AlertMetadata(
        iconRes = R.drawable.ic_notification_alert_blue,
        backgroundColorRes = R.color.white,
        titleColorRes = R.color.gray_900,
        descriptionColorRes = R.color.gray_500
    )

    class AlertSuccess(
        override val title: String? = null,
        override val description: String? = null,
        override val tag: String? = null
    ) : AlertMetadata(
        iconRes = R.drawable.ic_check,
        iconTintRes = R.color.white,
        backgroundColorRes = R.color.turquoise_600,
        titleColorRes = R.color.white,
        descriptionColorRes = R.color.white
    )

    class AlertError(
        override val title: String? = null,
        override val description: String? = null,
        override val tag: String? = null
    ) : AlertMetadata(
        iconRes = R.drawable.ic_error,
        iconTintRes = R.color.white,
        backgroundColorRes = R.color.salmon_600,
        titleColorRes = R.color.white,
        descriptionColorRes = R.color.white
    )

    class AlertCustom(
        override val iconRes: Int? = null,
        override val iconTintRes: Int? = null,
        override val backgroundColorRes: Int = R.color.white,
        override val title: String? = null,
        override val titleColorRes: Int = R.color.gray_900,
        override val description: String? = null,
        override val descriptionColorRes: Int = R.color.gray_500,
        override val metadata: Any? = null,
        override val tag: String? = null
    ) : AlertMetadata()

    @Suppress("MagicNumber")
    override fun hashCode(): Int {
        var result = iconRes.hashCode()
        result = 31 * result + iconTintRes.hashCode()
        result = 31 * result + backgroundColorRes.hashCode()
        result = 31 * result + title.hashCode()
        result = 31 * result + titleColorRes.hashCode()
        result = 31 * result + description.hashCode()
        result = 31 * result + descriptionColorRes.hashCode()
        result = 31 * result + metadata.hashCode()
        result = 31 * result + tag.hashCode()
        return result
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is AlertMetadata) return false

        if (iconRes != other.iconRes) return false
        if (iconTintRes != other.iconTintRes) return false
        if (backgroundColorRes != other.backgroundColorRes) return false
        if (title != other.title) return false
        if (titleColorRes != other.titleColorRes) return false
        if (description != other.description) return false
        if (descriptionColorRes != other.descriptionColorRes) return false
        if (metadata != other.metadata) return false
        if (tag != other.tag) return false

        return true
    }
}
