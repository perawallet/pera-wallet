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

package com.algorand.android.utils

import android.os.Bundle
import android.view.MenuItem
import androidx.annotation.IdRes
import androidx.annotation.NonNull
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.setFragmentResult
import androidx.fragment.app.setFragmentResultListener
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavController
import androidx.navigation.NavDirections
import androidx.navigation.NavOptions
import androidx.navigation.fragment.FragmentNavigator
import com.algorand.android.CoreMainActivity
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.google.android.material.bottomnavigation.BottomNavigationView
import kotlinx.coroutines.launch

fun BottomNavigationView.setupWithNavController(
    navController: NavController,
    onMenuItemClicked: (item: MenuItem) -> Unit
) {
    setOnItemSelectedListener { item ->
        onMenuItemClicked(item)
        return@setOnItemSelectedListener onNavDestinationChanged(item, navController)
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
    val navBackStackEntry: NavBackStackEntry?
    try {
        navBackStackEntry = (activity as? CoreMainActivity)?.navController?.getBackStackEntry(fragmentId)
    } catch (exception: Exception) {
        recordException(exception)
        return
    }

    if (navBackStackEntry != null) {
        // TODO need to have an extensive check on this one
        val job = lifecycleScope.launch {
            navBackStackEntry.lifecycle.repeatOnLifecycle(Lifecycle.State.RESUMED) {
                savedStateListener(navBackStackEntry)
            }
        }

        viewLifecycleOwner.lifecycle.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if (event == Lifecycle.Event.ON_DESTROY) {
                    job.cancel()
                }
            }
        })
    }
}

fun <T> Fragment.setNavigationResult(key: String, value: T) {
    (activity as? MainActivity)?.navController?.previousBackStackEntry?.savedStateHandle?.set(key, value)
}

fun <T> Fragment.listenToNavigationResult(
    key: String,
    callback: (T) -> Unit
) {
    (activity as? MainActivity)?.navController?.currentBackStackEntry?.savedStateHandle?.getLiveData<T>(key)?.observe(
        viewLifecycleOwner
    ) { result ->
        callback.invoke(result)
    }
}

fun FragmentActivity?.getNavigationBackStackCount(): Int {
    return this?.supportFragmentManager?.primaryNavigationFragment?.childFragmentManager?.backStackEntryCount ?: 0
}

fun NavController.navigateSafe(@NonNull directions: NavDirections, onError: (() -> Unit)? = null) {
    try {
        navigate(directions)
    } catch (exception: IllegalArgumentException) {
        onError?.invoke()
        recordException(exception)
    }
}

fun NavController.navigateSafe(@IdRes resId: Int, args: Bundle?, navOptions: NavOptions) {
    try {
        navigate(resId, args, navOptions)
    } catch (exception: IllegalArgumentException) {
        recordException(exception)
    }
}

fun NavController.navigateSafe(directions: NavDirections, extras: FragmentNavigator.Extras) {
    try {
        navigate(directions, extras)
    } catch (exception: IllegalArgumentException) {
        recordException(exception)
    }
}

fun <T> Fragment.setFragmentNavigationResult(key: String, value: T) {
    setFragmentResult(
        requestKey = key,
        result = bundleOf(key to value)
    )
}

fun <T> Fragment.useFragmentResultListenerValue(key: String, result: (T) -> Unit) {
    setFragmentResultListener(
        requestKey = key,
        listener = { requestKey, bundle ->
            try {
                val value = bundle.get(requestKey) as T
                result.invoke(value)
            } catch (classCastException: ClassCastException) {
                // TODO: We may have better exception handling in this case
                recordException(classCastException)
            }
        }
    )
}
