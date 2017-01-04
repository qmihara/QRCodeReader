//
//  MetadataObjectViewController.swift
//  QRCodeReader
//
//  Created by Kyusaku Mihara on 1/4/17.
//  Copyright © 2017 epohsoft. All rights reserved.
//

import UIKit
import AVFoundation

class MetadataObjectViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    var metadataObject: AVMetadataMachineReadableCodeObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = metadataObject.stringValue
    }
}
