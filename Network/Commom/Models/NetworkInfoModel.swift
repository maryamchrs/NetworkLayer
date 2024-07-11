//
//  NetworkInfoModel.swift
//  NetworkLayer
//
//  Created by Maryam Chrs on 11/07/2024.
//

import Foundation

/// Using NetworkInfoModel, you can access critical connectivity data whenever necessary.
public struct NetworkInfoModel {
    var isActive: Bool = false
    var isExpensive: Bool = false
    var isConstrained: Bool = false
    var connectionType = NetworkInterfaceType.other
}
