//
//  pagerVC.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 02/10/23.
//

import UIKit

class pagerVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let persistStorage = UserDefaults.standard

    var pages = [UIViewController]()
    let pageControl = UIPageControl()
    var initialPage = 0
    
    // MARK: - Delegate & DataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex == 0 {
            return nil
        } else {
            return pages[currentIndex - 1]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }

        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1] 
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        
        pageControl.currentPage = currentIndex
        NotificationCenter.default.post(name: .pageDataUpdated, object: currentIndex)
    }
    
    
    
    @objc func handleChangeLayer(_ notification: Notification) {
        if let control = notification.object as? String {
            if control == "next" {
                
                let actualPage = pageControl.currentPage
               
                self.setViewControllers([self.pages[actualPage+1]], direction: .forward, animated: true, completion: {_ in
                    self.pageControl.currentPage += 1
                    NotificationCenter.default.post(name: .pageDataUpdated, object: self.pageControl.currentPage)
                    
                })
            } else {
                let actualPage = pageControl.currentPage
               
                self.setViewControllers([self.pages[actualPage-1]], direction: .reverse, animated: true, completion: {_ in
                    self.pageControl.currentPage -= 1
                    NotificationCenter.default.post(name: .pageDataUpdated, object: self.pageControl.currentPage)
                    
                })
            }
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeLayer(_:)), name: .changeLayerPage, object: nil)
        setup()
        style()
        layout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .changeLayerPage, object: nil)
    }
}

extension pagerVC {
    
    func setup() {
        dataSource = self
        delegate = self
        
        //self.isPagingEnabled = false
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)

        let page1 = storyboard?.instantiateViewController(withIdentifier: "landVC")
        let page2 = storyboard?.instantiateViewController(withIdentifier: "marineVC")
        let page3 = storyboard?.instantiateViewController(withIdentifier: "atmosphereVC")
       

        pages.append(page1!)
        pages.append(page2!)
        pages.append(page3!)
        
        initialPage = persistStorage.integer(forKey: "context")

        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
    }
    
    func style() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .clear
        pageControl.pageIndicatorTintColor = .clear
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
    }
    
    func layout() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 80),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 1),
        ])
    }
}

// MARK: - Extension

extension pagerVC {

    @objc func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true, completion: nil)
    }
}


