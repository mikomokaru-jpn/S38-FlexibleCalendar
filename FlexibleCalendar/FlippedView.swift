import Cocoa

class FlippedView: NSView {
    //Y軸反転
    override var isFlipped: Bool{
        return true
    }
}
