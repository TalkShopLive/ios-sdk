//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation

public struct ShowData: Codable {
    public let id: Int?
    public let productKey: String?
    public let name: String?
    public let description: String?
    public let slug: String?
    public let brand_name: String?
    // Add other non-optional properties
    // Add other structs for nested data if needed
    
    // Custom initializer with default values
       public init(id: Int? = nil, productKey: String? = nil, name: String? = nil, description: String? = nil, slug: String? = nil, brandName: String? = nil) {
           self.id = id
           self.productKey = productKey
           self.name = name
           self.description = description
           self.slug = slug
           self.brand_name = brandName
           // Initialize other optional properties with default values here
       }
}


