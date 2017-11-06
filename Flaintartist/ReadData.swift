//
//  ReadData.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-08.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

func readData(forResource name: String, withExtension ext: String? = nil) -> Data {
    let url = Bundle.main.url(forResource: name, withExtension: ext)!
    var source = try! Data(contentsOf: url)
    var trailingNul: UInt8 = 0
    source.append(&trailingNul, count: 1)
    return source
}
