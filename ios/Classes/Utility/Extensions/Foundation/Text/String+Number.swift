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
//  String+Number.swift

import Foundation

extension String {
    var digits: String { return filter(("0"..."9").contains) }
    var decimal: Decimal { return Decimal(string: digits) ?? 0 }
    
    func doubleForSendSeparator(with fraction: Int) -> Double? {
        return Formatter.separatorWith(fraction: fraction).number(from: self)?.doubleValue
    }
    
    func currencyInputFormatting(with fraction: Int) -> String? {
        let decimal = self.decimal / pow(10, fraction)
        return Formatter.separatorForInputWith(fraction: fraction).string(for: decimal)
    }
}
