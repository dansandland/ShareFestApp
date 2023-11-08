//
//  ActCell.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import UIKit

final class ActCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: ActCell.self)
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.layer.cornerRadius = 35.0
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14.0, weight: .black)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14.0, weight: .thin)
        return label
    }()
    
    private lazy var artistInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .gray
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, artistInfoLabel])
        view.distribution = .fillEqually
        view.axis = .vertical
        view.spacing = 1.0
        return view
    }()
    
    private lazy var outerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageView, labelStackView])
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = 10
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContentView() {
        contentView.addSubview(outerStackView)
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            outerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            outerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            outerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            outerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    func configure(with act: ActViewModel) {
        titleLabel.text = act.name
        subtitleLabel.text = DateFormatter.actDate(fromDate: act.startDate, toDate: act.endDate)
        artistInfoLabel.text = act.artistInfo
        
        // Configure Image
        imageView.image = nil
        if let imageUrlString = act.artistImageUrl, let imageUrl = URL(string: imageUrlString) {
            Task {
                do {
                    let image = try await ImageCache.shared.loadImage(from: imageUrl)
                    DispatchQueue.main.async { [weak self] in
                        self?.imageView.image = image
                    }
                } catch {
                    print("Error fetching image:", error)
                }
            }
        }
    }
}
