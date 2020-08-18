//
//  ViewController.swift
//  Multiple-Sections
//
//  Created by Brendon Cecilio on 8/18/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case grid
        case single
        // to do: add third section
        var columnCount: Int {
            switch self {
            case .grid:
                return 4
            case .single:
                return 1
            }
        }
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
    
    private var dataSource: DataSource!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
    
    private func configureCollectionView() {
        
        // override the default layout
        // collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout()) (IF DONE PROGRAMMATICALLY)
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
    }

    private func createLayout() -> UICollectionViewLayout {
        
        // let layout = UICollectionViewCompositionalLayout(section: section)
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // find out which section we are in
            guard let sectionType = Section(rawValue: sectionIndex) else {
                return nil
            }
            // return columns
            let columns = sectionType.columnCount
            
            // create layout: item -> group -> section -> layout
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            // create group: group -> section -> layout
            let groupHeight = columns == 1 ? NSCollectionLayoutDimension.absolute(200) : NSCollectionLayoutDimension.fractionalWidth(0.25)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            
            // create section: section -> layout
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return layout
    }
    
    private func configureDataSource() {
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
                fatalError("could not dequeue LabelCell")
            }
            cell.textLabel.text = "\(item)"
            
            if indexPath.section == 0 {
                cell.backgroundColor = .systemBlue
            } else {
                cell.backgroundColor = .systemOrange
            }
            
            cell.layer.cornerRadius = 12
            return cell
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
                fatalError("could not dequeue view HeaderView")
            }
            headerView.textLabel.text = "\(Section.allCases[indexPath.section])"
            return headerView
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.grid, .single])
        snapshot.appendItems(Array(1...12), toSection: .grid)
        snapshot.appendItems(Array(13...24), toSection: .single)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

