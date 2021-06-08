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

import android.content.SharedPreferences

private const val LOCK_PREFERENCE_COUNT_KEY = "lock_preference_count_key"
const val DONT_SHOW_AGAIN_COUNT = -1
const val DEFAULT_LOCK_PREFERENCE_COUNT = 0

fun SharedPreferences.setLockPreferenceCount(lockCount: Int) {
    edit().putInt(LOCK_PREFERENCE_COUNT_KEY, lockCount).apply()
}

fun SharedPreferences.setLockDontAskAgain() {
    edit().putInt(LOCK_PREFERENCE_COUNT_KEY, DONT_SHOW_AGAIN_COUNT).apply()
}

fun SharedPreferences.getLockPreferenceCount(): Int {
    return getInt(LOCK_PREFERENCE_COUNT_KEY, DEFAULT_LOCK_PREFERENCE_COUNT)
}
