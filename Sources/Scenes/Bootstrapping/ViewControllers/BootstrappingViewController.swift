//
//  BootstrappingViewController.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import UIKit

class BootstrappingViewController: BaseViewController, Layouting, ViewModelIntializing {
    
    typealias ViewType = BootstrappingView
    typealias ViewModel = BootstrappingViewModel
    
    let viewModel: BootstrappingViewModel
    
    required init(viewModel: BootstrappingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        view = ViewType.create()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutableView.setLoading(true)
        UIApplication.shared.statusBarUIView?.backgroundColor = .white
    }
    
    override func bindUIControls() {
        super.bindUIControls()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        viewModel
            .bootstrap()
            .on(success: {
                 self.layoutableView.setLoading(false)
                //	self.viewModel.trigger()
            }) { _error in
                self.showAlert(type: .error, title: Strings.sdk_error, message: _error.localizedDescription, actionTitle: Strings.sdk_ok) {
                    self.viewModel.router?.trigger(.close)
                    Logger.logError(_error)
                }
            }
    }
}
