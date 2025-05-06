//
//  Show.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

// MARK: - Show Class

// Show class responsible for managing show-related functionality through ShowProvider
public class Show {
    
    // MARK: - Properties
    public static let shared = Show()// Singleton instance for Show class
    private var showInstance = ShowData()
    private var show2Instance = Show2Data()
    private var incrementedView = [String: Bool]()
   
    // MARK: - Initializer
    public init() {
        
    }
    // MARK: - Public Methods
    /// Get the details of the show.
    public func getDetails(
        showKey: String,
        completion: @escaping (Result<ShowData, APIClientError>) -> Void) 
    {
        // Fetch show details using the provider
        ShowProvider().fetchShow(showKey: showKey) { result in
            switch result {
            case .success(let showData):
                // Update the show instance with fetched data
                self.showInstance = showData
                // Set the details and invoke the completion with success.
                completion(.success(showData))
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                Config.shared.isDebugMode() ? print(String(describing: self),"::",error.localizedDescription) : ()
                completion(.failure(error))
            }
        }
    }
    
    public func getDetails2(
        showKey: String,
        completion: @escaping (Result<Show2Data, APIClientError>) -> Void)
    {
        // Fetch show details using the provider
        ShowProvider().fetchShow2(showKey: showKey) { result in
            switch result {
            case .success(let showData):
                // Update the show instance with fetched data
                self.show2Instance = showData
                // Set the details and invoke the completion with success.
                completion(.success(showData))
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                Config.shared.isDebugMode() ? print(String(describing: self),"::",error.localizedDescription) : ()
                completion(.failure(error))
            }
        }
    }
    
    /// Get the status of the show.
    public func getStatus(
        showKey: String,
        completion: @escaping (Result<EventData, APIClientError>) -> Void)
    {
        // Fetch current event status using the provider
        ShowProvider().fetchCurrentEvent(showKey: showKey) { result in
            switch result {
            case .success(let eventInstance):
                let incremented = self.incrementedView[showKey]
                if !(incremented ?? false),
                   let eventId = eventInstance.id,
                    eventInstance.streamInCloud == true,
                    eventInstance.status == "live"
                {
                    ShowProvider().incrementView(eventId: eventId) { status, error in
                        if status {
                            self.incrementedView[showKey] = true
                            Config.shared.isDebugMode() ? print("Incremented View!") : ()
                        } else {
                            Config.shared.isDebugMode() ? print(String(describing: self),"::","Increment View Failed: \(error?.localizedDescription ?? "")") : ()
                        }
                    }
                }
                // Set the details and invoke the completion with success.
                completion(.success(eventInstance))
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                Config.shared.isDebugMode() ? print(String(describing: self),"::",error.localizedDescription) : ()
                completion(.failure(error))
            }
        }
    }
    
    /// Get the products list from show details
    public func getProducts(
        showKey: String,
        preLive: Bool = false,
        completion: @escaping (Result<[ProductData], APIClientError>) -> Void)
    {
        let productIds = (preLive && (self.showInstance.entranceProductsRequired ?? false)) ? self.showInstance.entranceProductsIds : self.showInstance.productsIds
        // Fetch show details using the provider
        if let productIds = productIds, productIds.count > 0 {
            // Fetch products using the ShowProvider
            ShowProvider().fetchProducts(productIds: productIds) { result in
                // Handle the result of fetching products
                switch result {
                case .success(let productData):
                    // If products are fetched successfully, update the show instance with fetched data
                    // Set the details and invoke the completion with success.
                    completion(.success(productData))
                case .failure(let error):
                    // If there is a failure in fetching products, invoke the completion with failure
                    completion(.failure(error))
                }
            }
        } else {
            // If product IDs are not available, invoke the completion with failure indicating product not found
            completion(.failure(APIClientError.PRODUCT_NOT_FOUND))
        }
        
    }

}
