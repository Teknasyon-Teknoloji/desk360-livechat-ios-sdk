//
//  Reusable.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 16.04.2021.
//

import UIKit

protocol Reusable: AnyObject {
  static var reuseIdentifier: String { get }
}

extension Reusable {
  static var reuseIdentifier: String {
	return String(describing: self)
  }
}

extension UITableViewCell: Reusable {}
extension UICollectionViewCell: Reusable {}

 extension UITableView {

	func register<T: UITableViewCell>(cellType: T.Type) {
	  self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
		
	}
	
	func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
		guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
		fatalError(
		  "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
			+ "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
			+ "and that you registered the cell beforehand"
		)
	  }
	  return cell
  }

	func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) where T: Reusable {
	  self.register(headerFooterViewType.self, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
  }

	func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T? where T: Reusable {
	  guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T? else {
		fatalError(
		  "Failed to dequeue a header/footer with identifier \(viewType.reuseIdentifier) "
			+ "matching type \(viewType.self). "
			+ "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
			+ "and that you registered the header/footer beforehand"
		)
	  }
	  return view
  }
}
