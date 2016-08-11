//
//  HomeScreen.swift
//  Geo Dash
//
//  Created by Dongyu Zhai on 11/8/16.
//  Copyright © 2016 Dongyu Zhai. All rights reserved.
//

import Foundation
import UIKit

class HomeScreen : UICollectionViewController {
    
    var arrayOfOptions = [Int]()
    var arrayOfTitles = [String]()
    
    override func viewDidLoad() {
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        arrayOfOptions = [1, 2, 3]
        arrayOfTitles = ["Green", "Blue", "Black"]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayOfTitles.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        gameOption = arrayOfOptions[indexPath.row]
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Game")
        
        self.presentViewController(viewController!, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        let label = cell.viewWithTag(1) as! UILabel
        label.text = arrayOfTitles[indexPath.row]
        
        return cell
    }
}