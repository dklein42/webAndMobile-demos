//
//  ViewController.swift
//  DragAndDropTest
//
//  Created by Daniel Klein on 09.06.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit

class FotoTableViewController: UIViewController, UIDragInteractionDelegate, UIDropInteractionDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
    }

    private func createImageView(image: UIImage, location: CGPoint) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.bounds = CGRect(x: 0, y: 0, width: 200, height: 140)
        imageView.center = location
        imageView.isUserInteractionEnabled = true
        
        let dragInteraction = UIDragInteraction(delegate: self)
        imageView.addInteraction(dragInteraction)
        
        return imageView
    }
    
    // MARK: Drag
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let dragLocation = session.location(in: view)
        let imageView =  self.view.hitTest(dragLocation, with: nil)! as! UIImageView

        let itemProvider = NSItemProvider(object: imageView.image!)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = imageView
        
        return [dragItem]
    }
    
    // MARK: Drop
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let operation: UIDropOperation = (session.localDragSession != nil) ? .move : .copy
        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { images in
            if session.localDragSession != nil {
                let imageView = session.items[0].localObject as! UIImageView
                imageView.center = session.location(in: self.view)
                return
            }
            
            let image = images[0] as! UIImage
            let location = session.location(in: self.view)
            let newImageView = self.createImageView(image: image, location: location)
            self.view.addSubview(newImageView)
        }
    }
}

