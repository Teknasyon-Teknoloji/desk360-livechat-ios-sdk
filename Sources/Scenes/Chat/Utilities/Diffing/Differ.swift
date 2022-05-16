//
//  Differ.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 31.05.2021.
//

import Foundation

// swiftlint:disable nesting
final class MessagesDiffer {
	static func diff<T: Diffable>(old: [T], new: [T]) -> [Change<T>] {
		let heckel = Heckel<T>()
		dispatchPrecondition(condition: .onQueue(.global(qos: .background)))
		return heckel.diff(old: old, new: new)
	}
	
	static func preprocess<T>(old: [T], new: [T]) -> [Change<T>]? {
		switch (old.isEmpty, new.isEmpty) {
		case (true, true):
			// empty
			return []
		case (true, false):
			// all .insert
			return new.enumerated().map { index, item in
				return .insert(.init(item: item, index: index))
			}
		case (false, true):
			// all .delete
			return old.enumerated().map { index, item in
				return .delete(.init(item: item, index: index))
			}
		default:
			return nil
		}
	}
	
}

private extension MessagesDiffer {
	// Credit to:
	// https://gist.github.com/ndarville/3166060
	class Heckel<T: Diffable> {
		// OC and NC can assume three values: 1, 2, and many.
		enum Counter {
			case zero, one, many
			
			func increment() -> Counter {
				switch self {
				case .zero:
					return .one
				case .one:
					return .many
				case .many:
					return self
				}
			}
		}
		
		// The symbol table stores three entries for each line
		class TableEntry: Equatable {
			// The value entry for each line in table has two counters.
			// They specify the line's number of occurrences in O and N: OC and NC.
			var oldCounter: Counter = .zero
			var newCounter: Counter = .zero
			
			// Aside from the two counters, the line's entry
			// also includes a reference to the line's line number in O: OLNO.
			// OLNO is only interesting, if OC == 1.
			// Alternatively, OLNO would have to assume multiple values or none at all.
			var indexesInOld: [Int] = []
			
			static func == (lhs: TableEntry, rhs: TableEntry) -> Bool {
				return lhs.oldCounter == rhs.oldCounter && lhs.newCounter == rhs.newCounter && lhs.indexesInOld == rhs.indexesInOld
			}
		}
		
		// The arrays OA and NA have one entry for each line in their respective files, O and N.
		// The arrays contain either:
		enum ArrayEntry: Equatable {
			// a pointer to the line's symbol table entry, table[line]
			case tableEntry(TableEntry)
			
			// the line's number in the other file (N for OA, O for NA)
			case indexInOther(Int)
			
			static func == (lhs: ArrayEntry, rhs: ArrayEntry) -> Bool {
				switch (lhs, rhs) {
				case (.tableEntry(let l), .tableEntry(let r)):
					return l == r
				case (.indexInOther(let l), .indexInOther(let r)):
					return l == r
				default:
					return false
				}
			}
		}
		
		func diff(old: [T], new: [T]) -> [Change<T>] {
			// The Symbol Table
			// Each line works as the key in the table look-up, i.e. as table[line].
			var table: [T.DiffId: TableEntry] = [:]
			
			// The arrays OA and NA have one entry for each line in their respective files, O and N
			var oldArray = [ArrayEntry]()
			var newArray = [ArrayEntry]()
			
			perform1stPass(new: new, table: &table, newArray: &newArray)
			perform2ndPass(old: old, table: &table, oldArray: &oldArray)
			perform345Pass(newArray: &newArray, oldArray: &oldArray)
			let changes = perform6thPass(new: new, old: old, newArray: newArray, oldArray: oldArray)
			return changes
		}
		
		private func perform1stPass(
			new: [T],
			table: inout [T.DiffId: TableEntry],
			newArray: inout [ArrayEntry]) {
			
			// 1st pass
			// a. Each line i of file N is read in sequence
			new.forEach { item in
				// b. An entry for each line i is created in the table, if it doesn't already exist
				let entry = table[item.diffId] ?? TableEntry()
				
				// c. NC for the line's table entry is incremented
				entry.newCounter = entry.newCounter.increment()
				
				// d. NA[i] is set to point to the table entry of line i
				newArray.append(.tableEntry(entry))
				
				//
				table[item.diffId] = entry
			}
		}
		
		private func perform2ndPass(
			old: [T],
			table: inout [T.DiffId: TableEntry],
			oldArray: inout [ArrayEntry]
		) {
			
			// 2nd pass
			// Similar to first pass, except it acts on files
			old.enumerated().forEach { tuple in
				// old
				let entry = table[tuple.element.diffId] ?? TableEntry()
				
				// oldCounter
				entry.oldCounter = entry.oldCounter.increment()
				
				// lineNumberInOld which is set to the line's number
				entry.indexesInOld.append(tuple.offset)
				
				// oldArray
				oldArray.append(.tableEntry(entry))
				
				//
				table[tuple.element.diffId] = entry
			}
		}
		
