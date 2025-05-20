import Foundation
import SwiftUI
import Combine

final class TargetEditViewModel: ObservableObject {
    // MARK: - Свойства
    
    /// Заголовок цели, используемый для привязки к полю ввода.
    @Published var targetTitle: String = ""
    /// Описание цели, отображаемое в текстовом редакторе.
    @Published var targetDescription: String = ""
    /// Выбранная категория цели.
    @Published var targetCategory: TargetCategory = .personal
    /// Дата дедлайна основной цели.
    @Published var targetDeadline: Date = Date().addingTimeInterval(86400 * 7)
    
    /// Список моделей подцелей, прикреплённых к основной цели.
    @Published var subTargets: [SubTargetFormModel] = []
    
    // MARK: - Валидационные сообщения
    /// Сообщение об ошибке в названии цели.
    @Published var titleError: String? = nil
    /// Сообщение об ошибке в описании цели.
    @Published var descriptionError: String? = nil
    /// Сообщение об ошибке в дедлайне цели.
    @Published var deadlineError: String? = nil
    
    // MARK: - Состояние формы
    /// Флаг валидности формы (true, если все поля корректны).
    @Published var isFormValid: Bool = false
    
    // MARK: - Приватные свойства
    /// Подписки Combine для отслеживания изменений полей и валидации.
    private var cancellables = Set<AnyCancellable>()
    /// Исходная модель цели для режима редактирования.
    private var originalTarget: UserTargetDtoModel?
    /// Флаг: true при создании новой цели, false при редактировании.
    var isCreateTarget: Bool = true
    /// Флаг, указывающий, что в данный момент происходит программное обновление подцелей
    private var isUpdatingSubTargets = false
    
    // MARK: - Инициализация
    /// Инициализирует ViewModel с опциональной существующей целью и режимом создания.
    /// - Parameters:
    ///   - target: Существующая модель UserTargetDtoModel для редактирования или nil для создания новой.
    ///   - isCreateTarget: true при создании новой цели, false при редактировании.
    init(target: UserTargetDtoModel? = nil, isCreateTarget: Bool = true) {
        self.isCreateTarget = isCreateTarget
        self.originalTarget = target
        
        if let target = target {
            self.targetTitle = target.title.orEmpty
            self.targetDescription = target.description.orEmpty
            self.targetCategory = target.category.orDefault(.personal)
            
            if let deadlineString = target.deadLineDateTime,
               let deadlineDate = deadlineString.dateFromApiString {
                self.targetDeadline = deadlineDate
            }
            
            if let subTargets = target.subTargets {
                self.subTargets = subTargets.map { subTarget in
                    SubTargetFormModel(
                        id: UUID().uuidString,
                        model: subTarget, 
                        titleError: nil,
                        descriptionError: nil,
                        deadlineError: nil
                    )
                }
            }
        }
        
        setupValidation()
        // Выполняем первичную валидацию после инициализации
        validateTarget()
        validateSubTargets()
        validateForm()
    }
    
    // MARK: - Настройка валидации
    /// Подписывается на изменения полей и запускает валидацию основной цели и подцелей.
    private func setupValidation() {
        // Подписываемся на изменения полей для валидации основной цели
        Publishers.CombineLatest3(
            $targetTitle,
            $targetDescription,
            $targetDeadline
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] _, _, _ in
            self?.validateTarget()
            self?.validateForm()
        }
        .store(in: &cancellables)
        
        // Подписка на структурные изменения массива подцелей (добавление/удаление)
        $subTargets
            .dropFirst() // Пропускаем первоначальное значение
			.removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self, !self.isUpdatingSubTargets else { return }
				isUpdatingSubTargets = true
                self.validateSubTargets()
                self.validateForm()
				isUpdatingSubTargets = false
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Validation
    /// Выполняет проверку названия, длины описания и дедлайна основной цели.
    /// Устанавливает сообщения об ошибках для некорректных полей.
    func validateTarget() {
        // Валидация названия
        if targetTitle.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
            titleError = "Название не может быть менее 3 символов"
        } else {
            titleError = nil
        }
        
        // Валидация описания
        if targetDescription.count > 200 {
            descriptionError = "Описание не должно превышать 200 символов"
        } else {
            descriptionError = nil
        }
        
