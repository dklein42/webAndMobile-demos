//
//  SupplementariesViewController.swift
//  CompositionalLayout
//
//  Created by Daniel Klein on 24.05.20.
//  Copyright © 2020 Daniel Klein. All rights reserved.
//

import UIKit

class BadgeView: UICollectionReusableView {
    static let kind = "Badge"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        self.layer.cornerRadius = 9
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HeaderFooterView: UICollectionReusableView {
    static let headerKind = "Header"
    static let footerKind = "Footer"
    
//    var textLabel = UILabel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.addSubview(textLabel)
        
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addConstraints([
//            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//        ])
        
        self.backgroundColor = .lightGray
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SectionDecorationView: UICollectionReusableView {
    static let kind = "Section Decoration"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SupplementariesViewController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(BadgeView.self, forSupplementaryViewOfKind: BadgeView.kind, withReuseIdentifier: BadgeView.kind)
        collectionView.register(HeaderFooterView.self, forSupplementaryViewOfKind: HeaderFooterView.headerKind, withReuseIdentifier: HeaderFooterView.headerKind)
        collectionView.register(HeaderFooterView.self, forSupplementaryViewOfKind: HeaderFooterView.footerKind, withReuseIdentifier: HeaderFooterView.footerKind)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // Badge
        let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: 0.4, y: -0.4))
        let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(16), heightDimension: .absolute(16))
        let badge = NSCollectionLayoutSupplementaryItem(layoutSize: badgeSize, elementKind: BadgeView.kind, containerAnchor: badgeAnchor)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.333))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        // Header/Footer
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(36))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: HeaderFooterView.headerKind, alignment: .top)
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: HeaderFooterView.footerKind, alignment: .bottom)
        
        header.pinToVisibleBounds = true
        footer.pinToVisibleBounds = true
        header.zIndex = 2
        footer.zIndex = 2
        section.boundarySupplementaryItems = [header, footer]
        
        // Section Decoration
        let sectionDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionDecorationView.kind)
        sectionDecoration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        section.decorationItems = [sectionDecoration]
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.boundarySupplementaryItems = [header, footer]
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        layout.register(SectionDecorationView.self, forDecorationViewOfKind: SectionDecorationView.kind)
        
        return layout
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Grid Cell", for: indexPath) as! ListCell
        cell.textLabel.text = String(indexPath.row)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case HeaderFooterView.headerKind:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: HeaderFooterView.headerKind, withReuseIdentifier: HeaderFooterView.headerKind, for: indexPath) as! HeaderFooterView
            //headerView.textLabel.text = "Header"
            headerView.backgroundColor = .green
            return headerView
        case HeaderFooterView.footerKind:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: HeaderFooterView.footerKind, withReuseIdentifier: HeaderFooterView.footerKind, for: indexPath) as! HeaderFooterView
            //footerView.textLabel.text = "Footer"
            footerView.backgroundColor = .red
            return footerView
        case BadgeView.kind:
            return collectionView.dequeueReusableSupplementaryView(ofKind: BadgeView.kind, withReuseIdentifier: BadgeView.kind, for: indexPath)
        default:
            assert(false)
        }
    }
    
    
}
