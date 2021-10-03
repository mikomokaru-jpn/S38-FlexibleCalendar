import Cocoa

class UAHeadView: NSView {
    //Y軸反転
    override var isFlipped: Bool{
        return true
    }
    //プロパティ
    var fontSize: CGFloat = 0
    var text: String = ""
    private var attrText: NSMutableAttributedString?
    private var textSize = NSZeroSize
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.black.cgColor

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let text = self.attrText{
            let point =  NSPoint.init(x: self.bounds.width / 2 - textSize.width / 2,
                                      y: self.bounds.height / 2 - textSize.height / 2)
            text.draw(at: point)
        }
    }
    //見出しの設定
    func updateText(){
        self.updateText(rate: 1)
    }
    func updateText(rate: CGFloat){
        attrText = NSMutableAttributedString(string: text)
        let font = NSFont.systemFont(ofSize: self.fontSize * rate)
        attrText?.addAttributes([.font:font, .foregroundColor: NSColor.white],
                                range: NSMakeRange(0, attrText?.string.count ?? 0))
        self.textSize = attrText?.size() ?? NSZeroSize
        self.needsDisplay = true
    }
}
