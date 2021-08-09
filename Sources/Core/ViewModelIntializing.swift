//
//  ViewModelIntializing.swift
//  Example
//
//  Created by Ali Ammar Hilal on 12.04.2021.
//

import Foundation

/// Conform to `ViewModelIntializing` in `UIViewController` to init it with
/// a view model.
protocol ViewModelIntializing {
	
	/// ViewModel type
	associatedtype ViewModel
	
	/// The view model instance.
	var viewModel: ViewModel { get }
	
	/// Creates a view controller with a view model
	/// - Parameter viewModel: Current view controller view model.
	init(viewModel: ViewModel)
}
