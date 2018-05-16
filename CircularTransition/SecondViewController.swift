//
//  Created by Nesrine Sghaier on 14/07/2017.
//  Copyright © 2017 Training. All rights reserved.
//

import UIKit
class SecondViewController: UIViewController {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var satelliteButton: UIButton!
    @IBOutlet weak var StandardButton: UIButton!
    @IBOutlet weak var HybridButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.layer.cornerRadius = dismissButton.frame.size.width / 2
        satelliteButton.layer.cornerRadius = 10
        StandardButton.layer.cornerRadius = 10
        HybridButton.layer.cornerRadius = 10
    }

    @IBAction func dismissSecondVC(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
