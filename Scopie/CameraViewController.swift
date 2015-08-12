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
        self.vTopBar.layer?.backgroundColor = NSColor(calibratedRed:0, green:0, blue:0, alpha:0.3).CGColor

        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var videoDevice: AVCaptureDevice! = self.deviceWithMediaType(AVMediaTypeVideo, preferringPosition:.Front)
            println("videoDevice: \(videoDevice)")

            var error: NSError? = nil
            var videoDeviceInput: AVCaptureDeviceInput? =  AVCaptureDeviceInput(device:videoDevice, error:&error)
            println("videoDeviceInput: \(videoDeviceInput)")
            println("error: \(error)")

            if self.captureSession.canAddInput(videoDeviceInput) {
                println("adding video input")
                self.captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput

                dispatch_async(dispatch_get_main_queue(), {
                    self.previewLayer = AVCaptureVideoPreviewLayer(session:self.captureSession)
                    self.previewLayer?.frame = self.vCameraOutput.bounds
                    self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.previewLayer?.setAffineTransform(CGAffineTransformMakeScale(-1, 1))
                    self.vCameraOutput.wantsLayer = true
                    self.vCameraOutput.layer?.addSublayer(self.previewLayer)
                })
            }

            self.stillImageOutput = AVCaptureStillImageOutput()
            if self.captureSession.canAddOutput(self.stillImageOutput){
                self.stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                self.captureSession.addOutput(self.stillImageOutput)
            }
        });

        self.vCameraOutput.delegate = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.captureSession.startRunning()
        self.showTopBar(animated:true)
        self.hideTopBarAfterDelay()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.captureSession.stopRunning()
    }

    func deviceWithMediaType(mediaType: String, preferringPosition: AVCaptureDevicePosition) -> AVCaptureDevice{
        var devices = AVCaptureDevice.devicesWithMediaType(mediaType);
        var captureDevice: AVCaptureDevice = devices[0] as! AVCaptureDevice;

        for device in devices {
            if device.position == preferringPosition {
                captureDevice = device as! AVCaptureDevice
                break
            }
        }

        return captureDevice
    }

    @IBAction func didTapCapture(sender: AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let videoOrientation = self.previewLayer!.connection.videoOrientation
            self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = videoOrientation
            self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (imageDataSampleBuffer: CMSampleBuffer!, error: NSError!) in
                if error == nil {
                    var data: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)

                    let paths = NSSearchPathForDirectoriesInDomains(.PicturesDirectory, .UserDomainMask, true)
                    var directory = "\(paths[0] as! String)/\(self.IMAGE_CREDIT)"
                    NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories:false, attributes:nil, error:nil)
                    var ret = data.writeToFile("\(directory)/\(self.getShortDateString()).jpg", atomically:true)
                    println("created image: \(ret)")

                    dispatch_async(dispatch_get_main_queue(), {
                        self.runStillImageCaptureAnimation()
                    })
                } else {
                    println(error)
                }
            })
        })
    }

    @IBAction func didTapOpenFolder(sender: AnyObject) {
        let paths = NSSearchPathForDirectoriesInDomains(.PicturesDirectory, .UserDomainMask, true)
        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([paths[0]])
    }

    @IBAction func didTapQuit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(sender)
    }

    @IBAction func didTapLink(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string:"http://www.scopieapp.com/share.html")!)
    }
    
    func showTopBar(animated: Bool = true) {
        self.setBarTopConstraintValue(0, animated:animated)
    }

    func hideTopBarAfterDelay() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.hideTopBar()
        })
    }

    func hideTopBar(animated: Bool = true) {
        self.setBarTopConstraintValue(-self.vTopBar.frame.height, animated:animated)
    }

    private func setBarTopConstraintValue(constraintValue: CGFloat, animated: Bool = true) {
        self.conTopBarTop.constant = constraintValue
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            context.duration = animated ? 0.3 : 0
            context.allowsImplicitAnimation = true
            self.view.layoutSubtreeIfNeeded()
            }, completionHandler: {
        })
    }

    func getShortDateString() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter.stringFromDate(NSDate())
    }

    func runStillImageCaptureAnimation() {
        let animation = CABasicAnimation(keyPath:"opacity")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        self.vCameraOutput.layer?.addAnimation(animation, forKey:animation.keyPath)
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
