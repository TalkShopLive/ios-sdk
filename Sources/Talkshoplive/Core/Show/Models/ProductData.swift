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
    public var productKey: String?
    public var name: String?
    public var sku: String?
    public var description: String?
    public var image: String?
    public var affiliateLink: String?
    public var variants: [VariantsData]?
    public var minimumPrice: String?
    public var originalPrice: String?
    public var source: String?
    private let master: ProductMaster?
    
    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sku
        case description
        case image
        case affiliateLink
        case variants
        case minimumPrice = "minimum_price"
        case productKey = "product_key"
        case originalPrice = "original_price"
        case source
        case master
    }
    
    // MARK: Initializer
    public init() {
        id = nil
        productKey = nil
        name = nil
        sku = nil
        description = nil
        image = nil
        affiliateLink = nil
        minimumPrice = nil
        originalPrice = nil
        source = nil
        variants = nil
        master = nil
    }
    
    // MARK: Decodable Initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        productKey = try? container.decodeIfPresent(String.self, forKey: .productKey)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        minimumPrice = try? container.decodeIfPresent(String.self, forKey: .minimumPrice)
        originalPrice = try? container.decodeIfPresent(String.self, forKey: .originalPrice)
        source = try? container.decodeIfPresent(String.self, forKey: .source)
        variants = try? container.decodeIfPresent([VariantsData].self, forKey: .variants)

        master = try? container.decodeIfPresent(ProductMaster.self, forKey: .master)
        
        if let master = master,
           let firstImage = master.images?.first,
           let attachment = firstImage.attachment {
            image = attachment.original
        } else {
            image = nil
        }
        
        sku = master?.sku
        affiliateLink = master?.affiliateLink
        originalPrice = master?.originalPrice
    }
}

// MARK: - VariantsData
public struct VariantsData: Codable {
    public var id: Int?
    public var displayPrice: String?
    public var costCurrency: String?
    public var exchangeName: String?
    public var buyerPrice: String?
    public var isDefault: Bool?
    public var sku: String?
    public var position: Int?

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case displayPrice = "display_price"
        case costCurrency = "cost_currency"
        case exchangeName = "exchange_name"
        case buyerPrice = "buyer_price"
        case isDefault = "is_default"
        case sku
        case position
    }
    
    // MARK: Initializers
    public init() {
        id = nil
        displayPrice = nil
        costCurrency = nil
        exchangeName = nil
        buyerPrice = nil
        isDefault = nil
        sku = nil
        position = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        displayPrice = try? container.decodeIfPresent(String.self, forKey: .displayPrice)
        costCurrency = try? container.decodeIfPresent(String.self, forKey: .costCurrency)
        exchangeName = try? container.decodeIfPresent(String.self, forKey: .exchangeName)
        buyerPrice = try? container.decodeIfPresent(String.self, forKey: .buyerPrice)
        isDefault = try? container.decodeIfPresent(Bool.self, forKey: .isDefault)
        sku = try? container.decodeIfPresent(String.self, forKey: .sku)
        position = try? container.decodeIfPresent(Int.self, forKey: .position)
    }
}

// MARK: - ProductMaster
public struct ProductMaster: Codable {
    public var id: Int?
    public var sku: String?
    public var images: [ImageAttachment]?
    public var affiliateLink: String?
    public var externalOfferId: String?
    public var originalPrice: String?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case images
        case sku
        case affiliateLink = "affiliate_link"
        case externalOfferId = "external_offer_id"
        case originalPrice = "original_price"
    }
    
    // MARK: Initializers
    public init() {
        id = nil
        sku = nil
        images = nil
        affiliateLink = nil
        externalOfferId = nil
        originalPrice = nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        images = try? container.decodeIfPresent([ImageAttachment].self, forKey: .images)
        sku = try? container.decodeIfPresent(String.self, forKey: .sku)
        affiliateLink = try? container.decodeIfPresent(String.self, forKey: .affiliateLink)
        externalOfferId = try? container.decodeIfPresent(String.self, forKey: .externalOfferId)
        originalPrice = try? container.decodeIfPresent(String.self, forKey: .originalPrice)
    }
}