		private func perform345Pass(newArray: inout [ArrayEntry], oldArray: inout [ArrayEntry]) {
			// 3rd pass
			// a. We use Observation 1:
			// If a line occurs only once in each file, then it must be the same line,
			// although it may have been moved.
			// We use this observation to locate unaltered lines that we
			// subsequently exclude from further treatment.
			// b. Using this, we only process the lines where OC == NC == 1
			// c. As the lines between O and N "must be the same line,
			// although it may have been moved", we alter the table pointers
			// in OA and NA to the number of the line in the other file.
			// d. We also locate unique virtual lines
			// immediately before the first and
			// immediately after the last lines of the files ???
			//
			// 4th pass
			// a. We use Observation 2:
			// If a line has been found to be unaltered,
			// and the lines immediately adjacent to it in both files are identical,
			// then these lines must be the same line.
			// This information can be used to find blocks of unchanged lines.
			// b. Using this, we process each entry in ascending order.
			// c. If
			// NA[i] points to OA[j], and
			// NA[i+1] and OA[j+1] contain identical table entry pointers
			// then
			// OA[j+1] is set to line i+1, and
			// NA[i+1] is set to line j+1
			//
			// 5th pass
			// Similar to fourth pass, except:
			// It processes each entry in descending order
			// It uses j-1 and i-1 instead of j+1 and i+1
			newArray.enumerated().forEach { (indexOfNew, item) in
				switch item {
				case .tableEntry(let entry):
					guard !entry.indexesInOld.isEmpty else {
						return
					}
					let indexOfOld = entry.indexesInOld.removeFirst()
					let isObservation1 = entry.newCounter == .one && entry.oldCounter == .one
					let isObservation2 = entry.newCounter != .zero && entry.oldCounter != .zero && newArray[indexOfNew] == oldArray[indexOfOld]
					guard isObservation1 || isObservation2 else {
						return
					}
					newArray[indexOfNew] = .indexInOther(indexOfOld)
					oldArray[indexOfOld] = .indexInOther(indexOfNew)
				case .indexInOther:
					break
				}
			}
		}
		
		private func perform6thPass(
			new: [T],
			old: [T],
			newArray: [ArrayEntry],
			oldArray: [ArrayEntry]) -> [Change<T>] {
			
			// 6th pass
			// At this point following our five passes,
			// we have the necessary information contained in NA to tell the differences between O and N.
			// This pass uses NA and OA to tell when a line has changed between O and N,
			// and how far the change extends.
			var changes = [Change<T>]()
			var deleteOffsets = Array(repeating: 0, count: old.count)
			
			// deletions
			do {
				var runningOffset = 0
				
				oldArray.enumerated().forEach { oldTuple in
					deleteOffsets[oldTuple.offset] = runningOffset
					
					guard case .tableEntry = oldTuple.element else {
						return
					}
					
					changes.append(.delete(.init(
						item: old[oldTuple.offset],
						index: oldTuple.offset
					)))
					
					runningOffset += 1
				}
			}
			
			// insertions, replaces, moves
			do {
				var runningOffset = 0
				
				newArray.enumerated().forEach { newTuple in
					switch newTuple.element {
					case .tableEntry:
						runningOffset += 1
						changes.append(.insert(.init(
							item: new[newTuple.offset],
							index: newTuple.offset
						)))
					case .indexInOther(let oldIndex):
						if !isEqual(oldItem: old[oldIndex], newItem: new[newTuple.offset]) {
							changes.append(.replace(.init(
								oldItem: old[oldIndex],
								newItem: new[newTuple.offset],
								index: newTuple.offset
							)))
						}
						
						let deleteOffset = deleteOffsets[oldIndex]
						// The object is not at the expected position, so move it.
						if (oldIndex - deleteOffset + runningOffset) != newTuple.offset {
							changes.append(.move(.init(
								item: new[newTuple.offset],
								fromIndex: oldIndex,
								toIndex: newTuple.offset
							)))
						}
					}
				}
			}
			
			return changes
		}
		
		func isEqual(oldItem: T, newItem: T) -> Bool {
			return T.compareContent(oldItem, newItem)
		}
	}
}

extension Array {
	func executeIfPresent(_ closure: ([Element]) -> Void) {
		if !isEmpty {
			closure(self)
		}
	}
}
// swiftlint:enable nesting
