package com.algorand.android.modules.accountdetail.requiredminimumbalance

import android.widget.TextView
import com.algorand.android.R
import com.algorand.android.modules.informationbottomsheet.ui.BaseInformationBottomSheet
import com.google.android.material.button.MaterialButton

class RequiredMinimumBalanceInformationBottomSheet : BaseInformationBottomSheet() {

    override fun initTitleTextView(titleTextView: TextView) {
        titleTextView.setText(R.string.minimum_balance)
    }

    override fun initDescriptionTextView(descriptionTextView: TextView) {
        descriptionTextView.setText(R.string.minimum_balance_is_the_minimum)
    }

    override fun initNeutralButton(neutralButton: MaterialButton) {
        neutralButton.apply {
            setText(R.string.close)
            setOnClickListener { navBack() }
        }
    }
}
