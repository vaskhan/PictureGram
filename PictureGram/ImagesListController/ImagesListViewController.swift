//
//  ViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 19.12.2024.
//

import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func reloadTableAnimated(oldCount: Int, newCount: Int)
    func showLikeErrorAlert()
    func reloadRow(at index: Int)
}

final class ImagesListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!

    // MARK: - Properties
    private var presenter: ImagesListPresenterProtocol!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        tableView.delegate = self
        tableView.dataSource = self

        presenter.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleImage",
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {

            let photo = presenter.photo(at: indexPath.row)
            viewController.imageURL = photo.fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Injection
    func setPresenter(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
    }
    
    func reloadRow(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ImagesListViewController: ImagesListViewProtocol {

    func reloadTableAnimated(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else { return }

        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось поставить лайк.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photosCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        let photo = presenter.photo(at: indexPath.row)
        cell.configure(with: photo)
        cell.delegate = self

        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath.row)
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath.row)
        let tableWidth = tableView.bounds.width - tableView.layoutMargins.left - tableView.layoutMargins.right
        return (photo.size.height / photo.size.width) * tableWidth + 8
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayRow(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath.row)
    }
}
