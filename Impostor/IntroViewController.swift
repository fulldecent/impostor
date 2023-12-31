//
//  IntroViewController.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//  Copyright © 2023 William Entriken. All rights reserved.
//

import UIKit
import CenteredCollectionView

struct IntroPage {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: UIColor
}

class IntroViewController: UIViewController {
    let introPages = [
        IntroPage(title: NSLocalizedString("A party game", comment: "Intro screen 1 title"),
                  description: NSLocalizedString("For 3 to 12 players", comment: "Intro screen 1 detail"),
                  imageName: "help1",
                  backgroundColor: UIColor.gray),

        IntroPage(title: NSLocalizedString("Everyone sees their secret word", comment: "Intro screen 2 title"),
                  description: NSLocalizedString("But the impostor's word is different", comment: "Intro screen 2 detail"),
                  imageName: "help2",
                  backgroundColor: UIColor.gray),

        IntroPage(title: NSLocalizedString("Each round players describe their word", comment: "Intro screen 3 title"),
                  description: NSLocalizedString("then vote to eliminate one player (can't use word to describe itself or repeat other players, break ties with a revote)", comment: "Intro screen 3 detail"),
                  imageName: "help3",
                  backgroundColor: UIColor.gray),

        IntroPage(title: NSLocalizedString("To win", comment: "Intro screen 4 title"),
                  description: NSLocalizedString("the impostor must survive with one other player", comment: "Intro screen 4 detail"),
                  imageName: "help4",
                  backgroundColor: UIColor.gray)
    ]

    
    let centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
    let collectionView: UICollectionView

    let cellPercentWidth: CGFloat = 0.7
    var scrollToEdgeEnabled = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        collectionView = UICollectionView(centeredCollectionViewFlowLayout: centeredCollectionViewFlowLayout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CenteredCollectionView"

        // Just to make the example pretty ✨
        collectionView.backgroundColor = UIColor.clear

        // delegate & data source
        collectionView.delegate = self
        collectionView.dataSource = self

        // layout subviews
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(collectionView)
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        // register collection cells
        collectionView.register(
            ProgrammaticCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: ProgrammaticCollectionViewCell.self)
        )

        // configure layout
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * cellPercentWidth,
            height: view.bounds.height * cellPercentWidth * cellPercentWidth
        )
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
}

extension IntroViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true)
        print("Selected Cell #\(indexPath.row)")
        if scrollToEdgeEnabled,
            let currentCenteredPage = centeredCollectionViewFlowLayout.currentCenteredPage,
            currentCenteredPage != indexPath.row {
            centeredCollectionViewFlowLayout.scrollToPage(index: indexPath.row, animated: true)
        }
    }
}

extension IntroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return introPages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProgrammaticCollectionViewCell.self), for: indexPath) as! ProgrammaticCollectionViewCell

        let page = introPages[indexPath.row]
        cell.titleLabel.text = page.title
        cell.descriptionLabel.text = page.description
        cell.imageView.image = UIImage(named: page.imageName)
        cell.mainView.backgroundColor = page.backgroundColor

        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }
}

class ProgrammaticCollectionViewCell: UICollectionViewCell {

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()
    let mainView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Subview configuration
        mainView.backgroundColor = UIColor.white
        mainView.layer.cornerRadius = 3

        titleLabel.textAlignment = .left
        descriptionLabel.textAlignment = .left

        // ImageView configuration
        imageView.contentMode = .scaleAspectFit

        // Prepare subviews for layout
        contentView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false

        mainView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        mainView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        mainView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        mainView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        // Activate constraints
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: mainView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: mainView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: mainView.layoutMarginsGuide.topAnchor),

            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: mainView.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: mainView.layoutMarginsGuide.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.5),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: mainView.layoutMarginsGuide.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: mainView.layoutMarginsGuide.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: mainView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
