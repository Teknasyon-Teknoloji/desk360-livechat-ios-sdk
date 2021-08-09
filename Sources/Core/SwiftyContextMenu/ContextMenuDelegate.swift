//
//  ContextMenuDelegate.swift
//  ContextMenu
//
//  Created by Mario Iannotta on 09/07/2020.
//

import UIKit

protocol ContextMenuDelegate: AnyObject {

    func contextMenuWillAppear(_ contextMenu: ContextMenu)
    func contextMenuDidAppear(_ contextMenu: ContextMenu)
}

extension ContextMenuDelegate {

    func contextMenuWillAppear(_ contextMenu: ContextMenu) { }
    func contextMenuDidAppear(_ contextMenu: ContextMenu) { }
}
