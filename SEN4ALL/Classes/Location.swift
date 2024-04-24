//
//  Location.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 04/10/23.
//

import Foundation

struct LocationData: Codable {
    let place_id: Int
    let licence: String
    let osm_type: String
    let osm_id: Int
    let lat: String
    let lon: String
    
    let type: String
    let place_rank: Int
    let importance: Double
    let addresstype: String
    let name: String
    let display_name: String
    //let address: Address
    let boundingbox: [String]

    struct Address: Codable {
        let municipality: String
        let county: String
        let iso3166_2_lvl4: String
        let country: String
        let country_code: String

        
    }
}
