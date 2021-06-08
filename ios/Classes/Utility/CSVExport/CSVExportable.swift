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
//  CSVExportable.swift

import Foundation

protocol CSVExportable {
    func exportCSV(from data: [[String: Any]], with config: CSVConfig) -> URL?
}

extension CSVExportable {
    func exportCSV(from data: [[String: Any]], with config: CSVConfig) -> URL? {
        if let csvString = combineCSVString(from: data, with: config),
            let fileURL = createFileURL(from: config) {
            return createFile(from: csvString, to: fileURL)
        }
        return nil
    }
    
    private func combineCSVString(from data: [[String: Any]], with config: CSVConfig) -> String? {
        guard let keyValues = config.keys.array as? [String] else {
            return nil
        }
        
        var csvString = ""
        csvString += keyValues.joined(separator: ",")
        csvString += "\n"
        
        csvString += data.reduce(into: "") { result, dictionary in
            for key in keyValues {
                if let values = dictionary[key].map({ value -> String in
                    "\"\(value)\","
                }) {
                    result += values
                }
            }
            result.removeLast()
            result.append("\n")
        }
        return csvString
    }
    
    private func createFileURL(from config: CSVConfig) -> URL? {
        guard let initialPath = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else {
            return nil
        }
        
        var fileName = config.fileName
        if !fileName.hasSuffix(".csv") {
            fileName.append(".csv")
        }
        
        return initialPath.appendingPathComponent(fileName)
    }
    
    private func createFile(from string: String, to url: URL) -> URL? {
        try? string.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
