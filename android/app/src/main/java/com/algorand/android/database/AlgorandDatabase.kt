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

package com.algorand.android.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.algorand.android.database.AlgorandDatabase.Companion.LATEST_DB_VERSION
import com.algorand.android.models.Node
import com.algorand.android.models.NotificationFilter
import com.algorand.android.models.User
import com.algorand.android.models.WalletConnectSessionEntity
import com.algorand.android.models.WalletConnectSessionHistoryEntity

@Suppress("MagicNumber", "MaxLineLength")
@Database(
    entities = [
        User::class,
        Node::class,
        NotificationFilter::class,
        WalletConnectSessionEntity::class,
        WalletConnectSessionHistoryEntity::class
    ],
    version = LATEST_DB_VERSION,
    exportSchema = true
)
@TypeConverters(WalletConnectTypeConverters::class)
abstract class AlgorandDatabase : RoomDatabase() {
    abstract fun contactDao(): ContactDao
    abstract fun nodeDao(): NodeDao
    abstract fun notificationFilterDao(): NotificationFilterDao
    abstract fun walletConnect(): WalletConnectDao
    abstract fun walletConnectSessionHistoryDao(): WalletConnectSessionHistoryDao

    companion object {
        const val LATEST_DB_VERSION = 8

        val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Node ADD COLUMN networkSlug TEXT NOT NULL DEFAULT ''")
            }
        }

        val MIGRATION_4_5 = object : Migration(4, 5) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("DROP TABLE Node")
                database.execSQL(
                    """
                        CREATE TABLE Node (name TEXT NOT NULL, indexer_address TEXT NOT NULL,
                            indexer_api_key TEXT NOT NULL, algod_address TEXT NOT NULL, algod_api_key TEXT NOT NULL,
                            is_active INTEGER NOT NULL, is_added_default INTEGER NOT NULL, network_slug TEXT NOT NULL,
                            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
                        )
                        """.trimIndent()
                )
            }
        }

        val MIGRATION_5_6 = object : Migration(5, 6) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    "CREATE TABLE IF NOT EXISTS NotificationFilter (`public_key` TEXT NOT NULL, PRIMARY KEY(`public_key`))"
                )
            }
        }

        val MIGRATION_6_7 = object : Migration(6, 7) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    """
                        CREATE TABLE IF NOT EXISTS WalletConnectSessionEntity (
                            id INTEGER NOT NULL,
                            peer_meta TEXT NOT NULL,
                            wc_session TEXT NOT NULL,
                            date_time_stamp INTEGER NOT NULL,
                            connected_account_public_key TEXT NOT NULL,
                            is_connected INTEGER NOT NULL,
                            PRIMARY KEY(id)
                        )
                    """.trimIndent()
                )
                database.execSQL(
                    """
                        CREATE TABLE IF NOT EXISTS WalletConnectSessionHistoryEntity (
                            id INTEGER NOT NULL,
                            peer_meta TEXT NOT NULL,
                            wc_session TEXT NOT NULL,
                            creation_date_time_stamp INTEGER NOT NULL,
                            connected_account_public_key TEXT NOT NULL,
                            PRIMARY KEY(id)
                        )
                    """.trimIndent()
                )
            }
        }

        val MIGRATION_7_8 = object : Migration(7, 8) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Node ADD COLUMN mobile_algorand_address TEXT NOT NULL DEFAULT ''")
            }
        }

        const val DATABASE_NAME = "algorand-db"
    }
}
