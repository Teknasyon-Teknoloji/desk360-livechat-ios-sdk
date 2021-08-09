//
//  MultipleItemsCollection.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 29.07.2021.
//

import UIKit

final class MultipleItemsCollection: UIView {
    private let items: [String]
    
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MultipleItemsCollectionCell.self, forCellWithReuseIdentifier: MultipleItemsCollectionCell.reuseIdentifier)
        
        return collectionView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(collectionView)
        collectionView.fillSuperview()
    }
}

// MARK: - Data Source
extension MultipleItemsCollection: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleItemsCollectionCell.reuseIdentifier, for: indexPath) as? MultipleItemsCollectionCell else { fatalError() }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}

// MARK: - Delegate
extension MultipleItemsCollection: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizeForItem(at: indexPath)
    }
}

private extension MultipleItemsCollection {
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let cellSpacing: CGFloat = 4
        let totalWidth = frame.width
        let totalHeight = frame.width
        if items.count == 1 {
            return .init(width: totalWidth, height: frame.height)
        } else if items.count == 2 {
            let twoItemsWidth = (totalWidth - 4 * cellSpacing) / 2
            return .init(width: twoItemsWidth, height: frame.height)
        } else if items.count == 3 {
            let threeItemsHeight = (totalHeight - 4 * cellSpacing) / 3
            if indexPath.section == 0 || indexPath.section == 1 {
                let twoItemsWidth = (totalWidth - 4 * cellSpacing) / 2
                return .init(width: twoItemsWidth, height: threeItemsHeight)
            } else {
                let threeItemsHeight = (totalWidth - 4 * cellSpacing) / 3
                return .init(width: frame.width, height: threeItemsHeight)
            }
        } else {
            let twoItemsWidth = (totalWidth - 4 * cellSpacing) / 2
            let fourItemsHeight = (totalHeight - 4 * cellSpacing) / 4
            return .init(width: twoItemsWidth, height: fourItemsHeight)
        }
    }
}

final class  MultipleItemsCollectionCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var showButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    var itemURL: String = "" {
        didSet {
            imageView.kf.setImage(with: URL(string: itemURL))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(imageView)
        addSubview(showButton)
        imageView.fillSuperview()
        showButton.centerInSuperview(size: .init(width: 32, height: 32))
    }
}
