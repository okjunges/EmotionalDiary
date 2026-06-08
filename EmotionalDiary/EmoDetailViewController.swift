//
//  EmoDetailViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class EmoDetailViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var emotionCardView: UIView!
    @IBOutlet weak var socialContextCardView: UIView!
    @IBOutlet weak var situationCardView: UIView!
    @IBOutlet weak var energyCardView: UIView!
    @IBOutlet weak var memoCardView: UIView!
    
    @IBOutlet weak var emotionImageView: UIImageView!
    @IBOutlet weak var emotionTitleLabel: UILabel!
    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var intensityProgressView: UIProgressView!
    
    @IBOutlet weak var socialContextLabel: UILabel!
    @IBOutlet weak var situationLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoEditButton: UIButton!
    
    var record: EmotionRecord?
    var selectedDate: Date?
    
    private var isMemoEditing = false
    private let emptyMemoText = "저장된 내용이 없습니다...\n'수정' 버튼을 눌러 그 상황을 기록해주세요!"
    private var originalViewY: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        originalViewY = view.frame.origin.y
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(named: "TextColor")!
        ]
    
        setupTapGesture()
        setupUI()
        configureData()
        setupKeyboardObservers()
        setupBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func setupUI() {
        let cardViews = [
            emotionCardView,
            socialContextCardView,
            situationCardView,
            energyCardView,
            memoCardView
        ]
        
        cardViews.forEach { view in
            view?.layer.cornerRadius = 15
            view?.clipsToBounds = true
        }
        
        intensityProgressView.transform = CGAffineTransform(scaleX: 1, y: 5)
        intensityProgressView.layer.cornerRadius = 4
        intensityProgressView.clipsToBounds = true
        
        memoTextView.delegate = self
        memoTextView.isEditable = false
        memoTextView.isScrollEnabled = true
        memoTextView.layer.cornerRadius = 10
        memoTextView.backgroundColor = .clear

        memoEditButton.setTitle("수정", for: .normal)
        memoEditButton.tintColor = UIColor(named: "LightTextColor")
        isMemoEditing = false
    }
    
    private func configureData() {
        guard let record = record else { return }
        
        if let selectedDate = selectedDate {
            navigationItem.title = "\(selectedDate.toKoreanTitleString()) \(record.timeSlot.saveTitle)"
        }
        
        emotionImageView.image = UIImage(named: record.emotion.imageName)
        emotionTitleLabel.text = record.emotion.title
        
        intensityLabel.text = "강도 \(record.intensity)/5"
        intensityProgressView.progress = Float(record.intensity) / 5.0
        
        socialContextLabel.text = record.socialContext.title
        situationLabel.text = record.situation.rawValue
        energyLabel.text = record.energy.title
        
        if record.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            memoTextView.text = emptyMemoText
            memoTextView.textColor = .lightGray
        } else {
            memoTextView.text = record.memo
            memoTextView.textColor = UIColor(named: "TextColor") ?? .darkGray
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @IBAction func memoEditButtonTapped(_ sender: UIButton) {
        if isMemoEditing {
            saveMemo()
        } else {
            startMemoEditing()
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "감정 기록 삭제",
            message: "이 기록을 정말로 삭제하시겠습니까?\n삭제한 기록은 복구할 수 없습니다.",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )

        let deleteAction = UIAlertAction(
            title: "삭제",
            style: .destructive
        ) { [weak self] _ in
            self?.deleteEmotionRecord()
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(alert, animated: true)
    }
    
    private func startMemoEditing() {
        isMemoEditing = true
        memoEditButton.setTitle("저장", for: .normal)
        memoEditButton.tintColor = UIColor(named: "PointBtnColor")

        if memoTextView.text == emptyMemoText {
            memoTextView.text = ""
            memoTextView.textColor = UIColor(named: "TextColor") ?? .darkGray
        }

        memoTextView.isEditable = true
        memoTextView.becomeFirstResponder()
    }

    private func saveMemo() {
        guard let recordId = record?.id else {
            print("수정할 기록 ID가 없습니다.")
            return
        }

        let newMemo = memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        FirestoreService.shared.updateEmotionRecordMemo(
            recordId: recordId,
            memo: newMemo
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isMemoEditing = false
                    self?.memoEditButton.setTitle("수정", for: .normal)
                    self?.memoEditButton.tintColor = UIColor(named: "LightTextColor")
                    self?.memoTextView.isEditable = false
                    self?.memoTextView.resignFirstResponder()
                    self?.view.frame.origin.y = self?.originalViewY ?? 0

                    if newMemo.isEmpty {
                        self?.memoTextView.text = self?.emptyMemoText
                        self?.memoTextView.textColor = .lightGray

                    } else {
                        self?.memoTextView.text = newMemo
                        self?.memoTextView.textColor = UIColor(named: "TextColor") ?? .darkGray
                    }

                case .failure(let error):
                    print("메모 수정 실패:", error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteEmotionRecord() {
        guard let recordId = record?.id else {
            print("삭제할 기록 ID가 없습니다.")
            return
        }

        FirestoreService.shared.deleteEmotionRecord(recordId: recordId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print("삭제 실패:", error.localizedDescription)
                }
            }
        }
    }
    
    private func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func showUnsavedMemoAlert() {
        let alert = UIAlertController(
            title: "수정 내용이 저장되지 않았습니다",
            message: "'저장' 버튼을 누르지 않으면 수정한 내용이 저장되지 않습니다.",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(
            title: "계속 수정하기",
            style: .cancel
        )

        let backAction = UIAlertAction(
            title: "저장하지 않고 나가기",
            style: .destructive
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        alert.addAction(cancelAction)
        alert.addAction(backAction)

        present(alert, animated: true)
    }

    @objc private func backButtonTapped() {
        if isMemoEditing {
            showUnsavedMemoAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard isMemoEditing,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        let textViewFrame = memoTextView.convert(memoTextView.bounds, to: view)
        let textViewBottomY = textViewFrame.maxY

        let keyboardTopY = view.bounds.height - keyboardFrame.height
        let padding: CGFloat = 20

        if textViewBottomY > keyboardTopY - padding {
            let moveY = textViewBottomY - keyboardTopY + padding
            view.frame.origin.y = originalViewY - moveY
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = originalViewY
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // ------------------------------------------------------
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 150 {
            textView.text = String(textView.text.prefix(150))
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = UIColor(named: "TextColor") ?? .darkGray
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer && isMemoEditing {
                showUnsavedMemoAlert()
                return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}
