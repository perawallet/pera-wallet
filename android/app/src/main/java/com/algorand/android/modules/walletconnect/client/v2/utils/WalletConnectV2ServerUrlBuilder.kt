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

package com.algorand.android.modules.walletconnect.client.v2.utils

import java.net.URI

class WalletConnectV2ServerUrlBuilder private constructor() {

    private var projectId: String? = null

    fun addProjectId(projectId: String): WalletConnectV2ServerUrlBuilder {
        this.projectId = projectId
        return this
    }

    fun build(): String {
        return URI(SERVER_URL_SCHEME, SERVER_URL_HOST, null, getProjectIdQuery(), null).toString()
    }

    private fun getProjectIdQuery() = "$PROJECT_ID_QUERY_KEY=$projectId"

    companion object {

        fun create(): WalletConnectV2ServerUrlBuilder {
            return WalletConnectV2ServerUrlBuilder()
        }

        private const val SERVER_URL_SCHEME = "wss"
        private const val SERVER_URL_HOST = "relay.walletconnect.com"
        private const val PROJECT_ID_QUERY_KEY = "projectId"
    }
}
