//
//  CameraView.swift
//  MenuMirror
//
//  Created by Krishan Patel on 30/07/2015.
//  Copyright (c) 2015 Rocko Labs. All rights reserved.
//

import Cocoa

protocol CameraViewDelegate {
    func didEnterHover()
    func didExitHover()
    func didClick()
}

class CameraView: NSView {

    var trackingRect: NSView.TrackingRectTag?
    var delegate: CameraViewDelegate?

    override var frame: CGRect {
        didSet {
            if (self.trackingRect != nil) {
                self.removeTrackingRect(self.trackingRect!)
            }
            self.trackingRect = self.addTrackingRect(self.frame, owner:self, userData:nil, assumeInside:false)
        }
    }

    override func mouseEntered(with theEvent: NSEvent) {
        self.delegate?.didEnterHover()
    }

    override func mouseExited(with theEvent: NSEvent) {
        self.delegate?.didExitHover()
    }

    override func mouseDown(with theEvent : NSEvent) {
        self.delegate?.didClick()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        self.trackingRect = self.addTrackingRect(frame, owner:self, userData:nil, assumeInside:false)
    }

    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }

}
