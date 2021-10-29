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

package com.algorand.android.dependencyinjection

import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.ContextCompat
import androidx.room.Room
import com.algorand.android.core.AccountManager
import com.algorand.android.database.AlgorandDatabase
import com.algorand.android.database.AlgorandDatabase.Companion.MIGRATION_3_4
import com.algorand.android.database.AlgorandDatabase.Companion.MIGRATION_4_5
import com.algorand.android.database.AlgorandDatabase.Companion.MIGRATION_5_6
import com.algorand.android.database.AlgorandDatabase.Companion.MIGRATION_6_7
import com.algorand.android.database.ContactDao
import com.algorand.android.database.NodeDao
import com.algorand.android.database.NotificationFilterDao
import com.algorand.android.database.WalletConnectDao
import com.algorand.android.database.WalletConnectTypeConverters
import com.algorand.android.ledger.LedgerBleConnectionManager
import com.algorand.android.notification.AlgorandNotificationManager
import com.algorand.android.utils.ALGORAND_KEYSTORE_URI
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.AutoLockManager
import com.algorand.android.utils.ENCRYPTED_SHARED_PREF_NAME
import com.algorand.android.utils.KEYSET_HANDLE
import com.algorand.android.utils.preference.SETTINGS
import com.google.crypto.tink.Aead
import com.google.crypto.tink.KeysetHandle
import com.google.crypto.tink.aead.AeadFactory
import com.google.crypto.tink.aead.AeadKeyTemplates
import com.google.crypto.tink.config.TinkConfig
import com.google.crypto.tink.integration.android.AndroidKeysetManager
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.gson.Gson
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Singleton

@Suppress("TooManyFunctions")
@Module
@InstallIn(ApplicationComponent::class)
object AppModule {

    @Singleton
    @Provides
    fun provideDatabase(
        @ApplicationContext appContext: Context,
        walletConnectTypeConverters: WalletConnectTypeConverters
    ): AlgorandDatabase {
        return Room
            .databaseBuilder(appContext, AlgorandDatabase::class.java, AlgorandDatabase.DATABASE_NAME)
            .fallbackToDestructiveMigration()
            .addMigrations(MIGRATION_3_4, MIGRATION_4_5, MIGRATION_5_6, MIGRATION_6_7)
            .addTypeConverter(walletConnectTypeConverters)
            .build()
    }

    @Singleton
    @Provides
    fun getEncryptionAead(@ApplicationContext appContext: Context): Aead {
        TinkConfig.register()

        val algorandKeysetHandle: KeysetHandle = AndroidKeysetManager.Builder()
            .withSharedPref(appContext, KEYSET_HANDLE, ENCRYPTED_SHARED_PREF_NAME)
            .withKeyTemplate(AeadKeyTemplates.AES256_GCM)
            .withMasterKeyUri(ALGORAND_KEYSTORE_URI)
            .build()
            .keysetHandle

        return AeadFactory.getPrimitive(algorandKeysetHandle)
    }

    @Singleton
    @Provides
    fun provideSettingsSharedPref(@ApplicationContext appContext: Context): SharedPreferences {
        return appContext.getSharedPreferences(SETTINGS, Context.MODE_PRIVATE)
    }

    @Singleton
    @Provides
    fun provideNodeDao(database: AlgorandDatabase): NodeDao {
        return database.nodeDao()
    }

    @Singleton
    @Provides
    fun provideNotificationFilterDao(database: AlgorandDatabase): NotificationFilterDao {
        return database.notificationFilterDao()
    }

    @Singleton
    @Provides
    fun provideContactDao(database: AlgorandDatabase): ContactDao {
        return database.contactDao()
    }

    @Singleton
    @Provides
    fun provideWalletConnectDao(database: AlgorandDatabase): WalletConnectDao {
        return database.walletConnect()
    }

    @Singleton
    @Provides
    fun provideAlgorandNotificationManager(): AlgorandNotificationManager {
        return AlgorandNotificationManager()
    }

    @Singleton
    @Provides
    fun provideAccountCacheManager(accountManager: AccountManager): AccountCacheManager {
        return AccountCacheManager(accountManager)
    }

    @Singleton
    @Provides
    fun provideAccountManager(aead: Aead, gson: Gson, sharedPref: SharedPreferences): AccountManager {
        return AccountManager(aead, gson, sharedPref)
    }

    @Singleton
    @Provides
    fun provideLedgerBleConnectionManager(@ApplicationContext appContext: Context): LedgerBleConnectionManager {
        return LedgerBleConnectionManager(appContext)
    }

    @Singleton
    @Provides
    fun provideBluetoothManager(@ApplicationContext appContext: Context): BluetoothManager? {
        return ContextCompat.getSystemService<BluetoothManager>(appContext, BluetoothManager::class.java)
    }

    @Singleton
    @Provides
    fun provideAutoLockManager(): AutoLockManager {
        return AutoLockManager()
    }

    @Singleton
    @Provides
    fun provideFirebaseAnalytics(@ApplicationContext appContext: Context): FirebaseAnalytics {
        return FirebaseAnalytics.getInstance(appContext)
    }
}
