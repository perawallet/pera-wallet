package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import androidx.core.view.updateLayoutParams
import androidx.core.view.updateMargins
import com.algorand.android.R
import kotlin.random.Random
import kotlin.random.nextInt

class PassphraseValidationGroupView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val passphraseValidationViews = mutableListOf<PassphraseValidatorView>()

    private val passphraseValidatorViewListener = PassphraseValidatorView.Listener {
        listener?.onInputUpdate(passphraseValidationViews.all { it.isWordSelected() })
    }

    init {
        orientation = VERTICAL
    }

    private var listener: Listener? = null

    fun setupUI(words: List<String>, listener: Listener?) {
        this.listener = listener
        recreateUI(words, isFirstSetup = true)
    }

    fun recreateUI(words: List<String>, isFirstSetup: Boolean = false) {
        if (passphraseValidationViews.isNotEmpty()) {
            passphraseValidationViews.clear()
            removeAllViews()
        }

        words.withIndex()
            .shuffled()
            .windowed(PER_ITEM_COUNT, PER_ITEM_COUNT, partialWindows = false)
            .take(SIZE)
            .forEachIndexed { index, wordsWithIndexedValue ->
                addPassphraseValidationView(
                    passphraseValidatorView = createPassphraseValidatorView(wordsWithIndexedValue),
                    addMarginToBottom = index + 1 != SIZE
                )
            }

        if (isFirstSetup.not()) {
            listener?.onInputUpdate(allWordsSelected = false)
        }
    }

    private fun addPassphraseValidationView(
        passphraseValidatorView: PassphraseValidatorView,
        addMarginToBottom: Boolean
    ) {
        addView(passphraseValidatorView)
        passphraseValidationViews.add(passphraseValidatorView)
        if (addMarginToBottom) {
            passphraseValidatorView.updateLayoutParams<LayoutParams> {
                updateMargins(bottom = resources.getDimensionPixelOffset(R.dimen.passphrase_validation_bottom_margin))
            }
        }
    }

    private fun createPassphraseValidatorView(
        wordsWithIndexedValue: List<IndexedValue<String>>
    ): PassphraseValidatorView {
        return PassphraseValidatorView(context).apply {
            val correctWordPositionInList = Random.nextInt(0 until PER_ITEM_COUNT)
            val (correctWordPosition, correctWord) = wordsWithIndexedValue[correctWordPositionInList]
            setup(
                words = wordsWithIndexedValue.map { it.value },
                correctWord = correctWord,
                correctWordPosition = correctWordPosition,
                passphraseValidatorViewListener
            )
        }
    }

    fun isValidated(): Boolean {
        return passphraseValidationViews.isNotEmpty() && passphraseValidationViews.all { it.isValidated() }
    }

    interface Listener {
        fun onInputUpdate(allWordsSelected: Boolean)
    }

    companion object {
        private const val SIZE = 4
        private const val PER_ITEM_COUNT = 3
    }
}
