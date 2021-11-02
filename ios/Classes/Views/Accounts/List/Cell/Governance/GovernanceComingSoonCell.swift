// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   GovernanceComingSoonCell.swift

import UIKit

class GovernanceComingSoonCell: BaseCollectionViewCell<GovernanceComingSoonView> {
    
    weak var delegate: GovernanceComingSoonCellDelegate?

    override func setListeners() {
        contextView.delegate = self
    }
}

extension GovernanceComingSoonCell: GovernanceComingSoonViewDelegate {
    func governanceComingSoonViewDidTapCancelButton(_ governanceComingSoonView: GovernanceComingSoonView) {
        delegate?.governanceComingSoonCellDidTapCancelButton(self)
    }

    func governanceComingSoonViewDidTapGetStartedButton(_ governanceComingSoonView: GovernanceComingSoonView) {
        delegate?.governanceComingSoonCellDidTapGetStartedButton(self)
    }
}

protocol GovernanceComingSoonCellDelegate: AnyObject {
    func governanceComingSoonCellDidTapCancelButton(_ governanceComingSoonCell: GovernanceComingSoonCell)
    func governanceComingSoonCellDidTapGetStartedButton(_ governanceComingSoonCell: GovernanceComingSoonCell)
}
