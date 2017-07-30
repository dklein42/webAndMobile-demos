//
//  AnimatedDemoViewController.swift
//  DragAndDropTest
//
//  Created by Daniel Klein on 25.07.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit

class AnimatedDemoViewController: UIViewController, UIDragInteractionDelegate, UIDropInteractionDelegate {
    var imageViews = [UIImageView]()
    var lastPosition: CGPoint = CGPoint()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
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
        lastPosition = session.location(in: self.view)
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
            
            let newImageView = UIImageView(image: (images[0] as! UIImage))
            newImageView.bounds = CGRect(x: 0, y: 0, width: 200, height: 140)
            newImageView.center = session.location(in: self.view)
            newImageView.isUserInteractionEnabled = true
            
            let dragInteraction = UIDragInteraction(delegate: self)
            newImageView.addInteraction(dragInteraction)
            
            self.view.addSubview(newImageView)
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, previewForDropping item: UIDragItem, withDefault defaultPreview: UITargetedDragPreview) -> UITargetedDragPreview? {
        let target = UIDragPreviewTarget(container: self.view, center: lastPosition, transform: CGAffineTransform(scaleX: 1.5, y: 1.5))
        defaultPreview.view.alpha = 0
        return defaultPreview.retargetedPreview(with: target)
    }
}
