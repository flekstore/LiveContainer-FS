//
//  FSAppModel.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 30.09.2025.
//

import Foundation



struct FSAppModel: Identifiable, Codable {
    let app_id: Int
    let app_icon: String
    let app_name: String
    let app_version: String
    let app_short_description: String
    let app_isAdult: Int
    let install_url: String
    
    var id: Int { app_id }
}
