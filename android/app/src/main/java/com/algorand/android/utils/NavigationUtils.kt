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

package com.algorand.android.utils

import android.os.Bundle
import android.view.MenuItem
import androidx.annotation.IdRes
import androidx.annotation.NonNull
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavController
import androidx.navigation.NavDirections
import androidx.navigation.NavOptions
import com.algorand.android.CoreMainActivity
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.firebase.crashlytics.FirebaseCrashlytics

fun BottomNavigationView.setupWithNavController(navController: NavController) {
    setOnNavigationItemSelectedListener { item ->
        return@setOnNavigationItemSelectedListener onNavDestinationChanged(item, navController)
    }
}

private fun onNavDestinationChanged(
    item: MenuItem,
    navController: NavController
): Boolean {
    val builder = NavOptions.Builder()
        .setPopUpTo(R.id.mainNavigation, true)
    navController.navigateSafe(item.itemId, null, builder.build())
    return true
}

fun <T> NavBackStackEntry.useSavedStateValue(key: String, handler: (T) -> Unit) {
    if (savedStateHandle.contains(key)) {
        savedStateHandle.get<T>(key)?.let { newValue ->
            handler(newValue)
        }
        savedStateHandle.remove<T>(key)
    }
}

// Used for transferring data from dialog.
fun Fragment.startSavedStateListener(fragmentId: Int, savedStateListener: NavBackStackEntry.() -> Unit) {
    var navBackStackEntry: NavBackStackEntry? = null
    try {
        navBackStackEntry = (activity as? CoreMainActivity)?.navController?.getBackStackEntry(fragmentId)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        return
    }

    if (navBackStackEntry != null) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                // coroutine launch is added to wait for layout to be laid out.
                viewLifecycleOwner.lifecycleScope.launchWhenResumed {
                    savedStateListener(navBackStackEntry)
                }
            }
        }

        navBackStackEntry.lifecycle.addObserver(observer)

        viewLifecycleOwner.lifecycle.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if (event == Lifecycle.Event.ON_DESTROY) {
                    navBackStackEntry.lifecycle.removeObserver(observer)
                }
            }
        })
    }
}

fun <T> Fragment.setNavigationResult(key: String, value: T) {
    (activity as? MainActivity)?.navController?.previousBackStackEntry?.savedStateHandle?.set(key, value)
}

fun FragmentActivity?.getNavigationBackStackCount(): Int {
    return this?.supportFragmentManager?.primaryNavigationFragment?.childFragmentManager?.backStackEntryCount ?: 0
}

fun NavController.navigateSafe(@NonNull directions: NavDirections) {
    try {
        navigate(directions)
    } catch (exception: IllegalArgumentException) {
        FirebaseCrashlytics.getInstance().recordException(exception)
    }
}

fun NavController.navigateSafe(@IdRes resId: Int, args: Bundle?, navOptions: NavOptions) {
    try {
        navigate(resId, args, navOptions)
    } catch (exception: IllegalArgumentException) {
        FirebaseCrashlytics.getInstance().recordException(exception)
    }
}
