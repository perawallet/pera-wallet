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

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.provider.MediaStore
import androidx.activity.result.ActivityResultLauncher
import androidx.core.app.ShareCompat
import androidx.core.content.FileProvider
import androidx.fragment.app.Fragment
import com.algorand.android.BuildConfig
import java.io.File
import java.io.FileOutputStream

const val IMAGE_FILE_MIME_TYPE = "image/jpeg"
const val CSV_FILE_MIME_TYPE = "text/csv"
const val IMAGE_READ_REQUEST = 1010

private const val IMAGE_QUALITY = 100

fun Context.openTextShareBottomMenuChooser(text: String, title: String) {
    val sharingIntent = Intent(Intent.ACTION_SEND)
    sharingIntent.type = "text/plain"
    sharingIntent.putExtra(Intent.EXTRA_TEXT, text)
    startActivity(Intent.createChooser(sharingIntent, title))
}

fun Fragment.startImagePickerIntent() {
    val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
    startActivityForResult(Intent.createChooser(intent, ""), IMAGE_READ_REQUEST)
}

fun Fragment.openImageShareBottomMenu(bitmap: Bitmap, activityResultLauncher: ActivityResultLauncher<Intent>): File? {
    var tempFileDirectory: File? = null
    try {
        tempFileDirectory = File(requireContext().cacheDir, "/temp.jpg")
        val outStream = FileOutputStream(tempFileDirectory, false)
        bitmap.compress(Bitmap.CompressFormat.JPEG, IMAGE_QUALITY, outStream)
        outStream.flush()
        outStream.close()
    } catch (exception: Exception) {
        tempFileDirectory?.delete()
        recordException(exception)
        return null
    }

    return shareFile(tempFileDirectory, IMAGE_FILE_MIME_TYPE, activityResultLauncher)
}

fun Fragment.shareFile(file: File, type: String, activityResultLauncher: ActivityResultLauncher<Intent>): File {
    try {
        val uri = FileProvider.getUriForFile(
            requireContext(),
            "${BuildConfig.APPLICATION_ID}.fileprovider",
            file
        )

        val sharingIntent = ShareCompat.IntentBuilder.from(requireActivity())
            .setType(type)
            .setStream(uri)
            .createChooserIntent()
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        activityResultLauncher.launch(sharingIntent)
    } catch (exception: Exception) {
        file.delete()
        recordException(exception)
    }

    return file
}
