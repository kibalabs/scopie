//
//  CameraViewController.swift
//  
//
//  Created by Krishan Patel on 29/07/2015.
//
//

import Cocoa
import AVFoundation
import AVKit

class CameraViewController: NSViewController, CameraViewDelegate {

    let IMAGE_CREDIT = "Scopie"

    let captureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?

    @IBOutlet weak var vTopBar: NSView!
    @IBOutlet weak var conTopBarTop: NSLayoutConstraint!
    @IBOutlet weak var vCameraOutput: CameraView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make everything use layers so view order is preserved
        self.view.wantsLayer = true
        self.vTopBar.layer?.backgroundColor = NSColor(calibratedRed:0, green:0, blue:0, alpha:0.3).cgColor

        self.captureSession.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.high))

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            let videoDevice: AVCaptureDevice = self.deviceWithMediaType(convertFromAVMediaType(AVMediaType.video), preferringPosition:.front);
            print("videoDevice: \(String(describing: videoDevice))")
            guard let videoDeviceInput: AVCaptureDeviceInput = try? AVCaptureDeviceInput(device:videoDevice) else {
                return;
            }
            print("videoDeviceInput: \(String(describing: videoDeviceInput))")
            if self.captureSession.canAddInput(videoDeviceInput) {
                print("adding video input")
                self.captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async(execute: {
                    self.previewLayer = AVCaptureVideoPreviewLayer(session:self.captureSession)
                    self.previewLayer?.frame = self.vCameraOutput.bounds
                    self.previewLayer?.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
                    self.previewLayer?.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
                    self.vCameraOutput.wantsLayer = true
                    self.vCameraOutput.layer?.addSublayer(self.previewLayer!)
                })
            }

            self.stillImageOutput = AVCaptureStillImageOutput()
            if self.captureSession.canAddOutput(self.stillImageOutput!){
                self.stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                self.captureSession.addOutput(self.stillImageOutput!)
            }
        });

        self.vCameraOutput.delegate = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.captureSession.startRunning()
        self.showTopBar(true)
        self.hideTopBarAfterDelay()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.captureSession.stopRunning()
    }

    func deviceWithMediaType(_ mediaType: String, preferringPosition: AVCaptureDevice.Position) -> AVCaptureDevice{
        var devices = AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType));
        var captureDevice: AVCaptureDevice = devices[0] ;

        for device in devices {
            if (device as AnyObject).position == preferringPosition {
                captureDevice = device 
                break
            }
        }

        return captureDevice
    }

    @IBAction func didTapCapture(_ sender: AnyObject) {
        guard let stillImageOutput = self.stillImageOutput else {
            return;
        }
        guard let previewLayerConnection = self.previewLayer?.connection else {
            return;
        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            guard let videoConnection = stillImageOutput.connection(with: AVMediaType.video) else {
                return;
            }
            videoConnection.videoOrientation = previewLayerConnection.videoOrientation;
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer: CMSampleBuffer?, error: Error?) in
                if let error = error {
                    print(error);
                    return;
                }
                guard let imageDataSampleBuffer = imageDataSampleBuffer else {
                    print("imageDataSampleBuffer is nil")
                    return;
                }
                guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) else {
                    print("failed to extract data")
                    return;
                }

                let paths = NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true)
                let directory = "\(paths[0] )/\(self.IMAGE_CREDIT)"
                try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories:false, attributes:nil)
                let ret = (try? data.write(to: URL(fileURLWithPath: "\(directory)/\(self.getShortDateString()).jpg"), options: [.atomic])) != nil
                print("created image: \(ret)")

                DispatchQueue.main.async(execute: {
                    self.runStillImageCaptureAnimation()
                })
            };
        })
    }

    @IBAction func didTapOpenFolder(_ sender: AnyObject) {
        let paths = NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true)
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: paths[0])])
    }

    @IBAction func didTapQuit(_ sender: AnyObject) {
        NSApplication.shared.terminate(sender)
    }

    @IBAction func didTapLink(_ sender: AnyObject) {
        NSWorkspace.shared.open(URL(string:"https://www.scopieapp.com")!)
    }
    
    func showTopBar(_ animated: Bool = true) {
        self.setBarTopConstraintValue(0, animated:animated)
    }

    func hideTopBarAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.hideTopBar()
        })
    }

    func hideTopBar(_ animated: Bool = true) {
        self.setBarTopConstraintValue(-self.vTopBar.frame.height, animated:animated)
    }

    fileprivate func setBarTopConstraintValue(_ constraintValue: CGFloat, animated: Bool = true) {
        self.conTopBarTop.constant = constraintValue
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            context.duration = animated ? 0.3 : 0
            context.allowsImplicitAnimation = true
            self.view.layoutSubtreeIfNeeded()
            }, completionHandler: {
        })
    }

    func getShortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter.string(from: Date())
    }

    func runStillImageCaptureAnimation() {
        let animation = CABasicAnimation(keyPath:"opacity")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        self.vCameraOutput.layer?.add(animation, forKey:animation.keyPath)
    }

    func didEnterHover() {
        self.showTopBar()
    }

    func didExitHover() {
        self.hideTopBar()
    }

    func didClick() {
        self.didTapCapture(self.vCameraOutput)
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVCaptureSessionPreset(_ input: AVCaptureSession.Preset) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
	return input.rawValue
}
