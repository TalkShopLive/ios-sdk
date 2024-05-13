//
//  ProductData.swift
//  
//
//  Created by TalkShopLive on 2024-05-10.
//

import Foundation

//MARK: - ProductData

public struct GetProductsResponse: Codable {
    let products : [ProductData]
}


// Define the main struct representing the top-level data
public struct ProductData: Codable {
    public var id: Int?
    public var sku: String?
    public var description: String?
    public var image: String?
    public var productSource: String?
    public var affiliateLink: String?
    public var variants: [VariantsData]?
    private let master: Master?
    
    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case sku
        case description
        case image
        case productSource
        case affiliateLink
        case variants
        case master
    }
    
    // MARK: Initializers
    public init() {
        id = nil
        sku = nil
        description = nil
        image = nil
        productSource = nil
        affiliateLink = nil
        variants = nil
        master = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        productSource = try? container.decodeIfPresent(String.self, forKey: .productSource)
        affiliateLink = try? container.decodeIfPresent(String.self, forKey: .affiliateLink)
        variants = try? container.decodeIfPresent([VariantsData].self, forKey: .variants)

        master = try? container.decodeIfPresent(Master.self, forKey: .master)
        image = master?.images?.first?.attachment?.original
        sku = master?.sku
    }

}

public struct VariantsData: Codable {
    public let id: Int?
    public let displayPrice: String?
    public let costCurrency: String?
    public let exchangeName: String?
    public let buyerPrice: String?
    public let isDefault: Bool?
    
    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case displayPrice = "display_price"
        case costCurrency = "cost_currency"
        case exchangeName
        case buyerPrice
        case isDefault
    }
    
    // MARK: Initializers
    public init() {
        id = nil
        displayPrice = nil
        costCurrency = nil
        exchangeName = nil
        buyerPrice = nil
        isDefault = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        displayPrice = try? container.decodeIfPresent(String.self, forKey: .displayPrice)
        costCurrency = try? container.decodeIfPresent(String.self, forKey: .costCurrency)
        exchangeName = try? container.decodeIfPresent(String.self, forKey: .exchangeName)
        buyerPrice = try? container.decodeIfPresent(String.self, forKey: .buyerPrice)
        isDefault = try? container.decodeIfPresent(Bool.self, forKey: .isDefault)
    }

}
