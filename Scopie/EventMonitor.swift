import Cocoa

open class EventMonitor {
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEvent.EventTypeMask
    fileprivate let handler: (NSEvent?) -> ()

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        self.stop()
    }

    open func start() {
        self.monitor = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler:self.handler) as AnyObject
    }

    open func stop() {
        if (self.monitor != nil) {
            NSEvent.removeMonitor(self.monitor!)
            self.monitor = nil
        }
    }
}
