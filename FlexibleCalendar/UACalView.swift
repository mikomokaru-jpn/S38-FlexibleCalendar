import Cocoa

class UACalView: NSView {
    
    var dayViewArray = [UADayView2]()
    var calDateArray = [CalDate]()
    var calSize: Int = 0
    private var firstDate :Date
    private var preFirstDate :Date
    private var nextFirstDate :Date    
    private var youbiViewArray = [UAHeadView]()
    private var holidays: Dictionary = [String: String]()
    //日付ユーティリティ
    private let dateUtil = UADateUtil.dateManager
    //外形定義
    let calViewSize = NSSize(width: 280, height: 315) //カレンダービューのサイズ
    private let dayViewSize = NSSize(width: 40, height: 40) //日付ビューのサイズ
    private let fontSize: CGFloat = 24
    private let smallFontSize: CGFloat = 16
    private let headerRect = NSRect.init(x: 0, y: 0, width: 280, height: 50) //見出しビューのサイズ
    private let youbisRect = NSRect.init(x: 0, y: 50, width: 280, height: 25) //曜日見出しビューのサイズ
    private let preBtnRect = NSRect.init(x: 5, y: 8, width: 36, height: 36)
    private let nextBtnRect = NSRect.init(x: 280-5-36, y: 8, width: 36, height: 36)
    private let WEEK4 = 28
    private let WEEK5 = 35
    private let WEEK6 = 42
    private let youbiList = ["月", "火", "水", "木", "金", "土", "日",]
    //コントロール参照
    private let headerViewObj = UAHeadView.init(frame: NSRect.init())
    private let youbisViewObj = NSView.init(frame: NSRect.init())
    private let preBtnObj = NSButton.init()
    private let nextBtnObj = NSButton.init()
    //サイズ変更監視
    private var observers = [NSKeyValueObservation]()
    //カレンダ情報
    struct CalDate {
        var year: Int = 0
        var month: Int = 0
        var day: Int = 0
        var selected: Bool = false
        
