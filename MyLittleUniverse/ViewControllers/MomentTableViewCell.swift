//
//  MomentTableViewCell.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/01/06.
//

import UIKit
import RxSwift

class MomentTableViewCell: UITableViewCell {
    static let identifier = "momentCell"
    
    let onData: AnyObserver<Moment>
    var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        let data = PublishSubject<Moment>()
        
        onData = data.asObserver()
        
        super.init(coder: coder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] moment in
                self?.lblDescription.text = moment.description
                self?.lblDate.text = "\(moment.date)"
                self?.lblStatus.text = moment.status.rawValue
                if let frame = self?.frame {
                    let imageView = UIImageView(frame: frame)
                    imageView.image = UIImage(named: moment.image)
                    self?.backgroundView = UIView()
                    self?.backgroundView?.addSubview(imageView)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
}
