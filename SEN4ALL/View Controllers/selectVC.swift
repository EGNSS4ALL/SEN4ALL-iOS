//
//  selectVC.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 02/10/23.
//

import UIKit

protocol selectVCDelegate {
    func applyLayer()
}

class selectVC: UIViewController {
    
    @IBOutlet weak var layerLabel: UILabel!
    @IBOutlet weak var layerIcon: UIImageView!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    let persistStorage = UserDefaults.standard
    var delegate: selectVCDelegate?
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func prevAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: .changeLayerPage, object: "prev")
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: .changeLayerPage, object: "next")
    }
    
    // MARK: - Helpers
    
    func updateUI() {
        
        let context = persistStorage.integer(forKey: "context")
        
        
        selectContext(context: context)
    
    }
    
    func selectContext(context: Int) {
        switch context {
        case 0:
            prevBtn.alpha = 0.3
            prevBtn.isUserInteractionEnabled = false
            nextBtn.alpha = 1
            nextBtn.isUserInteractionEnabled = true
            layerIcon.image = UIImage(named: "context_land")
            layerLabel.text = "Land"
        case 1:
            prevBtn.alpha = 1
            prevBtn.isUserInteractionEnabled = true
            nextBtn.alpha = 1
            nextBtn.isUserInteractionEnabled = true
            layerIcon.image = UIImage(named: "context_marine")
            layerLabel.text = "Marine"
        case 2:
            prevBtn.alpha = 1
            prevBtn.isUserInteractionEnabled = true
            nextBtn.alpha = 0.3
            nextBtn.isUserInteractionEnabled = false
            layerIcon.image = UIImage(named: "context_atmo")
            layerLabel.text = "Atmosphere"
        default:
            print("error context")
            
        }
    }
    
    @objc func handlePageDataUpdate(_ notification: Notification) {
        if let context = notification.object as? Int {
            selectContext(context: context)
        }
    }
    
    @objc func handleApplyLayer(_ notification: Notification) {
        delegate?.applyLayer()
        self.dismiss(animated: true)
    }
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageDataUpdate(_:)), name: .pageDataUpdated, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplyLayer(_:)), name: .applyLayer, object: nil)

        // Do any additional setup after loading the view.
    }
  
    
    override func viewDidDisappear(_ animated: Bool) {
       
        NotificationCenter.default.removeObserver(self, name: .pageDataUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .applyLayer, object: nil)

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