        mutating func setDate (_ y: Int, _ m: Int, _ d: Int) {
            self.year = y
            self.month = m
            self.day = d
        }
        var ymd: Int{
            return year * 10000 + month * 100 + day
        }
    }
    //Y軸反転
    override var isFlipped: Bool{
        return true
    }
    //イニシャライザ
    override init(frame frameRect: NSRect) {
        //初日
        firstDate = dateUtil.firstDate(date: Date())
        preFirstDate = dateUtil.date(date: firstDate, addMonths: -1)
        nextFirstDate = dateUtil.date(date: firstDate, addMonths: 1)
        //スーパークラスのイニシャライズ
        super.init(frame: frameRect)
        //初期処理
        self.frame.size = calViewSize
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.black.cgColor
        //見出しの作成
        headerViewObj.frame = self.headerRect
        self.addSubview(headerViewObj)
        //曜日見出しの作成
        youbisViewObj.frame = self.youbisRect
        for i in 0 ..< 7{
            let youbi = UAHeadView.init()
            youbi.frame = CGRect(x: CGFloat(i) * (headerRect.width / 7), y: 0,
                                 width: youbisRect.width / CGFloat(7),
                                 height: youbisRect.height)
            youbi.text = youbiList[i]
            youbi.fontSize = smallFontSize
            youbi.updateText()
            youbiViewArray.append(youbi)
            youbisViewObj.addSubview(youbi)
        }
        self.addSubview(youbisViewObj)
        //移動ボタンの作成
        preBtnObj.frame = self.preBtnRect
        preBtnObj.bezelStyle = .texturedSquare
        preBtnObj.title = "<"
        preBtnObj.font = NSFont.systemFont(ofSize: fontSize)
        preBtnObj.tag = -1
        preBtnObj.target = self
        preBtnObj.action = #selector(self.btnClicked(_:))
        headerViewObj.addSubview(preBtnObj)
        nextBtnObj.frame = self.nextBtnRect
        nextBtnObj.bezelStyle = .texturedSquare
        nextBtnObj.title = ">"
        nextBtnObj.font = NSFont.systemFont(ofSize: fontSize)
        nextBtnObj.tag = 1
        nextBtnObj.target = self
        nextBtnObj.action = #selector(self.btnClicked(_:))
        headerViewObj.addSubview(nextBtnObj)
        //空の日付ビュー/カレンダー情報を作成
        var index = 0
        for i in 0 ..< 6{
            for j in 0 ..< 7{
                calDateArray.append(CalDate())
                dayViewArray.append(UADayView2.init()) //日付ビュー
                dayViewArray[index].index = index
                addSubview(dayViewArray[index])
                dayViewArray[index].frame =
                    NSRect.init(x: dayViewSize.width * CGFloat(j),
                                y: dayViewSize.height * CGFloat(i)
                                    + headerRect.height + youbisRect.height,
                                width: dayViewSize.width,
                                height: dayViewSize.height)
                if j == 5{
                    dayViewArray[index].weekDay = .saturday
                }
                if j == 6{
                    dayViewArray[index].weekDay = .sunday
                }
                index += 1
            }
        }
        //休日ファイルの読み込み
        if let path = Bundle.main.path(forResource: "holiday", ofType: "json"){
            do {
                let url:URL = URL.init(fileURLWithPath: path)
                let data = try Data.init(contentsOf: url)
                let jsonData = try JSONSerialization.jsonObject(with: data)
                if  let dictionary = jsonData as? Dictionary<String, String>{
                    holidays = dictionary
                }else{
                    print("休日ファイルを読み込めません")
                    return
                }
            }catch{
                print("休日ファイルを読み込めません \(error.localizedDescription)")
            }
        }
        //日付のセット
        self.setDate()
        //親ビュー（自身）のサイズが変わったとき（コンテントビューのサイズと連動する）
        observers.append(self.observe(\.layer?.bounds, options: [.old, .new]){_,change in
            if let bounds = change.newValue as? CGRect{
                self.viewTransform(rect: bounds)
            }
        })
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //月移動ボタン
    @objc private func btnClicked(_ sender: NSButton){
        self.changeMonth(inc: sender.tag)
    }
    //月移動
    func changeMonth(inc: Int){
        firstDate = dateUtil.date(date: firstDate, addMonths: inc)
        preFirstDate = dateUtil.date(date: firstDate, addMonths: -1)
        nextFirstDate = dateUtil.date(date: firstDate, addMonths: 1)
        self.setDate()
        self.viewTransform(rect: self.bounds)

    }
    //日付のセット
    private func setDate(){
        let preCalInfo = dateUtil.calendarInfo(date: preFirstDate)      //前月
        let thisCalInfo = dateUtil.calendarInfo(date: firstDate)        //当月
        let nextCalInfo = dateUtil.calendarInfo(date: nextFirstDate)    //翌月
        //見出し
        headerViewObj.text = String(format: "%ld年% ld月",
                                    thisCalInfo.year, thisCalInfo.month)
        headerViewObj.fontSize = fontSize
        headerViewObj.updateText()
        //日付
        let start = (thisCalInfo.firstWeekday + 5) % 7
        var preDay = preCalInfo.daysOfMonth - start - 1
        var thisDay = 0
        var nextDay = 0
        //カレンダーのい大きさ
        if thisCalInfo.daysOfMonth + start <=  WEEK4{
            self.calSize = WEEK4
        }else if thisCalInfo.daysOfMonth + start <=  WEEK5{
            self.calSize = WEEK5
        }else{
            self.calSize = WEEK6
        }
        for i in 0 ..< WEEK6{
            if i < start {
                //前月
                preDay += 1
                self.setDateItem(index: i,calInfo: preCalInfo, day: preDay,
                                 size: smallFontSize)
            }else if i < start + thisCalInfo.daysOfMonth{
                //当月
                thisDay += 1
                self.setDateItem(index: i,calInfo: thisCalInfo, day: thisDay,
                                 size: fontSize)
            }else{
                //翌月
                if (i >= WEEK4) && (self.calSize == WEEK4){
                    nextDay = 0
                }else if (i >= WEEK5) && (self.calSize == WEEK5){
                        nextDay = 0
                }else{
                    nextDay += 1
                }
                self.setDateItem(index: i, calInfo: nextCalInfo,day: nextDay,
                                 size: smallFontSize)
            }
        }
        //初期化
        for dt in dayViewArray{
            dt.isHoliday = false
            dt.isToday = false
            dt.selected = false
        }
        //休日のセット
        for i in 0 ..< calDateArray.count{
            for (key, _) in holidays{
                if let ymd = Int(key),
                   calDateArray[i].ymd == ymd{
                        dayViewArray[i].isHoliday = true
                        break
                }
            }
        }
        //現在日のセット
        let current = dateUtil.intDate(date: Date())
        for i in 0 ..< calDateArray.count{
            if calDateArray[i].ymd == current{
                dayViewArray[i].isToday = true
            }
        }
    }
    private func setDateItem(index: Int, calInfo:CalendarInfo, day: Int, size: CGFloat){
        dayViewArray[index].index = index
        dayViewArray[index].day = day
        dayViewArray[index].fontSize = size
        dayViewArray[index].updateText()
        calDateArray[index].setDate(calInfo.year, calInfo.month, day)
    }
    //拡大・縮小
    private func viewTransform(rect: CGRect){
        let rateWidth: CGFloat = bounds.width / self.calViewSize.width
        let rateHeight: CGFloat = bounds.height / self.calViewSize.height
        //見出し
        self.transForm(rect: &self.headerViewObj.frame, original: self.headerRect,
                       xRate:rateWidth, yRate: rateHeight)
        self.self.headerViewObj.updateText(rate: sqrt(rateWidth * rateHeight))
        self.transForm(rect: &self.preBtnObj.frame, original: self.preBtnRect,
                       xRate:rateWidth, yRate: rateHeight)
        //ボタン
        self.transForm(rect: &self.preBtnObj.frame, original: self.preBtnRect,
                       xRate:rateWidth, yRate: rateHeight)
        self.preBtnObj.font = NSFont.systemFont(ofSize: fontSize * sqrt(rateWidth * rateHeight))
        self.transForm(rect: &self.nextBtnObj.frame, original: self.nextBtnRect,
                       xRate:rateWidth, yRate: rateHeight)
        self.nextBtnObj.font = NSFont.systemFont(ofSize: fontSize * sqrt(rateWidth * rateHeight))
        //曜日見出し
        self.transForm(rect: &self.youbisViewObj.frame, original: self.youbisRect,
                       xRate:rateWidth, yRate: rateHeight)
        let youbiW = youbisRect.width / 7
        for i in 0 ..< 7{
            self.transForm(rect: &self.youbiViewArray[i].frame,
                           original: CGRect(x: CGFloat(i) * (youbisRect.width / 7), y: 0,
                                            width: youbiW, height: youbisRect.height),
                           xRate:rateWidth, yRate: rateHeight)
            self.youbiViewArray[i].updateText(rate: sqrt(rateWidth * rateHeight))
        }
        //日付
        var index = 0
        for i in 0 ..< 6{
              for j in 0 ..< 7{
                let point =  CGPoint(x: CGFloat(j) * self.dayViewSize.width,
                                     y: CGFloat(i) * self.dayViewSize.height + youbisRect.height  + headerRect.height)
                self.transForm(rect: &self.dayViewArray[index].frame,
                               original: CGRect.init(origin: point, size: self.dayViewSize),
                               xRate:rateWidth, yRate: rateHeight)
                self.dayViewArray[index].updateText(rate: sqrt(rateWidth * rateHeight))
                index += 1
            }
        }
    }
    private func transForm(rect: inout CGRect, original: CGRect, xRate: CGFloat, yRate: CGFloat){
        rect.size.width = original.size.width * xRate
        rect.size.height = original.size.height * yRate
        rect.origin.x = original.origin.x * xRate
        rect.origin.y = original.origin.y * yRate
 
    }
}
