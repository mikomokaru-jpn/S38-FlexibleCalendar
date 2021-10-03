import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.white.cgColor
        let calendarView = UACalView2.init(frame: NSRect.init(x: 10, y: 10, width: 0, height: 0))
        calendarView.autoresizingMask = [.width, .height]
        window.setContentSize(NSSize(width: calendarView.calViewSize.width + 20,
                                     height: calendarView.calViewSize.height + 20))
        window.contentView?.addSubview(calendarView)
    }
}

