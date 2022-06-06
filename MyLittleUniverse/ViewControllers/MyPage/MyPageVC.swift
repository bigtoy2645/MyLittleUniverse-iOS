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
    let viewModel = MyPageViewModel()
    private let datePicker = UIDatePicker()
    private var toolBar = UIToolbar()
    private var oldSelectedDate: Date?
    private var dateComponents = DateComponents()
    private var installMonth: Date?
    private var cardVC: CardVC?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCount.layer.cornerRadius = btnCount.frame.width / 2
        btnCount.layer.borderWidth = 1
        btnCount.layer.borderColor = UIColor.bgGreen.cgColor
        
        tabView.addShadow(location: .top)
        tabView.vc = self
        
        // 앱 설치된 월
        if let docUrlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.path,
           let createdDate = try? FileManager.default.attributesOfItem(atPath: docUrlPath)[.creationDate] as? Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            let dateString = "\(createdDate.year)-\(createdDate.month)-01"
            installMonth = formatter.date(from: dateString)
        }
        
        if let cardVC = Route.getVC(.cardVC) as? CardVC {
            self.cardVC = cardVC
            self.present(asChildViewController: cardVC, view: cardView)
        }
        
        setupCalendar()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dotView.backgroundColor = .clear
        dotView.createDottedLine(width: 1.0, color: UIColor.bgGreen.cgColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .light
    }
    
    /* Binding */
    func setupBindings() {
        // 사용자명
        viewModel.userName
            .bind(to: lblUser.rx.text)
            .disposed(by: disposeBag)
        
        // 이전달
        btnLeft.rx.tap
            .bind { self.moveCalendarPage(moveUp: false) }
            .disposed(by: disposeBag)
        
        // 다음달
        btnRight.rx.tap
            .bind { self.moveCalendarPage(moveUp: true) }
            .disposed(by: disposeBag)
        
        // 현재 페이지 날짜
        viewModel.calendarDate
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
        
        viewModel.selectedMoments
            .bind { self.cardVC?.moments.accept($0) }
            .disposed(by: disposeBag)
        
        cardVC?.height
            .bind(to: cardViewHeight.rx.constant)
            .disposed(by: disposeBag)
    }
    
    /* 달력 설정 */
    func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.select(viewModel.selectedDate.value)
        calendar.scrollEnabled = true
        calendar.calendarHeaderView.isHidden = true
        calendar.headerHeight = 0
        calendar.today = nil
        calendar.placeholderType = .none
        calendar.appearance.eventDefaultColor = .mainBlack
        calendar.appearance.eventSelectionColor = .mainBlack
        calendar.appearance.eventOffset = CGPoint(x: 0, y: 5)
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
        datePicker.minimumDate = installMonth
        
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
        
        if let page = currentCalendar.date(byAdding: dateComponents, to: viewModel.currentPage.value) {
            calendar.setCurrentPage(page, animated: true)
            calendar.select(page)
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
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var btnCount: UIButton!
    
    @IBOutlet weak var dateSelectorView: UIStackView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var backUpView: UIView!
    @IBOutlet weak var tabView: TabBarView!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewHeight: NSLayoutConstraint!
}

// MARK: - FSCalendar

extension MyPageVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    /* 날짜 선택 */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.selectedDate.accept(date)
    }
    
    /* 달력 페이지 변경 */
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        viewModel.currentPage.accept(calendar.currentPage)
    }
    
    /* 달력 날짜에 이벤트 표시 */
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let isRegistered = viewModel.moments.value.contains { moment in
            moment.year == date.year &&
            moment.month == date.month &&
            moment.day == date.day
        }
        return isRegistered ? 1 : 0
    }
    
    /* 최초 설치 월 이후 달력 표시 */
    func minimumDate(for calendar: FSCalendar) -> Date {
        return installMonth ?? Date()
    }
}
