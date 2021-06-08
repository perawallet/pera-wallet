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

package com.algorand.android.utils.preference

import android.content.Context
import android.content.SharedPreferences
import com.algorand.android.models.Account
import com.algorand.android.models.Currency
import com.algorand.android.utils.encryptString
import com.algorand.android.utils.parseFormattedDate
import com.google.crypto.tink.Aead
import com.google.gson.Gson
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

// <editor-fold defaultstate="collapsed" desc="Constants">

private const val USE_BIOMETRIC_KEY = "use_biometric"
private const val ALGORAND_ACCOUNTS_KEY = "algorand_accounts"
private const val LOCK_PASSWORD = "lock_password"
private const val LOCK_ATTEMPT_COUNT_KEY = "lock_attempt_count"
private const val LOCK_PENALTY_REMAINING_KEY = "lock_penalty_remaining"
private const val NOTIFICATION_USER_ID_KEY = "notification_user_id"
private const val DEFAULT_NODE_LIST_VERSION = "default_node_list_version"
private const val REWARDS_ACTIVATED_KEY = "rewards_activated"
private const val NOTIFICATION_ACTIVATED_KEY = "notification_activated"
private const val QR_TUTORIAL_SHOWN_KEY = "qr_tutorial_shown_key"
private const val TD_COPY_TUTORIAL_SHOWN_KEY = "transaction_detail_copy_shown_key"
private const val FILTER_TUTORIAL_SHOWN_KEY = "filter_tutorial_shown_key"
private const val NOTIFICATION_REFRESH_DATE_KEY = "notification_refresh_date_key"
private const val CURRENCY_PREFERENCE_KEY = "currency_preference_key"
private const val APP_REVIEW_START_COUNT_KEY = "app_review_start_count_key"
private const val REGISTER_SKIP_KEY = "register_skip_key"
const val SETTINGS = "algorand_settings"

// </editor-fold>

fun Context.getSettingsSharedPref(): SharedPreferences = getSharedPreferences(SETTINGS, Context.MODE_PRIVATE)

fun SharedPreferences.removeAll() {
    edit()
        .clear()
        .putBoolean(QR_TUTORIAL_SHOWN_KEY, isQrTutorialShown())
        .putBoolean(TD_COPY_TUTORIAL_SHOWN_KEY, isTransactionDetailCopyTutorialShown())
        .putBoolean(FILTER_TUTORIAL_SHOWN_KEY, isFilterTutorialShown())
        .putString(NOTIFICATION_USER_ID_KEY, getNotificationUserId())
        .apply()
}

// <editor-fold defaultstate="collapsed" desc="Accounts">

fun SharedPreferences.saveAlgorandAccounts(gson: Gson, accountsList: List<Account>, aead: Aead) {
    edit().putString(ALGORAND_ACCOUNTS_KEY, aead.encryptString(gson.toJson(accountsList))).apply()
}

fun SharedPreferences.getEncryptedAlgorandAccounts() = getString(ALGORAND_ACCOUNTS_KEY, null)

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="Password">

fun SharedPreferences.savePassword(newPassword: String) = edit().putString(LOCK_PASSWORD, newPassword).apply()

fun SharedPreferences.getPassword() = getString(LOCK_PASSWORD, null)

fun SharedPreferences.isPasswordChosen() = getString(LOCK_PASSWORD, null) != null

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="NotificationUserId">

fun SharedPreferences.setNotificationUserId(userId: String) {
    edit().putString(NOTIFICATION_USER_ID_KEY, userId).apply()
}

fun SharedPreferences.getNotificationUserId() = getString(NOTIFICATION_USER_ID_KEY, null)

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="Notification">
fun SharedPreferences.isNotificationActivated() = getBoolean(NOTIFICATION_ACTIVATED_KEY, true)

fun SharedPreferences.setNotificationPreference(enableNotifications: Boolean) {
    edit().putBoolean(NOTIFICATION_ACTIVATED_KEY, enableNotifications).apply()
}

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="Rewards">
fun SharedPreferences.isRewardsActivated() = getBoolean(REWARDS_ACTIVATED_KEY, true)

