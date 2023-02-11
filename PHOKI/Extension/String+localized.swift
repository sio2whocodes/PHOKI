//
//  String+localized.swift
//  PHOKI
//
//  Created by sujeong on 2022/11/18.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
