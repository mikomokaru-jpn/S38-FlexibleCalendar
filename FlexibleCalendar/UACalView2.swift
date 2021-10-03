
import Cocoa

class UACalView2: UACalView, UADayViewDelegate {
    //windowオブジェクトの監視
    private var observers = [NSKeyValueObservation]()
    //イニシャライザ
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //デリゲートのセット
        for dayView in super.dayViewArray{
            dayView.delegate = self
        }
        //初期の日付選択
        observers.append(self.observe(\.window?, options: [.old, .new]){_,change in
            //windowオブジェクトを取得したタイミング（contentViewにaddされたとき）
            for dayView in self.dayViewArray{
                if dayView.isToday{
                    dayView.selected = true
                    self.window?.makeFirstResponder(dayView)
                }
            }
        })
            
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //マウスクリックによる日付の移動（デリゲートメソッド）
    func clicked(_ index: Int) {
        for dayView in dayViewArray{
            if dayView.day > 0{
                if dayView.index == index{
                    dayView.selected = true
                }else{
                    dayView.selected = false
                }
            }
        }
    }
    //キー入力による日付・月の移動（デリゲートメソッド）
    func goto(event: NSEvent, from: Int){
        var newIndex = -1
        switch event.keyCode {
            case 123: //left
            if from > 0{
                newIndex = from - 1
            }else{
                self.changeMonth(inc: -1) //前月
                newIndex = calSize - 1
            }
            case 124: //right
            if from < self.calSize - 1{
                newIndex = from + 1
            }else{
                self.changeMonth(inc: 1) //翌月
                newIndex = 0
            }
            case 125: //down
            if from + 7 < calSize{
                newIndex = from + 7
            }
            case 126: //up
            if from - 7 >= 0{
                newIndex = from - 7
            }
            case 43: // <
            if event.modifierFlags.contains(.shift){
                self.changeMonth(inc: -1)
                newIndex = calSize - 1
            }
            case 47: // >
            if event.modifierFlags.contains(.shift){
                self.changeMonth(inc: 1)
                newIndex = 0
            }
            default:
                break
        }
        if newIndex >= 0{
            self.window?.makeFirstResponder(dayViewArray[newIndex])
            dayViewArray[newIndex].selected = true
        }
    }
}
