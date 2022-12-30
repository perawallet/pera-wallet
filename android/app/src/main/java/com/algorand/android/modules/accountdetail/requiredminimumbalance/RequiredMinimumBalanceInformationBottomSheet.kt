package com.algorand.android.modules.accountdetail.requiredminimumbalance

import com.algorand.android.R
import com.algorand.android.modules.informationbottomsheet.ui.BaseInformationBottomSheet

class RequiredMinimumBalanceInformationBottomSheet : BaseInformationBottomSheet() {

    override val titleTextResId: Int
        get() = R.string.minimum_balance

    override val descriptionTextResId: Int
        get() = R.string.minimum_balance_is_the_minimum

    override val neutralButtonTextResId: Int
        get() = R.string.close

    override fun onNeutralButtonClick() {
        navBack()
    }
}
