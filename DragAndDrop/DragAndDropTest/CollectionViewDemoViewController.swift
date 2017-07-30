//
//  DragDropTestCollectionViewController.swift
//  DragAndDropTest
//
//  Created by Daniel Klein on 16.07.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit

class CollectionViewDemoViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        
        images.append(UIImage(named: "Test 1")!)
        images.append(UIImage(named: "Test 2")!)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.imageView.image = images[indexPath.row]
        
        return cell
    }

    //  MARK: Drag Support
    private func dragItem(for indexPath: IndexPath) -> UIDragItem {
        let image = images[indexPath.row]
        let itemProvider = NSItemProvider(object: image)
        return UIDragItem(itemProvider: itemProvider)
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [dragItem(for: indexPath)]
    }
    
//    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
//    }
    
    // MARK: Drop Handling
    
//    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
//        print("Can load image: \(session.canLoadObjects(ofClass: UIImage.self))")
//        return session.canLoadObjects(ofClass: UIImage.self)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: collectionView.numberOfItems(inSection: 0), section: 0)
        
        coordinator.session.loadObjects(ofClass: UIImage.self) { items in
            let images = items as! [UIImage]
            self.images.insert(images[0], at: destinationIndexPath.row)
            collectionView.insertItems(at: [destinationIndexPath])
        }
    }

    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
