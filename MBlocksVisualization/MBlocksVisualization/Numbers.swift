//
//  Numbers.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 10/13/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / .pi }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
