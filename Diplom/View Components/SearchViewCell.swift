//
//  SearchCell.swift
//  Diplom
//
//  Created by ryan on 08.12.2021.
//

import UIKit

class SearchViewCell: UICollectionViewCell {

    var appResult: Results! {
        didSet {
            setupData()
        }
    }

    func setupData() {
        print("Download Started")
        guard let movies = appResult else { return }
        nameLabel.text = movies.title
        ratingLabel.text = movies.vote_average.toString()
        dateLabel.text = movies.release_date

        if let url = URL(string: "https://image.tmdb.org/t/p/original\((movies.poster_path) )") {

            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                DispatchQueue.main.async() { [weak self] in
                    self!.imagePath.image = UIImage(data: data)
                }
            }
        }

        nameLabel.text = movies.title
        ratingLabel.text = movies.vote_average.toString()
        dateLabel.text = movies.release_date

    }

    let imagePath: UIImageView = {
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.widthAnchor.constraint(equalToConstant: 150).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 300).isActive = true
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())

    let nameLabel: UILabel = {
        $0.text = "APP MOVIE"
        return $0
    }(UILabel())

    let ratingLabel: UILabel = {
        $0.text = "9.26M"
        $0.font = .boldSystemFont(ofSize: 15)
        $0.textColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        return $0
    }(UILabel())

    let imageIcon: UIImageView = {
        $0.image = UIImage(systemName: "star.fill")
        $0.tintColor = #colorLiteral(red: 1, green: 0.9022858502, blue: 0, alpha: 1)
        return $0
    }(UIImageView())

    let dateLabel: UILabel = {
        $0.text = "2019-08-2021"
        $0.font = .boldSystemFont(ofSize: 15)
        $0.textColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        return $0
    }(UILabel())

    let getWhatchButton: UIButton = {
        $0.setTitle("WatchList", for: .normal)
        $0.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 32).isActive = true
        $0.layer.cornerRadius = 16
        return $0
    }(UIButton(type: .system))

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackLabelStart = UIStackView(arrangedSubviews: [imageIcon,ratingLabel])
        stackLabelStart.spacing = 5

        let labelStackViewDescription = UIStackView(arrangedSubviews: [stackLabelStart,dateLabel])

        labelStackViewDescription.axis = .horizontal
        labelStackViewDescription.alignment = .center
        labelStackViewDescription.spacing = 10

        let labelStackView = UIStackView(arrangedSubviews: [
            nameLabel, labelStackViewDescription ,getWhatchButton
        ])

        labelStackView.axis = .vertical
        labelStackView.alignment = .center
        labelStackView.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [imagePath, labelStackView])

        stackView.spacing = 20
        stackView.alignment = .center

        addSubview(stackView)

        stackView.fillSuperview(padding: .init(top: 15, left: 15, bottom: 15, right: 15))

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UICollectionViewCell {
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

extension Float {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

