//
//  TimerVC.swift
//  Pomodoro
//
//  Created by Osaretin Uyigue on 7/15/22.
//

import UIKit

class TimerVC: UIViewController {

    
    //MARK: - View's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpViews()
        setUpInitalState()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpCircularProgressBarView()
    }
    
    //MARK: - Properties
    let currentModeButtonColor = UIColor.appMainColor.withAlphaComponent(0.4)
    fileprivate(set) var timer: Timer?
    
    fileprivate(set) var elapsedTimeInSeconds = 0
    
    fileprivate(set) var shortRestDurationInMinutes = 3
    
    fileprivate var elapsedTimeInMinutes: CGFloat {
        get {
            return CGFloat(elapsedTimeInSeconds / 60)
        }
    }
    
    var focusDurationInMinutes = 1 {
        didSet {
            let color = pomodoroSessionType == .work ? UIColor.appMainColor : UIColor.appGrayColor
            setUpFocusTimerMinutesLabel(color: color)
        }
    }
    
    
    var pomodoroSessionType: PomodoroSessionType = .work
    
    var minutesToSecondsMultiplier = 60
    
    fileprivate(set) var currentTimerStatus: TimerStatus = .inactive {
        didSet {
            configureStartPauseTimerButton(using: currentTimerStatus)
        }
    }

    
    fileprivate lazy var currentModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 0.8
        button.layer.borderColor = currentModeButtonColor.cgColor
        button.setTitle("Work", for: .normal)
        button.setTitleColor(currentModeButtonColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = UIColor.appMainColor.withAlphaComponent(0.1)
        button.tintColor = currentModeButtonColor
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .black, scale: .medium)
        let image = UIImage(systemName: "chevron.down", withConfiguration:
                                config)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        return button
    }()
    
    
    fileprivate let currentTaskLabelHeight: CGFloat = 45
    fileprivate lazy var currentTaskLabel: UILabelWithInsets = {
        let label = UILabelWithInsets()
        label.text = "Current Task Label"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.rgb(red: 242, green: 242, blue: 246)
        label.textInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = currentTaskLabelHeight / 2
        return label
    }()
    
    
    let taskButtonDimen: CGFloat = 60
    fileprivate lazy var taskButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "rectangle.grid.1x2.fill")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = taskButtonDimen / 2
        button.tintColor = .lightGray
        button.backgroundColor = UIColor.rgb(red: 242, green: 242, blue: 246)
        button.addTarget(self, action: #selector(didTapTasksButton), for: .touchUpInside)
        return button
    }()
    
    
    fileprivate lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = taskButtonDimen / 2
        button.tintColor = .lightGray
        button.backgroundColor = UIColor.rgb(red: 242, green: 242, blue: 246)
        button.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        return button
    }()
    
    
    fileprivate let circularProgressBarParentViewDimen: CGFloat = 150
    fileprivate lazy var circularProgressBarParentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = circularProgressBarParentViewDimen / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate(set) lazy var circularProgressBarView = CircularProgressBarView(frame: .zero)
    fileprivate var circularViewDuration: TimeInterval = 5

    
    
    fileprivate(set) lazy var startPauseTimerButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapStartPauseButton), for: .touchUpInside)
        return button
    }()
    
    
    // reset button
    fileprivate(set) lazy var resetTimerBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapResetTimerBtn), for: .touchUpInside)
        return button
    }()
    
    
    fileprivate(set) lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appMainColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var firstSessionLabel = createCircularLabel(text: "1")
    fileprivate lazy var secondSessionLabel = createCircularLabel(text: "2")
    fileprivate lazy var thirdSessionLabel = createCircularLabel(text: "3")
    fileprivate lazy var fourthSessionLabel = createCircularLabel(text: "4")

   
    
    
    //MARK: - Methods
    fileprivate func setUpInitalState() {
        circularProgressBarView.progressLayer.strokeColor = UIColor.appGrayColor.cgColor
        setUpFocusTimerMinutesLabel(color: .appGrayColor)
        configureStartPauseTimerButton(using: .inactive)
    }
    
    
    fileprivate func setUpViews() {
        
        // selectionTypeButton
        view.addSubview(currentModeButton)
        currentModeButton.centerXInSuperview()
        currentModeButton.constrainWidth(constant: 85)
        currentModeButton.constrainHeight(constant: 35)
        currentModeButton.layer.cornerRadius = 35 / 2
        currentModeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
   
        // currentTaskLabel
        view.addSubview(currentTaskLabel)
        NSLayoutConstraint.activate([
            currentTaskLabel.centerXAnchor.constraint(equalTo: currentModeButton.centerXAnchor),
            currentTaskLabel.topAnchor.constraint(equalTo: currentModeButton.bottomAnchor, constant: 40),
            currentTaskLabel.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.width),
            currentTaskLabel.heightAnchor.constraint(equalToConstant: currentTaskLabelHeight)
        ])
        
        
        // circularRingView
        view.addSubview(circularProgressBarParentView)
        NSLayoutConstraint.activate([
            circularProgressBarParentView.centerXAnchor.constraint(equalTo: currentModeButton.centerXAnchor),
            circularProgressBarParentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circularProgressBarParentView.widthAnchor.constraint(equalToConstant: circularProgressBarParentViewDimen),
            circularProgressBarParentView.heightAnchor.constraint(equalToConstant: circularProgressBarParentViewDimen)
        ])
        
        
        
        // timerLabel
        circularProgressBarParentView.addSubview(timerLabel)
        timerLabel.centerInSuperview()
        
        // startPauseButton
        view.addSubview(startPauseTimerButton)
        NSLayoutConstraint.activate([
            startPauseTimerButton.centerXAnchor.constraint(equalTo: currentModeButton.centerXAnchor),
            startPauseTimerButton.topAnchor.constraint(equalTo: circularProgressBarParentView.bottomAnchor, constant: 40),
            startPauseTimerButton.widthAnchor.constraint(equalToConstant: 75),
            startPauseTimerButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        
        // resetButton
        view.addSubview(resetTimerBtn)
        NSLayoutConstraint.activate([
            resetTimerBtn.centerXAnchor.constraint(equalTo: currentModeButton.centerXAnchor),
            resetTimerBtn.topAnchor.constraint(equalTo: startPauseTimerButton.bottomAnchor, constant: 15),
            
        ])
        
        
        
        // circles
        let stackView = UIStackView(arrangedSubviews: [firstSessionLabel, secondSessionLabel, thirdSessionLabel, fourthSessionLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: resetTimerBtn.bottomAnchor, constant: 15),
            stackView.centerXAnchor.constraint(equalTo: currentModeButton.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: startPauseTimerButton.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: startPauseTimerButton.trailingAnchor, constant: -5),
            stackView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        
        
        // taskButton
        let xAxisPadding: CGFloat = view.frame.width * 0.15
        let yAxisPadding: CGFloat = 30
        view.addSubview(taskButton)
        taskButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: xAxisPadding, bottom: yAxisPadding, right: 0), size: .init(width: taskButtonDimen, height: taskButtonDimen))
        
        
        
        // settingsButton
        view.addSubview(settingsButton)
        settingsButton.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: yAxisPadding, right: xAxisPadding), size: .init(width: taskButtonDimen, height: taskButtonDimen))
        

    }
    
    
    fileprivate func setUpFocusTimerMinutesLabel(color: UIColor) {
        let attributedText = NSMutableAttributedString(string: "\(focusDurationInMinutes)\n", attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 40, weight: .heavy)])
        
        attributedText.append(NSMutableAttributedString(string: "minutes", attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
        timerLabel.attributedText = attributedText
    }
    
    
    func setUpCircularProgressBarView() {
        // set view
        // align to the center of the screen
        circularProgressBarView.center = circularProgressBarParentView.center
        // call the animation with circularViewDuration
//        circularProgressBarView.progressAnimation(duration: circularViewDuration)
        // add this view to the view controller
        view.addSubview(circularProgressBarView)
    }
    
    
    
    fileprivate func createCircularLabel(text: String) -> UILabel {
        let label = UILabelWithInsets()
        label.textColor = .gray
        label.text = text
        label.textAlignment = .center
        label.textInsets = .init(top: 3, left: 3, bottom: 3, right: 3)
        label.font = UIFont.systemFont(ofSize: 8)
        label.layer.cornerRadius = 10 / 2
        label.layer.borderColor = UIColor.appMainColor.cgColor
        label.layer.borderWidth = 1
        label.constrainHeight(constant: 10)
        label.constrainWidth(constant: 10)
        return label
    }
    
    
    func configureStartPauseTimerButton(using status: TimerStatus) {
        switch status {
        case .active:
            
            changeButtonAppearance(with: TimerButtonTitle.pause, titleColor: .gray, backgroundColor: .appMilkyColor)

        case .onHold:

            changeButtonAppearance(with: TimerButtonTitle.resume, titleColor: .white, backgroundColor: .appMainColor)

        case .inactive:

            changeButtonAppearance(with: TimerButtonTitle.start, titleColor: .white, backgroundColor: .appMainColor)
        }
    }
    
    
    
   fileprivate func changeButtonAppearance(with title: String, titleColor: UIColor, backgroundColor: UIColor) {
        startPauseTimerButton.setTitle(title, for: .normal)
        startPauseTimerButton.setTitleColor(titleColor, for: .normal)
        startPauseTimerButton.backgroundColor = backgroundColor
    }

}





