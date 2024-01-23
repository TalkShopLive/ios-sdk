//
//  Config.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public class ConfigLoader {
    public static func loadConfig() throws -> Config {
//        let fileURL = URL(fileURLWithPath: #file)
//            .deletingLastPathComponent()
//            .appendingPathComponent("env.json")
        
        guard let fileURL = Bundle.module.url(forResource: "env", withExtension: "json") else {
            return Config.init(PUBLISH_KEY: "", SUBSCRIBE_KEY: "", USER_ID: "")
        }
        let data = try Data(contentsOf:fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(Config.self, from: data)
    }
    
    public static func loadAPIConfig() throws -> APIConfig {
        var fileName = ""
        #if DEBUG
            fileName = "StagingConfig"
        #else
            fileName = "ProductionConfig"
        #endif
        guard let fileURL = Bundle.module.url(forResource: fileName, withExtension: "json") else {
            return APIConfig.init(BASE_URL: "")
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(APIConfig.self, from: data)
    }
}

