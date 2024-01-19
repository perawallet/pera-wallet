package com.algorand.android

import android.database.Cursor
import android.database.DatabaseUtils
import android.util.Log
import androidx.room.testing.MigrationTestHelper
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.sqlite.db.framework.FrameworkSQLiteOpenHelperFactory
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.AndroidJUnit4
import com.algorand.android.database.AlgorandDatabase
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSessionMeta
import com.algorand.android.utils.defaultNodeList
import com.google.gson.Gson
import java.io.IOException
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class DatabaseMigrationUnitTest {

    private val allMigrations = listOf(
        AlgorandDatabase.MIGRATION_3_4,
        AlgorandDatabase.MIGRATION_4_5,
        AlgorandDatabase.MIGRATION_5_6,
        AlgorandDatabase.MIGRATION_6_7,
        AlgorandDatabase.MIGRATION_7_8,
        AlgorandDatabase.MIGRATION_8_9,
        AlgorandDatabase.MIGRATION_9_10,
        AlgorandDatabase.MIGRATION_10_11
    )
    private var migratedDb: SupportSQLiteDatabase? = null
    private lateinit var gson: Gson

    @Rule
    @JvmField
    val helper: MigrationTestHelper = MigrationTestHelper(
        InstrumentationRegistry.getInstrumentation(),
        AlgorandDatabase::class.java.canonicalName,
        FrameworkSQLiteOpenHelperFactory()
    )

    @Before
    @Test
    @Throws(IOException::class)
    fun migrate3ToLastVersion() {
        gson = Gson()
        migratedDb = helper.createDatabase(TEST_DB, 3).apply {
            insertNodeToDatabaseV3()
            insertUser("FirstPublicKey")
        }

        migratedDb = helper.runMigrationsAndValidate(
            TEST_DB,
            AlgorandDatabase.LATEST_DB_VERSION,
            true,
            *allMigrations.toTypedArray()
        )
    }

    @Test
    fun insertNodeToDatabase() {
        migratedDb!!.insertNodeToDatabaseLatestVersion()
        val queryString = "SELECT * FROM Node"
        val cursor: Cursor = migratedDb!!.query(queryString, emptyArray())
        Log.d(TAG, "Node DB: ${DatabaseUtils.dumpCursorToString(cursor)}")
        Log.d(TAG, "Node Count in Database: ${cursor.count}")
        Assert.assertTrue("Nodes Count After Migration Not Successful", cursor.count == defaultNodeList.count())
    }

    @Test
    fun insertUserToDatabase() {
        migratedDb!!.insertUser("LastPublicKey")
        val queryString = "SELECT * FROM User"
        val cursor = migratedDb!!.query(queryString, emptyArray())
        Log.d(TAG, "User DB: ${DatabaseUtils.dumpCursorToString(cursor)}")
        Log.d(TAG, "User Count in Database: ${cursor.count}")
        Assert.assertTrue("Users Count After Migration Not Successful", cursor.count == 2)
    }

    @Test
    fun insertWalletConnectSessionToDatabase() {
        migratedDb!!.insertWalletConnectSession()
        val queryString = "SELECT * FROM WalletConnectSessionEntity"
        val cursor = migratedDb!!.query(queryString, emptyArray())
        Log.d(TAG, "WalletConnectSessionEntity DB :${DatabaseUtils.dumpCursorToString(cursor)}")
        Log.d(TAG, "Session count in Database: ${cursor.count}")
        Assert.assertTrue("WalletConnectSession Count After Migration Not Successful", cursor.count == 1)
    }

    @Test
    fun insertWalletConnectSessionAccountToDatabase() {
        migratedDb!!.insertWalletConnectSessionAccount()
        val queryString = "SELECT * FROM WalletConnectSessionAccountEntity"
        val cursor = migratedDb!!.query(queryString, emptyArray())
        Log.d(TAG, "WalletConnectSessionAccountEntity DB :${DatabaseUtils.dumpCursorToString(cursor)}")
        Log.d(TAG, "Connected account count in Database: ${cursor.count}")
        Assert.assertTrue("WalletConnectSession Count After Migration Not Successful", cursor.count == 1)
    }

    @After
    fun closeMigratedDatabase() {
        migratedDb?.close()
    }

    private fun SupportSQLiteDatabase.insertWalletConnectSession() {
        val peerMetaJson = gson.toJson(WalletConnectPeerMeta("name", "url", "description", listOf("icon_url")))
        val sessionMetaJson = gson.toJson(WalletConnectSessionMeta("bridge", "key", "topic", "version"))
        val fallbackBrowserGroupResponse = "chrome"
        execSQL(
            """
                INSERT INTO WalletConnectSessionEntity (
                    id, 
                    peer_meta,
                    wc_session,
                    date_time_stamp, 
                    is_connected,
                    is_subscribed,
                    fallback_browser_group_response
                )
                VALUES (
                    1625574947350,
                    '$peerMetaJson',
                    '$sessionMetaJson',
                    1625574947350,
                    0,
                    0,
                    '$fallbackBrowserGroupResponse'
                )
            """.trimIndent()
        )
    }

    private fun SupportSQLiteDatabase.insertWalletConnectSessionAccount() {
        val address = "KFQMT4AK4ASIPAN23X36T3REP6D26LQDMAQNSAZM3DIEG2HTVKXEF76AP4"
        execSQL(
            """
                INSERT INTO WalletConnectSessionAccountEntity (
                    id, 
                    session_id,
                    connected_account_address
                )
                VALUES (
                    1,
                    1625574947350,
                    '$address'
                )
            """.trimIndent()
        )
    }

    private fun SupportSQLiteDatabase.insertUser(publicKey: String) {
        execSQL(
            """
                INSERT INTO User (name, public_key, uri)
                VALUES ('contactName', '$publicKey', 'uri')
                """.trimIndent()
        )
    }

    private fun SupportSQLiteDatabase.insertNodeToDatabaseV3() {
        execSQL(
            """
                INSERT INTO Node (name, address, apiKey, isActive, isAddedDefault, id) 
                VALUES ('name1', 'address', 'api_key', 0, 1, 1)
                """.trimIndent()
        )
    }

    private fun SupportSQLiteDatabase.insertNodeToDatabaseLatestVersion() {
        defaultNodeList.forEach {
            with(it) {
                execSQL(
                    """
                INSERT INTO Node (name, indexer_address, indexer_api_key, algod_address, algod_api_key,  
                mobile_algorand_address, is_active, is_added_default, network_slug)
                VALUES ('$name', '$indexerAddress', '$indexerApiKey', '$algodAddress', '$algodApiKey',
                 '$mobileAlgorandAddress', ${if (isActive) 1 else 0}, ${if (isAddedDefault) 1 else 0}, '$networkSlug')
                """.trimIndent()
                )
            }
        }
    }

    companion object {
        private const val TEST_DB = "migration-test"
        private val TAG = DatabaseMigrationUnitTest::class.java.simpleName
    }
}
