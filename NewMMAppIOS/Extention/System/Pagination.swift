//
//  Pagination.swift
//  NewMMAppIOS
//
//  Created by artem on 12.04.2025.
//

typealias PaginationQury = [String: String]

protocol PaginationProtocol {
    associatedtype TypeItem
    var results: [TypeItem]? { get }
    var totalPages: Int? { get }
    var pageNumber: Int? { get }
    var pageSize: Int? { get }
}

extension PaginationProtocol {
    /// Получить конфигурацию для следующей пагинации
    var nextPagination: [String: String] {
        [
            PaginationConstants.pageNumberKey: String(pageNumber.orZero + 1),
            PaginationConstants.pageSizeKey: String(pageSize.orZero)
        ]
    }

    /// Были загружены все страницы
    var isAll: Bool {
        // Количество отображенных страниц
        let countPage = pageNumber.orZero + 1
        return totalPages.orZero <= countPage
    }
}

enum PaginationConstants {
    static let pageNumberKey = "pageNumber"
    static let pageSizeKey = "pageSize"
}
