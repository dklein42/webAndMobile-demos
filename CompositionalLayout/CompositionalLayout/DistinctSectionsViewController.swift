//
//  DistinctSectionsViewController.swift
//  CompositionalLayout
//
//  Created by Daniel Klein on 24.05.20.
//  Copyright © 2020 Daniel Klein. All rights reserved.
//

import UIKit

enum SizeSections: Int, CaseIterable {
    case small
    case middle
    case large
}

class DistinctSectionsViewController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            print("Configuring section \(sectionIndex)")
            print("Content size: \(layoutEnvironment.container.contentSize)")
            print("Trait collection: \(layoutEnvironment.traitCollection)")
            
            guard let sectionKind = SizeSections(rawValue: sectionIndex) else { return nil }
            
            let width: CGFloat
            
            switch sectionKind {
            case .small:
                width = 0.1666
            case .middle:
                width = 0.333
            case .large:
                width = 0.5
            }

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(width), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(width))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        
        return layout
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SizeSections.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Grid Cell", for: indexPath) as! ListCell
        cell.textLabel.text = "\(indexPath.section).\(indexPath.row)"
        return cell
    }
}
