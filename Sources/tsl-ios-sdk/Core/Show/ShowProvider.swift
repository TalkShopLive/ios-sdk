//
//  File.swift
//  
//
//  Created by Mayuri on 2024-01-24.
//

import Foundation

public protocol ShowProvider {
    func getShows(completion: @escaping (Result<TSLShow, Error>) -> Void)
    // Add other functions as needed
}