        // Валидация даты
//		if targetDeadline.endOfDay < Date() {
//            deadlineError = "Дата не может быть раньше текущей"
//        } else {
            deadlineError = nil
//        }
    }
    
    /// Выполняет проверку названия, длины описания и дедлайна каждой подцели относительно основной цели.
    /// Устанавливает сообщения об ошибках для некорректных полей подцелей.
	func validateSubTargets() {
		guard !subTargets.isEmpty else { return }
		
		// Создаем копию для валидации
		var validatedSubTargets = subTargets
		
		let targetDateDay = Calendar.current.startOfDay(for: targetDeadline)
		let today = Calendar.current.startOfDay(for: Date())
		
		for index in validatedSubTargets.indices {
			// Валидация названия
			if validatedSubTargets[index].title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				validatedSubTargets[index].titleError = "Название не может быть пустым"
			} else {
				validatedSubTargets[index].titleError = nil
			}
			
			// Валидация описания
			if validatedSubTargets[index].description.count > 200 {
				validatedSubTargets[index].descriptionError = "Описание не должно превышать 200 символов"
			} else {
				validatedSubTargets[index].descriptionError = nil
			}
			
			// Валидация даты
			let subtargetDateDay = Calendar.current.startOfDay(for: validatedSubTargets[index].deadline)
			
			if subtargetDateDay > targetDateDay {
				validatedSubTargets[index].deadlineError = "Дата подцели не может быть позже основной цели"
//			} else if subtargetDateDay < today {
//				validatedSubTargets[index].deadlineError = "Дата не может быть раньше текущей"
			} else {
				validatedSubTargets[index].deadlineError = nil
			}
		}
		
		// Обновляем все подцели одним присваиванием
		subTargets = validatedSubTargets
		
	}
    
    /// Обновляет общий флаг валидности формы (`isFormValid`) на основании результатов валидации всех полей.
    private func validateForm() {
        let isTargetValid = titleError == nil && descriptionError == nil && deadlineError == nil
        
        let areSubTargetsValid = subTargets.allSatisfy { subTarget in
            subTarget.titleError == nil && 
            subTarget.descriptionError == nil && 
            subTarget.deadlineError == nil
        }
        
        // Проверяем, что название заполнено
        let isTitleFilled = !targetTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Проверяем, что подцели имеют заполненные названия
        let areSubTargetsFilled = subTargets.isEmpty || subTargets.allSatisfy { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        isFormValid = isTargetValid && areSubTargetsValid && isTitleFilled && areSubTargetsFilled
    }
    
    // MARK: - Actions
    /// Добавляет новую подцель с дедлайном в конец дня основной цели и выполняет валидацию.
    func addNewSubTarget() {
		let targetEndOfDay = targetDeadline.endOfDay
        let newSubTarget = SubTargetFormModel(
            id: UUID().uuidString,
            title: "",
            description: "",
            deadline: targetEndOfDay
        )
        
        subTargets.append(newSubTarget)
    }
    
    /// Удаляет подцель по указанному индексу и обновляет состояние валидности формы.
    /// - Parameter index: Индекс удаляемой подцели.
    func removeSubTarget(at index: Int) {
        guard index < subTargets.count else { return }
        subTargets.remove(at: index)
    }
    
    // MARK: - Data Conversion
    /// Формирует UserTargetDtoModel на основе данных формы, обрезая пробелы и форматируя дедлайны.
    /// - Returns: Модель UserTargetDtoModel для сохранения или отправки.
    func createTargetModel() -> UserTargetDtoModel {
        // Равномерное распределение процентов между подцелями
		var subTargetModels = subTargets.isEmpty ? nil : subTargets.map { subTarget -> UserSubTargetDtoModel in
            var model = subTarget.toSubTargetModel(rootTargetId: originalTarget?.id)
            model.subTargetPercentage = subTargets.isEmpty ? 0 : 100.0 / Double(subTargets.count)
            return model
        }
		
		let newIds = subTargetModels?.compactMap(\.id) ?? []
        let oldIds = originalTarget?.subTargets?.compactMap(\.id) ?? []
		let deletedIds = oldIds.filter { !newIds.contains($0) }
		for id in deletedIds {
			if var deletedModel = originalTarget?.subTargets?.first(where: { $0.id == id }) {
				deletedModel.isDeleted = true
				subTargetModels?.append(deletedModel)
			}
		}
		
        return UserTargetDtoModel(
            id: originalTarget?.id,
            title: targetTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: targetDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            userExternalId: UserRepository.shared.externalId,
            percentage: originalTarget?.percentage ?? 0,
			deadLineDateTime: targetDeadline.endOfDay.toApiString,
            streamId: originalTarget?.streamId,
            targetStatus: originalTarget?.targetStatus ?? .draft,
            subTargets: subTargetModels,
            isDeleted: originalTarget?.isDeleted,
            creationDateTime: originalTarget?.creationDateTime,
            lastUpdatingDateTime: originalTarget?.lastUpdatingDateTime,
            category: targetCategory
        )
    }
}

