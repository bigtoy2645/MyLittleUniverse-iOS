//
//  MomentTableViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import UIKit
import RxSwift

class MomentTableViewCell: UITableViewCell {
    static let nibName = "MomentTableViewCell"
    static let identifier = "momentCell"
    
    var moment: ViewMoment
    private var disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 30, bottom: 15, right: 30))
        contentView.layer.cornerRadius = 10
        
        setupBindings()
    }

    required init?(coder aDecoder: NSCoder) {
        moment = ViewMoment(Moment.empty)
        super.init(coder: aDecoder)
    }
    
    /* Binding */
    func setupBindings() {
        let moment = Observable.just(self.moment)
        
        moment.map { $0.image }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                if let frame = self?.frame {
                    let imageView = UIImageView(frame: frame)
                    imageView.image = image
                    self?.backgroundView = UIView()
                    self?.backgroundView?.addSubview(imageView)
                }
            })
            .disposed(by: disposeBag)
        
        moment.map { $0.text }
            .asObservable()
            .bind(to: lblDescription.rx.text)
            .disposed(by: disposeBag)
        
        moment.map { $0.date }
            .bind(to: lblDate.rx.text)
            .disposed(by: disposeBag)
        
        moment.map { $0.emotion }
            .bind(to: lblEmotion.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblEmotion: UILabel!
}
