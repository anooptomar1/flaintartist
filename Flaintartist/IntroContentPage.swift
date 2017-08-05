//
//  IntroContentPage.swift
//  Flaintartist
//
//  Created by Kerby Jean on 6/13/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class IntroContentPage: UIPageViewController, UIPageViewControllerDelegate {
    
    var viewControllerIndex: Int?

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
         let firstViewController = orderedViewControllers[0]
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        viewControllerIndex = 1
        
    }

    
    // MARK:- Finish passin

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.newColoredViewController(id: "ViewOne")
            ,self.newColoredViewController(id: "ViewTwo")
            , self.newColoredViewController(id: "ViewThree")]
    }()
    
    private func newColoredViewController(id: String) -> UIViewController {
        
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: id)
    }
    
}



// MARK: UIPageViewControllerDataSource

extension IntroContentPage: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,  viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed){
            return
        }
        let index = pageViewController.viewControllers!.first!.view.tag
        self.viewControllerIndex = index
    }
}
