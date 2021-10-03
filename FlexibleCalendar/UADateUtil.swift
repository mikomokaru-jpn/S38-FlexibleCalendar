//------------------------------------------------------------------------------
//  UADateUtil.swift
//------------------------------------------------------------------------------
import Foundation
//カレンダー情報
struct CalendarInfo {
    var year: Int = 0
    var month: Int = 0
    var daysOfMonth: Int = 0
    var firstWeekday: Int = 0
    var weekDayString: String = ""
}
class UADateUtil: NSObject {
    //シングルトン
    //dateManager は UADateUtilクラスのオブジェクト
    // '={...}()'は 「Initialization Closure」によるプロパティの初期化
    static var dateManager: UADateUtil = {
        return UADateUtil.init()
    }()
    //プロパティ
    private let calendar: Calendar
    private let warekiFormat: DateFormatter
    private let yobiFormat: DateFormatter
    //日付の構成要素
    private let unitDay:Set = [Calendar.Component.year,
                               Calendar.Component.month,
                               Calendar.Component.day,
                               Calendar.Component.weekday]
    //時刻の構成要素
    private let unitTimr:Set = [Calendar.Component.hour,
                                Calendar.Component.minute,
                                Calendar.Component.second]
    //イニシャライザ
    private override init() {
        //カレンダーオブジェクト
        calendar = Calendar.init(identifier: .gregorian)
        // --- 和暦変換 ---
        // 時刻書式指定子を設定
        warekiFormat = DateFormatter.init()
        warekiFormat.dateStyle = .full
        warekiFormat.timeStyle = .none
        //ロケールを設定
        warekiFormat.locale = Locale.init(identifier: "ja_JP")
        //カレンダーを設定
        warekiFormat.calendar = Calendar.init(identifier: .japanese)
        //和暦を出力するように書式指定
        warekiFormat.dateFormat = "GG yy"
        //曜日フォーマット（日本語）
        yobiFormat = DateFormatter.init()
        yobiFormat.locale = Locale.init(identifier: "ja")
        super.init()
    }
    //指定の日付から日数を加算した日付を返す
    func date(date:Date, addDays:Int) -> Date {
        //date(byAdding: , value: , to: )の戻り値は　Date? であるのでアンラップする
        if let dt = calendar.date(byAdding: .day, value: addDays, to: date){
            return dt
        }else{
            print("UADateUtil error")
            return Date()
        }
    }
    //指定の日付から月数を加算した日付を返す
    func date(date:Date, addMonths:Int) -> Date {
        if let dt = calendar.date(byAdding: .month, value: addMonths, to: date){
            return dt
        }else{
            print("UADateUtil error")
            return Date()
        }
    }
    //指定の日付から年数を加算した日付を返す
    func date(date:Date, addYears:Int) -> Date {
        if let dt = calendar.date(byAdding: .year, value: addYears, to: date){
            return dt
        }else{
            print("UADateUtil error")
            return Date()
        }
    }
    //指定の日の月の初日を返す：
    func firstDate(date: Date)->Date{
        var comp: DateComponents = calendar.dateComponents(unitDay, from: date)
        comp.day = 1
        if let returnDate = calendar.date(from: comp){
            return returnDate
        }else{
            print("UADateUtil error")
            return Date()
        }
    }
    //指定の日の月の末日を返す：
    func lastDate(date: Date)->Date{
        let lastDay = calendar.range(of: .day, in: .month, for: date)?.count
        var comp: DateComponents = calendar.dateComponents(unitDay, from: date)
        comp.day = lastDay
        if let returnDate = calendar.date(from: comp){
            return returnDate
        }else{
            print("UADateUtil error")
            return Date()
        }
    }
    //指定した日の月の日数
    func daysOfMonth(date: Date) -> Int{
        if let days = calendar.range(of: .day, in: .month, for: date)?.count{
            return days
        }else{
            print("UADateUtil error")
            return 0
        }
    }
    //指定した日付の年
    func intYear(date: Date) -> Int{
        return calendar.component(.year, from: date)
    }
    //指定した日付の月
    func intMonth(date: Date) -> Int{
        return calendar.component(.month, from: date)
    }
    //指定した日付の日
    func intDay(date: Date) -> Int{
        return calendar.component(.day, from: date)
    }
    //指定した日付の曜日（コード）
    func intWeekday(date: Date) -> Int{
        return calendar.component(.weekday, from: date)
    }
    //指定した日付の曜日（日本語）
    func stringWeekday(date: Date) -> String{
        let weekday = calendar.component(.weekday, from: date)
        return yobiFormat.shortMonthSymbols[weekday-1]
    }
    //指定した日付の整数表現（yyyymmdd）
    func intDate(date: Date)->Int{
        let comp: DateComponents = calendar.dateComponents(unitDay, from: date)
        let year:Int = comp.year ?? 0
        let month:Int = comp.month ?? 0
        let day:Int = comp.day ?? 0
        return year * 10000 + month * 100 + day
    }
    //日付の比較
    func isEqualDate(date1:Date, date2:Date)->Bool{
        let intDate1 = self.intDate(date: date1)
        let intDate2 = self.intDate(date: date2)
        return intDate1 == intDate2
    }
    //西暦年月->和暦年月の変換（元号・半角スペース・和暦："平成 30"）
    func yearOfWareki(date: Date)->Array<String>{
        let wareki = warekiFormat.string(from: date)
        return wareki.components(separatedBy: " ")
    }
    //カレンダー情報・月
    func calendarInfo(date: Date) -> CalendarInfo{
        let year = self.intYear(date: date)
        let month = self.intMonth(date: date)
        return self.calendarInfo(year: year, month: month)
    }
    //カレンダー情報・年間
    func calendarYearInfo(date: Date) -> [CalendarInfo]{
        var calendarInfoList = [CalendarInfo]()
        let year = self.intYear(date: date)
        for i in 1 ... 12{
            calendarInfoList.append(self.calendarInfo(year: year, month: i))
        }
        return calendarInfoList
    }
    private func calendarInfo(year: Int, month: Int) -> CalendarInfo{
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        let dateString =  String(year) + "_" + String(month) + "_1"
        guard  let date = formatter.date(from: dateString) else{
            print("func calendar(_ year: Int) error")
            return CalendarInfo()
        }
        var record = CalendarInfo()
        record.year = year
        record.month = month
        record.daysOfMonth = self.daysOfMonth(date: date)
        record.firstWeekday = self.intWeekday(date: date)
        record.weekDayString = yobiFormat.shortWeekdaySymbols[record.firstWeekday-1]
        return record
    }
}

