//
//  GridCollectionViewController.swift
//  CompositionalLayout
//
//  Created by Daniel Klein on 24.05.20.
//  Copyright © 2020 Daniel Klein. All rights reserved.
//

import UIKit

class GridViewController: UICollectionViewController {
    let data = (1...100).map { String($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"
        
        //collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "List Cell", for: indexPath) as! ListCell
        cell.textLabel.text = data[indexPath.row]
        return cell
    }
}
