//
//  jsonHelper.swift
//  glassHouses
//
//  Created by Jonathon Day on 3/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import Crashlytics

//TODO: replace with modified third party library

extension Dictionary {
    func getDoubleForKey(_ key: String) -> Double? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let double = self[aKey] as? Double else {
            reportFailure(key: key, type: "Double", raw: self[aKey])
            return nil
        }
        return double
    }
    
    func getStringForKey(_ key: String) -> String? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let String = self[aKey] as? String else {
            reportFailure(key: key, type: "String", raw: self[aKey])
            return nil
        }
        return String
    }
    
    func getArrayOfDictForKey(_ key: String) -> [[String: Any]]? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let array = self[aKey] as? Array<Dictionary<String, Any>> else {
            reportFailure(key: key, type: "ArrayOfDict", raw: self[aKey])
            return nil
        }
        return array
    }
    
    func getDictForKey(_ key: String) -> [String: Any]? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let dict = self[aKey] as? Dictionary<String, Any> else {
            reportFailure(key: key, type: "Dictionary", raw: self[aKey])
            return nil
        }
        return dict
    }
    
    func getBoolForKey(_ key: String) -> Bool? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let Bool = self[aKey] as? Bool else {
            reportFailure(key: key, type: "Bool", raw: self[aKey])
            return nil
        }
        return Bool
    }
    
    
    func reportFailure(key: String, type: String, raw: Any?) {
        Crashlytics.sharedInstance().recordCustomExceptionName("JSON Mapping Failure", reason: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse in leo lectus. Etiam sollicitudin porta odio, eget tristique orci iaculis nec. Nulla sed aliquam ligula. Sed quis rutrum est, egestas fermentum ante. Sed sed leo vel eros consectetur maximus. Quisque vitae dolor pulvinar, rhoncus risus vitae, semper lacus. Nam facilisis eros nec leo dictum, ut bibendum ante auctor. Vestibulum quis elementum quam, et dictum Praesent quis mattis nulla. Cras pretium mi ac nibh dapibus, eget ornare purus volutpat. Cras efficitur, diam sit amet pharetra consequat, diam nibh mattis lectus, a cursus nisl urna a ex. Sed elit metus, eleifend ultricies sem id, facilisis luctus tortor. Pellentesque nunc augue, rutrum eget mattis in, commodo sed arcu. In finibus diam eget lacus vestibulum viverra. Fusce euismod est sollicitudin ex dignissim pretium. Proin non luctus diam. Proin est mauris, commodo non interdum egestas, blandit bibendum nisl. Fusce semper tempus felis, vitae convallis ligula maximus eu. Nullam iaculis porta Mauris a vulputate augue, pellentesque ullamcorper ipsum. Quisque sit amet ultricies tellus, in suscipit libero. Aliquam auctor interdum ex at vehicula. Mauris pulvinar tristique ipsum ut hendrerit. Curabitur maximus augue neque, eget ultrices ligula mollis quis. Ut aliquet urna a nisl dictum, ut mollis sem imperdiet. Sed luctus congue risus a volutpat. Sed consequat dui vel dignissim fringilla. Mauris eros odio, consequat eget aliquam facilisis, cursus ultrices purus. Phasellus sit amet sagittis tellus. Praesent eget lobortis nulla. Quisque ac turpis a ligula sodales scelerisque. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus Aliquam rutrum rhoncus nisl, at vestibulum lacus finibus id. Praesent quis gravida diam. Nam placerat faucibus aliquam. Fusce sed efficitur dolor. Maecenas semper in elit nec sodales. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Ut aliquet tincidunt mauris ut fermentum. Nam porta rutrum sem, vitae iaculis velit ornare quis. Proin nunc odio, luctus eget metus quis, aliquam molestie mauris. Interdum et malesuada fames ac ante ipsum primis in faucibus. Mauris id tellus eget purus ultrices mollis. Proin eget vehicula ipsum. Etiam mauris augue, imperdiet eget posuere et, consequat eget magna. Praesent tincidunt consequat lectus, eget venenatis metus. Quisque placerat quam nibh, id facilisis nibh rutrum ut. Nunc vehicula finibus Sed lorem turpis, malesuada ac fringilla at, scelerisque in justo. Aenean vel erat in libero condimentum luctus. Nunc nec rhoncus odio. Suspendisse ut tempus urna. Etiam finibus blandit sapien, vitae dignissim purus rhoncus sit amet. Donec faucibus fermentum massa, ac venenatis ipsum cursus nec. Suspendisse accumsan vel nisi at volutpat. Quisque posuere non justo at condimentum. Sed faucibus ligula non pharetra blandit. Aenean at ex massa. Aliquam metus eros, consequat vel imperdiet nec, iaculis ac orci. Etiam a odio magna. Nullam id accumsan ex. Sed venenatis tellus sem, eget tempor lectus fermentum quis. Curabitur fringilla mattis vulputate.", frameArray: [CLSStackFrame.init(symbol: "something")])
    }
    
}
