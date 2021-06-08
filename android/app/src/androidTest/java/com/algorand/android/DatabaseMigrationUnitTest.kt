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
import com.algorand.android.utils.defaultNodeList
import java.io.IOException
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class DatabaseMigrationUnitTest {

    private val allMigrations =
        listOf(AlgorandDatabase.MIGRATION_3_4, AlgorandDatabase.MIGRATION_4_5, AlgorandDatabase.MIGRATION_5_6)
    private var migratedDb: SupportSQLiteDatabase? = null

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
        val cursor: Cursor = migratedDb!!.query(queryString, null)
        Log.d(TAG, "Node DB: ${DatabaseUtils.dumpCursorToString(cursor)}")
        Log.d(TAG, "Node Count in Database: ${cursor.count}")
        Assert.assertTrue("Nodes Count After Migration Not Successful", cursor.count == 2)
    }

    @Test
    fun insertUserToDatabase() {
        migratedDb!!.insertUser("LastPublicKey")
        val queryString = "SELECT * FROM User"
        val cursor = migratedDb!!.query(queryString, null)
        Log.d(TAG, "User DB: ${DatabaseUtils.dumpCursorToString(cursor)}")
        Log.d(TAG, "User Count in Database: ${cursor.count}")
        Assert.assertTrue("Users Count After Migration Not Successful", cursor.count == 2)
    }

    @After
    fun closeMigratedDatabase() {
        migratedDb?.close()
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
                INSERT INTO Node (name, indexer_address, indexer_api_key, algod_address, algod_api_key, is_active, 
                is_added_default, network_slug)
                VALUES ('$name', '$indexerAddress', '$indexerApiKey', '$algodAddress', '$algodApiKey', 
                         ${if (isActive) 1 else 0}, ${if (isAddedDefault) 1 else 0}, '$networkSlug')
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
