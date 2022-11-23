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

package com.algorand.android

import android.content.Context
import android.text.Annotation
import android.text.SpannedString
import android.text.style.ForegroundColorSpan
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.test.platform.app.InstrumentationRegistry
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setXmlStyledString
import com.algorand.android.utils.supportedLanguages
import java.util.Locale
import org.junit.Test

class StringValidationTest {

    private val context = InstrumentationRegistry.getInstrumentation().targetContext

    private val replacementRandomString = "replacementRandomString"
    private val foregroundColorSpan = ForegroundColorSpan(ContextCompat.getColor(context, R.color.link_primary))
    private val iconReplacementRandomIconId = R.drawable.ic_pera.toString()
    private val dummyTextView = TextView(context)

    @Test
    fun areAnnotationStringValuesValid() {
        val annotatedStringResIdList = getAnnotatedStringsResIdAndAnnotationPairList()
        val contextListForAllLanguages = createContextListForAllLanguages()

        contextListForAllLanguages.forEach { languageUpdatedContext ->
            printCurrentLanguage(languageUpdatedContext)
            annotatedStringResIdList.forEach { (annotatedStringResId, annotationList) ->
                val annotatedString = createAnnotatedString(annotatedStringResId, annotationList)
                printAnnotationDetails(annotatedString)

                try {
                    dummyTextView.setXmlStyledString(annotatedStringResId)
                    println(languageUpdatedContext.getXmlStyledString(annotatedString))
                } catch (exception: Exception) {
                    printBitriseChangeReminder()
                    assert(false)
                }
            }
        }
    }

    private fun getAnnotatedStringsResIdAndAnnotationPairList(): List<Pair<Int, Array<Annotation>>> {
        return R.string::class.java.declaredFields.mapNotNull {
            val resId = context.resources.getIdentifier(it.name, "string", "com.algorand.android")
            if (resId == 0) return@mapNotNull null
            val xmlText = context.getText(resId)
            val spansOfXmlText = (xmlText as? SpannedString)?.getSpans(0, xmlText.length, Annotation::class.java)
            val isAnnotatedString = spansOfXmlText?.isNotEmpty() == true
            if (xmlText is SpannedString && isAnnotatedString) {
                resId to spansOfXmlText!!
            } else {
                null
            }
        }
    }

    private fun createAnnotatedString(stringResId: Int, xmlAnnotations: Array<Annotation>): AnnotatedString {
        val replacementList = mutableListOf<Pair<CharSequence, CharSequence>>()
        val customAnnotationList = mutableListOf<Pair<CharSequence, Any>>()
        xmlAnnotations.forEach {
            when (it.key) {
                "replacement" -> replacementList.add(it.value to replacementRandomString)
                "iconReplacement" -> replacementList.add(it.value to iconReplacementRandomIconId)
                "custom" -> customAnnotationList.add(it.value to foregroundColorSpan)
            }
        }
        return AnnotatedString(stringResId, replacementList, customAnnotationList)
    }

    private fun createContextListForAllLanguages(): List<Context> {
        return supportedLanguages.map {
            val newLocale = Locale(it)

            val currentConfiguration = InstrumentationRegistry.getInstrumentation().context.resources.configuration
            currentConfiguration.setLocale(newLocale)

            context.createConfigurationContext(currentConfiguration)
        }
    }

    private fun printCurrentLanguage(context: Context) {
        printLineDivider()
        println("Current Language: ${context.resources.configuration.locales.toLanguageTags().firstOrNull()}")
        printLineDivider()
    }

    private fun printAnnotationDetails(annotatedString: AnnotatedString) {
        printLineDivider()
        println("Annotation Details")
        annotatedString.replacementList.forEach {
            println("Replacement Key:${it.first}")
            println("Replacement Value:${it.second}")
        }
        annotatedString.customAnnotationList.forEach {
            println("Custom Key:${it.first}")
            println("Custom Value:${it.second}")
        }
        printLineDivider()
    }

    private fun printLineDivider() {
        println("************************************************************************")
    }

    @Suppress("MaxLineLength")
    private fun printBitriseChangeReminder() {
        println("${StringValidationTest::class.java.simpleName} Update bitrise translation after fixing the issue on your local")
    }
}
