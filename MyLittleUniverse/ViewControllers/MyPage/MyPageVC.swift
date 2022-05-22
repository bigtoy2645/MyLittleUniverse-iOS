//
//  MyPageVC.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/05/19.
//

import UIKit
import RxSwift
import RxRelay
import FSCalendar

class MyPageVC: UIViewController {
    var currentPage = BehaviorRelay<Date>(value: Date())
    let selectedDate = BehaviorRelay<Date>(value: Date())
    private let datePicker = UIDatePicker()
    private var toolBar = UIToolbar()
    private var oldSelectedDate: Date?
    private var dateComponents = DateComponents()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCount.layer.cornerRadius = btnCount.frame.width / 2
        btnCount.layer.borderWidth = 1
        btnCount.layer.borderColor = UIColor.bgGreen.cgColor
        
        setupCalendar()
        setupBindings()
    }
    
    /* Binding */
    func setupBindings() {
        // 이전달
        btnLeft.rx.tap
            .bind { self.moveCalendarPage(moveUp: false) }
            .disposed(by: disposeBag)
        
        // 다음달
        btnRight.rx.tap
            .bind { self.moveCalendarPage(moveUp: true) }
            .disposed(by: disposeBag)
        
        // 현재 페이지 날짜
        currentPage.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY. MM"
            return formatter.string(from: $0)
        }
        .bind(to: lblDate.rx.text)
        .disposed(by: disposeBag)
        
        // 연월 선택
        dateSelectorView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.presentDatePicker()
            })
            .disposed(by: disposeBag)
        
        // 날짜 선택
        datePicker.rx.date
            .subscribe(onNext: {
                self.calendar.select($0, scrollToDate: true)
            })
            .disposed(by: disposeBag)
        
        // 나의 세계로 이동
        btnCount.rx.tap
            .bind {
                let universeVC = Route.getVC(.myUniverseVC)
                self.navigationController?.pushViewController(universeVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        Repository.instance.moments
            .map { String($0.count) }
            .bind(to: btnCount.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        // 기록 보관하기
        backUpView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in self.presentBackUpAlert() })
            .disposed(by: disposeBag)
    }
    
    /* 달력 설정 */
    func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.select(selectedDate.value)
        calendar.scrollEnabled = true
        calendar.calendarHeaderView.isHidden = true
        calendar.headerHeight = 0
        calendar.today = nil
        calendar.placeholderType = .fillSixRows
        calendar.appearance.eventDefaultColor = .mainBlack
        calendar.appearance.selectionColor = .pointYellow
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        calendar.appearance.titleDefaultColor = .mediumGray
        calendar.appearance.titleSelectionColor = .mainBlack
        calendar.appearance.titlePlaceholderColor = .clear
    }
    
    /* 기록 보관하기 클릭 시 */
    func presentBackUpAlert() {
        guard let alertVC = Route.getVC(.alertVC) as? AlertVC else { return }
        
        alertVC.modalPresentationStyle = .overFullScreen
        let alert = Alert(title: "열심히 준비 중입니다.\n업데이트가 완료되면 알려드릴게요!")
        alertVC.vm.alert.accept(alert)
        alertVC.vm.alert.accept(alert)
        self.present(alertVC, animated: false) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.dismiss(animated: false)
                }
            }
        }
    }
    
    /* DatePicker 표시 */
    func presentDatePicker() {
        oldSelectedDate = calendar.selectedDate
        datePicker.date = calendar.selectedDate ?? Date()
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.backgroundColor = .white
        
        let pickerHeight: CGFloat = 300
        let toolBarHeight: CGFloat = 50
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0,
                                  y: UIScreen.main.bounds.size.height - pickerHeight,
                                  width: UIScreen.main.bounds.size.width,
                                  height: pickerHeight)
        view.addSubview(datePicker)
        
        toolBar = UIToolbar(frame: CGRect(x: 0,
                                          y: UIScreen.main.bounds.size.height - pickerHeight,
                                          width: UIScreen.main.bounds.size.width,
                                          height: toolBarHeight))
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onCancelButtonClick)),
                         UIBarButtonItem(title: "선택", style: .done, target: self, action: #selector(onDoneButtonClick))]
        toolBar.sizeToFit()
        view.addSubview(toolBar)
    }
    
    /* 달력 페이지 변경 */
    private func moveCalendarPage(moveUp: Bool) {
        let currentCalendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        
        if let page = currentCalendar.date(byAdding: dateComponents, to: currentPage.value) {
            calendar.setCurrentPage(page, animated: true)
        }
    }
    
    /* 날짜 선택 */
    @objc private func dateChanged(_ sender: UIDatePicker?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
    }
    
    /* 날짜 선택 취소 */
    @objc private func onCancelButtonClick() {
        calendar.select(oldSelectedDate, scrollToDate: true)
        onDoneButtonClick()
    }
    
    /* 날짜 선택 완료 */
    @objc private func onDoneButtonClick() {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnCount: UIButton!
    
    @IBOutlet weak var dateSelectorView: UIStackView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var backUpView: UIView!
    
}

// MARK: - FSCalendar

extension MyPageVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    /* 날짜 선택 */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate.accept(date)
    }
    
    /* 달력 페이지 변경 */
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        currentPage.accept(calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let currentPageDate = currentPage.value
        if date.year == currentPageDate.year,
           date.month == currentPageDate.month { return true }
        return false
    }
    
    //    /* 달력 날짜에 이벤트 표시 */
    //    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    //        if let tasks = todoScheduled[date.toString()], tasks.count > 0 { return 1 }
    //        return 0
    //    }
}
