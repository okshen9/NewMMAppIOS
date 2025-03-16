//
//  CreateSubTargetBodyModel.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//
import Foundation

struct CreateSubTargetBodyModel: JSONRepresentable {
    let title: String?
    let description: String?
    let subTargetPercentage: Double?
    let deadLineDateTime: String?
    let targetSubStatus: TargetSubStatus?
}
