//
//  ViewController.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Combine
import UIKit

final class LineupViewController: UIViewController {
    
    // MARK: - Collection View Data Source
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ActViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ActViewModel>
    
    struct Section: Hashable {
        let title: String
    }
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(
            collectionView: collectionView) { collectionView, indexPath, act in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActCell.reuseIdentifier, for: indexPath) as? ActCell
                else {
                    fatalError("Failed to dequeue cell")
                }
                cell.configure(with: act)
                return cell
            }
        return dataSource
    }()
    
    // MARK: - Views
    
    private lazy var segmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Day 1", "Day 2"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged), for: .valueChanged)
        
        return segmentedControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.itemSize = CGSize(width: view.bounds.width, height: 80.0)
        collectionViewFlowLayout.minimumLineSpacing = 20
        collectionViewFlowLayout.headerReferenceSize = CGSize(width: view.bounds.width, height: 60.0)
        collectionViewFlowLayout.sectionHeadersPinToVisibleBounds = true
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        
        return collectionView
    }()
    
    // MARK: -
    
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: LineupViewModel
    
    // MARK: - Initialization
    
    init(viewModel: LineupViewModel = LineupViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setDefaultDay()
    }
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        viewModel.$acts
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
    }
    
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        setupSegmentedControl()
        setupCollectionView()
    }
    
    private func setupSegmentedControl() {
        self.view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }
    
    @objc private func segmentedControlValueChanged() {
        viewModel.day = segmentedControl.selectedSegmentIndex
        applySnapshot()
    }
    
    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        collectionView.register(ActCell.self, forCellWithReuseIdentifier: ActCell.reuseIdentifier)
        collectionView.register(ActSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ActSectionHeaderView.reuseIdentifier)
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ActSectionHeaderView.reuseIdentifier, for: indexPath) as? ActSectionHeaderView
                
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                sectionHeaderView?.titleLabel.text = section.title
                
                return sectionHeaderView
            } else {
                return nil
            }
        }
        
        collectionView.dataSource = dataSource
    }
    
    private func applySnapshot(animatingDifferences: Bool = false) {
        let acts = viewModel.acts
        var snapshot = Snapshot()
        let locations = Set(acts.map { $0.location })
        
        for location in locations {
            snapshot.appendSections([Section(title: location)])
            let actsForLocation = acts.filter { $0.location == location }
            snapshot.appendItems(actsForLocation, toSection: Section(title: location))
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

}
