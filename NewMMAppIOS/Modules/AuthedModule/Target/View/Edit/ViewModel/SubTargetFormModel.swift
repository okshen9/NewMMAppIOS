//
//  SubTargetFormModel.swift
//  NewMMAppIOS
//
//  Created by artem on 02.05.2025.
//

import SwiftUI
import Foundation

/// Модель формы подцели с данными и сообщениями об ошибках.
struct SubTargetFormModel: Identifiable, Equatable {
    let id: String
	let originalModel: UserSubTargetDtoModel?
    var title: String = ""
    var description: String = ""
	var deadline: Date = Date().endOfDay
	var isDeleted: Bool = false
    
    var titleError: String? = nil
    var descriptionError: String? = nil
    var deadlineError: String? = nil
    
    /// Инициализирует пустую модель подцели с опциональными сообщениями об ошибках.
    /// - Parameters:
    ///   - id: Уникальный идентификатор подцели.
    ///   - title: Начальное название.
    ///   - description: Начальное описание.
    ///   - deadline: Начальный дедлайн.
    ///   - titleError: Сообщение об ошибке названия (при наличии).
    ///   - descriptionError: Сообщение об ошибке описания (при наличии).
    ///   - deadlineError: Сообщение об ошибке дедлайна (при наличии).
	init(id: String, title: String = "", description: String = "", deadline: Date = Date().endOfDay, titleError: String? = nil, descriptionError: String? = nil, deadlineError: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
		self.deadline = deadline.endOfDay
        self.titleError = titleError
        self.descriptionError = descriptionError
        self.deadlineError = deadlineError
		self.originalModel = nil
    }
    
    /// Инициализирует модель подцели из существующего UserSubTargetDtoModel.
    /// - Parameters:
    ///   - id: Уникальный идентификатор экземпляра формы.
    ///   - model: Исходная модель UserSubTargetDtoModel для копирования.
    ///   - titleError: Сообщение об ошибке названия (при наличии).
    ///   - descriptionError: Сообщение об ошибке описания (при наличии).
    ///   - deadlineError: Сообщение об ошибке дедлайна (при наличии).
    init(id: String, model: UserSubTargetDtoModel, titleError: String? = nil, descriptionError: String? = nil, deadlineError: String? = nil) {
        self.id = id
		self.originalModel = model
        self.title = model.title.orEmpty
        self.description = model.description.orEmpty
        
        if let deadlineString = model.deadLineDateTime,
           let deadlineDate = deadlineString.dateFromApiString {
            self.deadline = deadlineDate.endOfDay
        } else {
			self.deadline = Date().endOfDay
        }
        
        self.titleError = titleError
        self.descriptionError = descriptionError
        self.deadlineError = deadlineError
    }
    
    /// Преобразует модель формы обратно в UserSubTargetDtoModel для сохранения, обрезая пробелы и форматируя дедлайн.
    /// - Parameter rootTargetId: Идентификатор родительской цели.
    /// - Returns: UserSubTargetDtoModel, заполнённый данными формы.
    func toSubTargetModel(rootTargetId: Int?) -> UserSubTargetDtoModel {
        UserSubTargetDtoModel(
			id: originalModel?.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            subTargetPercentage: 0.0,
			targetSubStatus: originalModel?.targetStatus ?? .notDone,
            rootTargetId: rootTargetId,
			isDeleted: originalModel?.isDeleted,
			creationDateTime: originalModel?.creationDateTime ?? Date.now.toApiString,
            lastUpdatingDateTime: Date.now.toApiString,
			deadLineDateTime: deadline.endOfDay.toApiString
        )
    }
	
	static func == (lhs: SubTargetFormModel, rhs: SubTargetFormModel) -> Bool {
		return lhs.title == rhs.title
		&& lhs.description == rhs.description
		&& lhs.deadline == rhs.deadline
		&& lhs.id  == rhs.id
		
	}
}
