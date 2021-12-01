//
//  Dictionary+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation

extension Dictionary where Key == String {
	typealias JSONDictionary = [String: Any]
	
	func resolve<T>( keyPath: String) -> T? {
		var current: Any? = self

		keyPath.split(separator: ".").forEach { component in
			if let maybeInt = Int(component), let array = current as? [Any] {
				current = array[maybeInt]
			} else if let dictionary = current as? JSONDictionary {
				current = dictionary[String(component)]
			}
		}
		
		return current as? T
	}
	
	func resolve<T>(
		keyPath: String,
		orDefault value: @autoclosure () -> T
	) -> T {
		var current: Any? = self

		keyPath.split(separator: ".").forEach { component in
			if let maybeInt = Int(component), let array = current as? [Any] {
				current = array[maybeInt]
			} else if let dictionary = current as? JSONDictionary {
				current = dictionary[String(component)]
			}
		}
		
		guard let aValue  = current as? T else { return value() }
		return aValue
	}
    
    mutating func combine(with anotherDic: [Key: Value]){
        for (k, v) in anotherDic {
            updateValue(v, forKey: k)
        }
    }
}