fun SharedPreferences.setRewardsPreference(enableRewards: Boolean) {
    edit().putBoolean(REWARDS_ACTIVATED_KEY, enableRewards).apply()
}

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="NodeList">
fun SharedPreferences.getDefaultNodeListVersion() = getInt(DEFAULT_NODE_LIST_VERSION, 0)

fun SharedPreferences.setNodeListVersion(newVersion: Int) {
    edit().putInt(DEFAULT_NODE_LIST_VERSION, newVersion).apply()
}

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="Biometric">

fun SharedPreferences.setBiometricRegistrationPreference(enableBiometric: Boolean) {
    edit().putBoolean(USE_BIOMETRIC_KEY, enableBiometric).apply()
}

fun SharedPreferences.isBiometricActive() = getBoolean(USE_BIOMETRIC_KEY, false)

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="LockPinAttempt">

fun SharedPreferences.setLockAttemptCount(lockAttemptCount: Int) {
    edit().putInt(LOCK_ATTEMPT_COUNT_KEY, lockAttemptCount).apply()
}

fun SharedPreferences.getLockAttemptCount() = getInt(LOCK_ATTEMPT_COUNT_KEY, 0)

fun SharedPreferences.setLockPenaltyRemainingTime(penaltyRemainingTime: Long) {
    edit().putLong(LOCK_PENALTY_REMAINING_KEY, penaltyRemainingTime).apply()
}

fun SharedPreferences.getLockPenaltyRemainingTime() = getLong(LOCK_PENALTY_REMAINING_KEY, 0)

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="QRTutorialShown">

fun SharedPreferences.setQrTutorialShown() {
    edit().putBoolean(QR_TUTORIAL_SHOWN_KEY, true).apply()
}

fun SharedPreferences.isQrTutorialShown() = getBoolean(QR_TUTORIAL_SHOWN_KEY, false)

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="TDCopyShown">

fun SharedPreferences.setTransactionDetailCopyShown() {
    edit().putBoolean(TD_COPY_TUTORIAL_SHOWN_KEY, true).apply()
}

fun SharedPreferences.isTransactionDetailCopyTutorialShown() = getBoolean(TD_COPY_TUTORIAL_SHOWN_KEY, false)

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="TDCopyShown">

fun SharedPreferences.setFilterTutorialShown() {
    edit().putBoolean(FILTER_TUTORIAL_SHOWN_KEY, true).apply()
}

fun SharedPreferences.isFilterTutorialShown() = getBoolean(FILTER_TUTORIAL_SHOWN_KEY, false)

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="CurrencyPreference">

private val defaultCurrencyPreference = Currency.USD.id

fun SharedPreferences.setCurrencyPreference(currencyId: String) {
    edit().putString(CURRENCY_PREFERENCE_KEY, currencyId).apply()
}

fun SharedPreferences.getCurrencyPreference(): String {
    return getString(CURRENCY_PREFERENCE_KEY, defaultCurrencyPreference) ?: defaultCurrencyPreference
}

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="NotificationRefreshDate">

// ISO-8601 ISO_DATE_TIME
fun SharedPreferences.setNotificationRefreshDate(notificationRefreshDate: ZonedDateTime) {
    edit()
        .putString(NOTIFICATION_REFRESH_DATE_KEY, notificationRefreshDate.format(DateTimeFormatter.ISO_DATE_TIME))
        .apply()
}

fun SharedPreferences.getNotificationRefreshDateTime(): ZonedDateTime {
    return getString(NOTIFICATION_REFRESH_DATE_KEY, null)
        .parseFormattedDate(DateTimeFormatter.ISO_DATE_TIME) ?: ZonedDateTime.now()
}

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="NotificationRefreshDate">

fun SharedPreferences.setAppReviewStartCount(appReviewStartCount: Int) {
    edit().putInt(APP_REVIEW_START_COUNT_KEY, appReviewStartCount).apply()
}

fun SharedPreferences.getAppReviewStartCount(): Int {
    return getInt(APP_REVIEW_START_COUNT_KEY, 0)
}

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="NotificationRefreshDate">

fun SharedPreferences.setRegisterSkip() {
    edit().putBoolean(REGISTER_SKIP_KEY, true).apply()
}

fun SharedPreferences.getRegisterSkip(): Boolean {
    return getBoolean(REGISTER_SKIP_KEY, false)
}

// </editor-fold>
