//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Kyusaku Mihara on 1/4/17.
//  Copyright © 2017 epohsoft. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var captureView: UIView!

    fileprivate lazy var captureSession: AVCaptureSession = AVCaptureSession()
    private lazy var captureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    private lazy var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer = { [unowned self] in
        return AVCaptureVideoPreviewLayer(session: self.captureSession)
    }()
    private lazy var captureInput: AVCaptureInput? = { [unowned self] in
        return try? AVCaptureDeviceInput(device: self.captureDevice)
    }()
    fileprivate var outputMetadataObject: AVMetadataMachineReadableCodeObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        captureSession.addInput(captureInput)

        let captureOutput = AVCaptureMetadataOutput()
        captureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(captureOutput)
        captureOutput.metadataObjectTypes = captureOutput.availableMetadataObjectTypes

        captureVideoPreviewLayer.frame = captureView.bounds
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureView.layer.addSublayer(captureVideoPreviewLayer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()

        super.viewWillDisappear(animated)
    }

    // MARK: - Notification methods

    func orientationChanged(notification: NSNotification) {
        let orientation = UIDevice.current.orientation
        let captureVideoOrientation: AVCaptureVideoOrientation
        switch orientation {
        case .portrait:
            captureVideoOrientation = .portrait
        case .portraitUpsideDown:
            captureVideoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            captureVideoOrientation = .landscapeRight
        case .landscapeRight:
            captureVideoOrientation = .landscapeLeft
        case.faceUp:
            captureVideoOrientation = .portrait
        case .faceDown:
            captureVideoOrientation = .portrait
        case .unknown:
            captureVideoOrientation = .portrait
        }
        captureVideoPreviewLayer.frame = captureView.bounds
        captureVideoPreviewLayer.connection.videoOrientation = captureVideoOrientation
        (captureSession.outputs.first as? AVCaptureOutput)?.connection(withMediaType: AVMediaTypeVideo)?.videoOrientation = captureVideoOrientation
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let outputMetadataObject = outputMetadataObject else {
            return
        }
        guard let viewController = (segue.destination as? UINavigationController)?.topViewController as? MetadataObjectViewController else {
            fatalError()
        }
        viewController.metadataObject = outputMetadataObject
        self.outputMetadataObject = nil
    }

    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        guard let metadataObject = metadataObjects.flatMap({ $0 as? AVMetadataMachineReadableCodeObject }).filter ({ $0.type == AVMetadataObjectTypeQRCode }).first else {
            return
        }

        captureSession.stopRunning()
        outputMetadataObject = metadataObject
        performSegue(withIdentifier: "PresentMetadataObjectView", sender: nil)
    }
}

