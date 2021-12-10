//
//  CastCell.swift
//  Diplom
//
//  Created by ryan on 25.11.2021.
//

import UIKit

class CastCell: UICollectionViewCell {

    var cast: Cast? {
        didSet {
            titleLabel.text = cast?.name

            if let baseUrl = TMDBNetwork.shared.configuration?.images.secureBaseUrl {
                let imageUrl = "\(baseUrl)w500\(cast?.profilePath ?? "")"

                posterView.loadImage(urlString: imageUrl, alias: cast?.profilePath ?? "",completion: nil)
            }
        }
    }

    static let cellId = "castCell"

    private let titleLabel: UILabel = {
        $0.text = "Movie Title"
        $0.font = .boldSystemFont(ofSize: 13)
        $0.numberOfLines = 2
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())

    private let posterView = CachedImageView(cornerRadius: 6, emptyImage: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        let labelWrapper = UIView(frame: titleLabel.frame)
        labelWrapper.constrainHeight(constant: 36)
        labelWrapper.addSubview(titleLabel)

        titleLabel.anchor(top: labelWrapper.topAnchor, leading: labelWrapper.leadingAnchor, bottom: nil, trailing: labelWrapper.trailingAnchor)

        let stackView = UIStackView(arrangedSubviews: [posterView, labelWrapper])
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.alignment = .top

        addSubview(stackView)
        stackView.fillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

