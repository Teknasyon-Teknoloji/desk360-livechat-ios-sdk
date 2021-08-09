//
//  Validator.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 15.06.2021.
//

import UIKit

struct Validator<Input, Output> {
	
	private var fields: [InputFiled] = []
	
	func validate(_ condition: @autoclosure() -> Bool, errorMessage expression: @autoclosure() -> String) { }
	
	func validate(_ input: Input, using rules: [Rule<Input, Output>]) -> Output? {
		return rules.compactMap({ $0.check(input) }).first
	}
	
	struct Rule<Input, Output> {
		let check: (Input) -> Output?
	}
}

extension Validator {
	struct InputFiled {
		let input: Input
		let rulues: [Rule<Input, Output>]
		let output: (Output) -> Void
	}
	
	mutating func add(field: InputFiled) {
		fields.append(field)
	}
	
	mutating func add(fields: [InputFiled]) {
		self.fields.append(contentsOf: fields)
	}
	
	func batchValidation() -> Bool {
		var isValid = true
		fields.forEach { field in
			if let error = validate(field.input, using: field.rulues) {
				field.output(error)
				isValid = false
			}
		}
		return isValid
	}
}

protocol Validationable {
	var value: String { get }
}

extension UITextField: Validationable {
	var value: String {
		text ?? ""
	}
}

extension UITextView: Validationable {
	var value: String {
		text
	}
}

extension Validator.Rule where Input == String, Output == String {
	static var notEmpty: Validator.Rule<Input, Output> {
		return Validator.Rule {
			return $0.isEmpty ? Strings.required_message : nil
		}
	}
	
	static var email: Validator.Rule<Input, Output> {
		return Validator.Rule {
			return $0.isValid(regex: .email) ? nil : Strings.required_message
		}
	}
	
	static var password: Validator.Rule<Input, Output> {
		return Validator.Rule {
			return $0.count < 6 ? "Strings.passwodError" : nil
		}
	}
}

fileprivate extension String {
	enum RegularExpressions: String {
		  case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
		  case email = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
	  }

	func isValid(regex: RegularExpressions) -> Bool { return range(of: regex.rawValue, options: .regularExpression) != nil }
}
