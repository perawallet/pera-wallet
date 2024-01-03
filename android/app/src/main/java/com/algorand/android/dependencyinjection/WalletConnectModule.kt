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

package com.algorand.android.dependencyinjection

import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.utils.walletconnect.WalletConnectEventLogger
import com.algorand.android.utils.walletconnect.WalletConnectFirebaseEventLogger
import com.google.firebase.analytics.FirebaseAnalytics
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectModule {

    @Provides
    fun provideWalletConnectEventLogger(
        firebaseAnalytics: FirebaseAnalytics,
        algodInterceptor: AlgodInterceptor
    ): WalletConnectEventLogger {
        return WalletConnectFirebaseEventLogger(firebaseAnalytics, algodInterceptor)
    }
}
