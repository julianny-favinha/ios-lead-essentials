//
//  FeedLocalizationTests.swift
//  FeediOSTests
//
//  Created by Julianny Favinha Donda on 20/04/22.
//

import Foundation
import XCTest

@testable import FeediOS

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(in: presentationBundle)
        let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)

        localizationBundles.forEach { (bundle, localization) in
            localizedStringKeys.forEach { key in
                let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)

                if localizedString == key {
                    XCTFail("Missing string for \(language)")
                }
            }
        }
    }

    // MARK: - Helpers

    private typealias LocalizedBundle = (bundle: Bundle, localization: String)

    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
        return bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType: "lproj"),
                let localizedBundle = Bundle(path: path)
            else {
                XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                return nil
            }

            return (localizedBundle, localization)
        }
    }

    private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
        return bundles.reduce([]) { (acc, current) in
            guard
                let path = current.bundle.path(forResource: table, ofType: "strings"),
                let strings = NSDictionary(contentsOfFile: path),
                let keys = strings.allKeys as? [String]
            else {
                XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                return acc
            }

            return acc.union(Set(keys))
        }
    }
}
