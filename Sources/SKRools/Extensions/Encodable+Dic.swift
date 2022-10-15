//
//  File.swift
//  
//
//  Created by Oscar Cardona on 17/4/22.
//

import Foundation

extension Encodable {
    public var dictionaryRepresentation: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        if var json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap({ $0 as? [String: Any] }) {
            json.keys.forEach { key in
                if let nsNumberValue = (json[key] as? NSNumber), nsNumberValue.isBool() {
                    json[key] = Bool(truncating: nsNumberValue)
                }
            }
            return json
        }
        else {
            return nil
        }
    }
}
