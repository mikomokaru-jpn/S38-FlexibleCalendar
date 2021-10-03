import Cocoa
enum WeekDayType { //曜日タイプ
    case weelDay
    case sunday
    case saturday
}
class UADayView: NSView {
    var index: Int = 0
    var fontSize: CGFloat = 0
    var weekDay: WeekDayType = .weelDay
    var day: Int = 0
    var isToday: Bool = false{
        didSet{
            if isToday{
                self.layer?.backgroundColor = NSColor.yellow.cgColor
            }else{ //default
                self.layer?.backgroundColor = NSColor.white.cgColor            }
        }
    }
    var isHoliday: Bool = false{
        didSet{
            self.updateText()
        }
    }
    private var attrText: NSMutableAttributedString?
    private var textSize = NSZeroSize
    //イニシャライザ
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.borderWidth = 0.5
        self.layer?.borderColor = NSColor.black.cgColor
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //ビューの再描画
    override func draw(_ dirtyRect: NSRect) {
        //日付
        if let text = self.attrText{
            let point =  NSPoint.init(x: self.bounds.width / 2 - textSize.width / 2,
                                      y: self.bounds.height / 2 - textSize.height / 2)
            text.draw(at: point)
        }
    }
    //日付の設定
    func updateText(){
        self.updateText(rate: 1)
    }
    //日付の設定
    func updateText(rate: CGFloat){
        let font = NSFont.systemFont(ofSize: self.fontSize * rate)
        //曜日の色
        var color = NSColor.black
        switch self.weekDay {
            case .saturday:
            color = NSColor.blue
            case .sunday:
            color = NSColor.red
            default:
            break
        }
        if self.isHoliday{
            color = NSColor.red
        }
        //文字の属性設定
        if day > 0{
            attrText = NSMutableAttributedString(string: String(day))
        }else{
            attrText = NSMutableAttributedString(string: "")
        }
        attrText?.addAttributes([.font:font,
                                 .foregroundColor: color],
                                range: NSMakeRange(0, attrText?.string.count ?? 0))
        self.textSize = attrText?.size() ?? NSZeroSize
        self.needsDisplay = true
    }
}