//MARK: - Actions
extension TimerVC {
    
    
    @objc fileprivate func didTapTasksButton() {
        let taskVC = TaskVC()
        let navVC = UINavigationController(rootViewController: taskVC)
        present(navVC, animated: true)
    }
    
    
    @objc fileprivate func didTapSettingsButton() {
        let settingsVC = SettingsVC()
        present(settingsVC, animated: true)
    }
    
    @objc fileprivate func didTapStartPauseButton() {
       handleStartPauseButtonActions(basedOn: currentTimerStatus)
    }
    
    
     func handleStartPauseButtonActions(basedOn currentTimerStatus: TimerStatus) {
        switch currentTimerStatus {
        case .active:
            pauseTimer()
        case .onHold, .inactive:
            startTimer()
        }
    }
    
    
    fileprivate func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeTicking), userInfo: nil, repeats: true)
        currentTimerStatus = .active
    }
    
    
    fileprivate func pauseTimer() {
        invalidateTimer()
        currentTimerStatus = .onHold
    }
    
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    @objc fileprivate func timeTicking() {
        elapsedTimeInSeconds += 1
        let duration = focusDurationInMinutes * minutesToSecondsMultiplier
        let progress = CGFloat(elapsedTimeInSeconds) / CGFloat(duration)
        circularProgressBarView.progressLayer.strokeEnd = 1 - progress
        if duration == elapsedTimeInSeconds {
            didTapResetTimerBtn()
            focusDurationInMinutes = shortRestDurationInMinutes
            circularProgressBarView.progressLayer.strokeColor = UIColor.appGrayColor.cgColor
            pomodoroSessionType = .shortBreak
        }

        print("progress: ", 1 - progress)
        print("elapsedTime: ", elapsedTimeInSeconds)
        
    }
    
    
    
    @objc fileprivate func didTapResetTimerBtn() {
        invalidateTimer()
        currentTimerStatus = .inactive
        elapsedTimeInSeconds = 0
        circularProgressBarView.progressLayer.strokeEnd = 1.0
    }

    
}


enum PomodoroSessionType {
    case work, shortBreak, longBreak
}

class UILabelWithInsets : UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
        
    }
}



