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

package com.algorand.android.modules.webexport.common.data.mapper

import com.algorand.android.models.WebQrCode
import com.algorand.android.modules.webexport.common.data.model.WebExportQrCode
import javax.inject.Inject

class WebExportQrCodeMapper @Inject constructor() {

    fun mapFromWebQrCode(
        webQrCode: WebQrCode,
    ): WebExportQrCode? {
        return if (
            isRecognized(webQrCode) &&
            webQrCode.action == WebQrCode.ACTION_EXPORT_KEY &&
            webQrCode.modificationKey != null
        ) {
            WebExportQrCode(
                backupId = webQrCode.backupId,
                modificationKey = webQrCode.modificationKey,
                encryptionKey = webQrCode.encryptionKey
            )
        } else {
            null
        }
    }

    private fun isRecognized(webQrCode: WebQrCode): Boolean {
        val intVersion = webQrCode.version.toIntOrNull() ?: return false
        return intVersion <= WebQrCode.CURRENT_QR_CODE_VERSION
    }
}
