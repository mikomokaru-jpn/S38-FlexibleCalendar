import Cocoa

protocol UADayViewDelegate {
    func clicked(_ index: Int)
    func goto(event: NSEvent, from: Int)
}
class UADayView2: UADayView {
    //日付の選択状態
    var selected: Bool = false{
        didSet{
            if selected{
                self.layer?.borderWidth = 3
                self.layer?.borderColor = NSColor.blue.cgColor
            }else{ //default
                self.layer?.borderWidth = 0.5
                self.layer?.borderColor = NSColor.black.cgColor
            }
        }
    }
    var delegate: UADayViewDelegate? = nil
    //ファーストレスポンダー・選択状態を解除する
    override func resignFirstResponder() -> Bool {
        self.selected = false
        return true
    }
    //日付をクリック
    override func mouseUp(with event: NSEvent) {
        delegate?.clicked(self.index)
    }
    //キー入力
    override func keyDown(with event: NSEvent) {
        delegate?.goto(event: event, from: self.index)
        //super.keyDown(with: event)
    }
}
