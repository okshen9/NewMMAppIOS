//
//  TargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

protocol TargetRowViewModelProtocol: ObservableObject {
    /// Закрыть цель
    func closedTarget(target: UserTargetDtoModel)
    /// удлить цель
    func deleteTarget(target: UserTargetDtoModel)
    /// Состояние для диалога подтверждения закрытия
    var showDiscardChangesAlert: Bool { get set }
}

struct TargetRowView<ViewModel: TargetRowViewModelProtocol>: View {
	@EnvironmentObject private var viewModelEnvironment: ViewModel
	
	var myTarget = true
	/// Отображаемый таргет
	var target: UserTargetDtoModel
	
	init(myTarget: Bool = true, target: UserTargetDtoModel) {
		self.myTarget = myTarget
		self.target = target
	}
	
	/// Показать диалоговое окошко закрытии/открытие задачи
	@State private var showCloseTaskDialog = false
	/// Показать диалоговое окошко закрытии/открытие задачи
	@State private var showDeleteTaskDialog = false
	/// Показать модалку по лонгтапу
	@State private var showLongTapDialog = false
	/// Показать модалку по лонгтапу
	@State private var isPressed = false
	/// Свернуть/развернуть цель
	@State private var isExpanded: Bool = false
	/// переход на экаран редактирования
	@State private var isEditing: Bool = false
	/// Показать алерт закрытия экрана редактирования
	@State private var showDismissEditAlert: Bool = false
	/// Меняется статус цели
	@State private var isLoading = false
	/// Показать описание
	@State private var showDescription: Bool = false
	/// Показать инструкцию для статусов целей
	@State private var showHelpStatusTooltip = false
	/// Показать инструкцию для статусов целей
	@State private var showHelpModerationStatusTooltip = false
	
	@State private var showHelpStatusTooltip2 = false
	
	private let categoryIndicatorSize: CGFloat = 36
	
	// MARK: - Body
	var body: some View {
		mainContentView
			.padding(12)
			.background(Color(.systemBackground))
			.onChange(of: target, {
				isLoading = false
			})
			.scaleEffect(isPressed ? 0.98 : 1.0)
			.animation(.easeInOut(duration: 0.2), value: isPressed)
			.onTapGesture {
				withAnimation(.spring(response: 0.1, dampingFraction: 3.8)) {
					showDescription.toggle()
					isExpanded.toggle()
				}
			}
			.onLongPressGesture(
				minimumDuration: 0.5,
				pressing: { isPressing in
					if myTarget {
						withAnimation { isPressed = isPressing }
					}
				},
				perform: {
					if myTarget {
						showLongTapDialog = true
					}
				}
			)
			.actionSheet(isPresented: $showLongTapDialog) {
				ActionSheet(
					title: Text("Действия с целью"),
					buttons: [
						.default(Text((target.targetStatus?.isDone).orFalse ? "Переоткрыть цель" : "Закрыть цель")) {
							showCloseTaskDialog = true
						},
						.default(Text("Изменить цель")
							.foregroundStyle(Color(.systemBlue))) {
								isEditing = true
							},
						.destructive(Text("Удалить цель")) {
							showDeleteTaskDialog = true
						},
						.cancel(Text("Отмена"))
					]
				)
			}
			.alert("Хотите удалить эту цель?", isPresented: $showDeleteTaskDialog) {
				Button("Да") {
					viewModelEnvironment.deleteTarget(target: target)
				}
				Button("Нет", role: .cancel) { }
			}
			.alert(
				(target.targetStatus?.isDone) ?? false ? "Вы хотите открыть эту цель?" : "Вы закрыли эту цель?",
				isPresented: $showCloseTaskDialog
			) {
				Button("Да") {
					isLoading = true
					viewModelEnvironment.closedTarget(target: target)
				}
				Button("Нет", role: .cancel) { }
			}
			.sheet(isPresented: $isEditing) {
				TargetEditView<TargetsViewModel>(target: target, isCreateTarget: false)
					.interactiveDismissDisabled(true) // Блокируем свайп
					.alert("Закрыть?", isPresented: $showDismissEditAlert) {
						Button("Отмена", role: .cancel) {}
						Button("Выйти", role: .destructive) {
							isEditing = false
						}
					} message: {
						Text("Все изменения будут потеряны.")
					}
			}
	}
	
	// MARK: - UI Components
	
	private var mainContentView: some View {
		VStack(alignment: .leading, spacing: 8) {
			headerContentView
			
			// Описание цели
			VStack(alignment: .leading, spacing: 8) {
				descriptionView
				if let moderationStatus = target.targetModerationStatus,
				   moderationStatus != .APPROVED {
					HStack {
						Spacer()
						moderationStatusView(moderationStatus)
					}
				}
				
				// Подцели
				if isExpanded,
				   let subTargets = target.subTargets,
				   !subTargets.isEmpty {
					subTasks(subTargets)
				}
			}
			.transition(.opacity.combined(with: .identity))
		}
	}
	
	private var headerContentView: some View {
		VStack(alignment: .leading, spacing: 6) {
			HStack(alignment: .firstTextBaseline) {
				// Индикатор цели
				targetIndicatorWhithDesription(target)
					
				
				Text(target.title.orEmpty)
					.font(MMFonts.body)
					.foregroundColor(.headerText)
					.multilineTextAlignment(.leading)
					.fixedSize(horizontal: false, vertical: true)
					.lineLimit(isExpanded ? nil : 3)
				
				Spacer()
				if let subTargets = target.subTargets,
				   !subTargets.isEmpty,
				   let description = target.description,
				   !description.isEmpty {
					Image(systemName: showDescription ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
						.foregroundColor(.gray)
						.imageScale(.small)
						.padding(.top, 2)
						.offset(.init(width: 0, height: 4))
				}
			}
			
			HStack(spacing: 8) {
				AppIcons.General.calendar
					.foregroundColor(.gray)
					.imageScale(.small)
				
				Text((target.deadLineDateTime?.dateFromApiString ?? Date.now).toDisplayString)
					.font(MMFonts.caption)
					.foregroundColor(.gray)
					.lineLimit(1)
				
				if let percentage = target.percentage {
					Spacer()
					let isDone = (target.targetStatus?.isDone ?? false)
					let textPercent = isDone ? "Выполнил!" : "\(Int(percentage))%"
					
					
					if let subTargets = target.subTargets,
					   !subTargets.isEmpty {
						subTasksLabel(subTargets)
					}
					Text(textPercent)
						.font(MMFonts.caption)
						.foregroundColor((percentage == 100 || isDone) ? .green : .gray)
				}
			}
			
			let percentTarget: Double = (target.subTargets.isEmptyOrNil) ?
			(((target.targetStatus?.isDone) ?? false) ? 100.0 : 0.0) :
			target.percentage ?? 0.0
			ProgressView(value: percentTarget, total: 100)
				.tint(percentTarget == 100 ? .green : .mainRed)
				.background(Color.gray.opacity(0.1))
				.cornerRadius(4)
		}
		.background(.white)
	}
	
	@ViewBuilder
	private var descriptionView: some View {
		if let description = target.description,
		   !description.isEmpty {
			Text(description)
				.font(MMFonts.caption)
				.foregroundColor(.secondary)
				.lineLimit(showDescription ? nil : 2)
				.frame(maxWidth: .infinity, alignment: .leading)
				.fixedSize(horizontal: false, vertical: true)
				.lineLimit(nil)
				.cornerRadius(8)
		}
	}
	
	@ViewBuilder
	private func moderationStatusView(_ moderationStatus: TargetModerationStatus) -> some View {
		HStack {
			Spacer()
			HStack(alignment: .center, spacing: 2) {
				Text(moderationStatus.title)
					.font(MMFonts.caption)
					.foregroundStyle(moderationStatus.color)
				Image(systemName: "info.circle")
					.resizable()
					.frame(width: 8, height: 8)
					.foregroundStyle(moderationStatus.color)
					.offset(CGSize(width: 0, height: 0.5))
			}
			.padding(2)
			.padding(.horizontal, 2)
			.background(moderationStatus.color.opacity(0.1))
			.cornerRadius(8)
			/// Обучалка
				.onTapGesture(perform:  {
					showHelpModerationStatusTooltip.toggle()
				})
				.popover(isPresented: $showHelpModerationStatusTooltip) {
					VStack(alignment: .leading, spacing: 8) {
						HStack {
							ZStack {
								moderationStatus.color
									.opacity(0.1)
									.frame(width: 24, height: 24)
									.cornerRadius(12)
								Image(systemName: moderationStatus.image)
									.resizable()
									.frame(width: 12, height: 14)
									.foregroundColor(moderationStatus.color)
								
							}
							Text(moderationStatus.title)
								.foregroundStyle(Color.headerText)
								.font(MMFonts.subTitle)
						}
						Text(moderationStatus.description())
							.foregroundStyle(Color.headerText)
							.font(MMFonts.body)
							.multilineTextAlignment(.leading)
							.fixedSize(horizontal: false, vertical: true)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					/// указываем размер взависимости всплывающего окна от размера экрана
					.frame(width: UIScreen.main.bounds.width - 150)
					.presentationCompactAdaptation(.popover)
					.padding()
				}
		}
		
		
		
		
	}
	
	@ViewBuilder
	func subTasks(_ subTargets: [UserSubTargetDtoModel]) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			Divider()
			
			Text("Подцели")
				.font(MMFonts.caption)
				.foregroundColor(.headerText)
				.padding(.top, 4)
			
			ForEach(subTargets) { subTarget in
				SubTargetRowView<TargetsViewModel>(
					myTarget: myTarget,
					showDescription: $showDescription,
					subTarget: subTarget,
					parentTarget: target
				)
			}
		}
		.padding(.top, 4)
	}
	
	// MARK: все что относится к категории
	
	@ViewBuilder
	private func subTasksLabel(_ subTargets: [UserSubTargetDtoModel]) -> some View {
		let done = subTargets.filter({ $0.targetStatus == .done }).count
		let total = subTargets.count
		
		HStack(spacing: 4) {
			Image(systemName: "checklist")
				.font(MMFonts.subCaption)
			Text("\(done)/\(total)")
				.font(MMFonts.caption)
		}
		.foregroundColor(.blue)
		.padding(.vertical, 1)
		.padding(.horizontal, 6)
		.background(
			Capsule()
				.fill(Color.blue.opacity(0.1))
		)
	}
	
	/// Индикатор со вписком целей (НЕ ИСПОЛЬЗУЕТСЯ)
	@ViewBuilder
	func targetIndicatorWhithList(_ target: UserTargetDtoModel) -> some View {
		StatusTargetIndicatorView(target)
			.onTapGesture(perform:  {
				showHelpStatusTooltip.toggle()
			})
			.popover(isPresented: $showHelpStatusTooltip) {
				VStack(alignment: .leading) {
					ForEach(TargetStatus.valueCases, id: \.self) { status in
						let isCurrentStatus = target.targetStatus == status
						HStack {
							StatusTargetIndicatorView(category: target.category ?? .unknown,
													  percentage: target.percentage ?? 0,
													  status: status,
													  enable: isCurrentStatus)
							Text(status.title)
								.foregroundStyle(isCurrentStatus ? .black : .secondary)
								.font(MMFonts.title)
						}
					}
				}
				.frame(width: UIScreen.main.bounds.width - 150)
				.presentationCompactAdaptation(.popover)
				.padding()
			}
	}
	
	/// Индикатор со вписком целей (ИСПОЛЬЗУЕТСЯ)
	@ViewBuilder
	func targetIndicatorWhithDesription(_ target: UserTargetDtoModel) -> some View {
		StatusTargetIndicatorView(target)
			.onTapGesture(perform:  {
				showHelpStatusTooltip.toggle()
			})
			.popover(isPresented: $showHelpStatusTooltip) {
				let status = target.targetStatus ?? .unknown
				let category = target.category ?? .unknown
				VStack(alignment: .leading, spacing: 8) {
					HStack(alignment: .center) {
						StatusTargetIndicatorView(category: category,
												  percentage: target.percentage ?? 0,
												  status: status)
						Text(status.title)
							.foregroundStyle(Color.headerText)
							.font(MMFonts.subTitle)
						
						Image(systemName: "info.circle")
							.resizable()
							.frame(width: 12, height: 12)
							.foregroundColor(.gray)
							.offset(.init(width: 0, height: 1))
							.onTapGesture {
								showHelpStatusTooltip2.toggle()
							}
							.popover(isPresented: $showHelpStatusTooltip2) {
								VStack(alignment: .leading) {
									ForEach(TargetStatus.valueCases, id: \.self) { status in
										let isCurrentStatus = target.targetStatus == status
										HStack {
											StatusTargetIndicatorView(category: target.category ?? .unknown,
																	  percentage: target.percentage ?? 0,
																	  status: status,
																	  enable: isCurrentStatus)
											Text(status.title)
												.foregroundStyle(isCurrentStatus ? .black : .secondary)
												.font(MMFonts.subTitle)
										}
									}
								}
								.frame(width: UIScreen.main.bounds.width - 150)
								.presentationCompactAdaptation(.popover)
								.padding()
							}
					}

					Text(status.description)
						.foregroundStyle(Color.headerText)
						.font(MMFonts.body)
						.multilineTextAlignment(.leading)
						.fixedSize(horizontal: false, vertical: true)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				/// указываем размер взависимости всплывающего окна от размера экрана
				.frame(width: UIScreen.main.bounds.width - 150)
				.presentationCompactAdaptation(.popover)
				.padding()
			}
			.fixedSize(horizontal: true, vertical: true)
	}
}

extension TargetRowView {
    enum TargetButtonStatus {
        /// свернуть подзадачи
        case turn
        /// Развернуть подзадачи
        case expand
        /// Закрыть задачу
        case toDone
        /// Открыть задачу
        case toInProgress
        
        var name: String {
            switch self {
            case .turn:
                return "Свернуть"
            case .expand:
                return "Развернуть"
            case .toDone:
                return "Открыть задачу вновь"
            case .toInProgress:
                return "Закрыть задачу"
            }
        }
    }
}

#Preview("TargetRowView") {
    TargetRowView<TargetsViewModel>(target: .init(
//        title: "Test",
		id: 0,
		title: "Testsdfdsfdsdsfsdfsd fsdf sdfdsfsdfsfsdfsdgsdfgsd sdfgdsfgdfgdfgdf gdfg dfgdfgdfgsdfsdfsddsfsd fsd fdsf sdfsdfdsfsdfd",
        description: "Тестовое описание цели khbsdafsdfdsf sf ds fdsfsd fdsf dsf dsf sdf dsfhhjbkjhkghjvkgvkgvkgvcgc,hgvm kgk kv jghvlvhj,,b",
        percentage: 10,
		targetStatus: .inProgress,
		targetModerationStatus: .REJECTED,
        subTargets: [.init(title: "Test", description: "dssds",targetSubStatus: .notDone)],
		category: .family
    ))
    .environmentObject(TargetsViewModel())
	
	TargetRowView<TargetsViewModel>(target: .init(
//        title: "Test",
		id: 0,
		title: "Tdfd",
		description: "Тестовое описание цели khbsdafsdfdsf sf ds fdsfsd fdsf dsf dsf sdf dsfhhjbkjhkghjvkgvkgvkgvcgc,hgvm kgk kv jghvlvhj,,b",
		percentage: 10,
		targetStatus: .inProgress,
		targetModerationStatus: .DRAFT,
		subTargets: [.init(title: "Test", description: "dssds",targetSubStatus: .notDone)],
		category: .family
	))
	.environmentObject(TargetsViewModel())
}

#Preview("section") {
	CategorySectionView(
		category: .money,
		targets: [
			UserTargetDtoModel(
				id: 1,
//                title: "Test Tarsdf sdf sdf sdfdsfsdfsdfds fsdf sd fdfds fdsf sdf sdf sdfds f sdf sdf sdfsd fsd fget",
//				title: "Task ee",
				title: "Task 5eep[ooopopopopopopiiopopioipopi opiopi opi opi opi opi piopioopiopopopiopiiop l dg g dgfd fg dfgdgf gfddfgdfgnjuimimiioiiiklkj",
				description: "Description d dsf gdfgdfg fdg dgdfg dsfg dsf gdfg sdf gds dfsg dfg",
				percentage: 75,
				targetStatus: .draft,
				targetModerationStatus: .DRAFT,
				subTargets: [.init(id: 1, title: "Subtarget 1", description: "sdfsdfdsdf sdfsd fsd sfds fdsgdgsdfg dfg dfg dfs dfdfg dfdhds dsffssdf hsdfhdsfhsdhgdh"),
													   .init(id: 2, title: "Subtarget 2")],
				category: .money
			),
			UserTargetDtoModel(
				id: 2,
//                title: "Test Tarsdf sdf sdf sdfdsfsdfsdfds fsdf sd fdfds fdsf sdf sdf sdfds f sdf sdf sdfsd fsd fget",
//				title: "Task ee",
				title: "Tasknn",
				description: "Description d dsf gdfgdfg fdg dgdfg dsfg dsf gdfg sdf gds dfsg dfg",
				percentage: 75,
				targetStatus: .draft,
				targetModerationStatus: .DRAFT,
				subTargets: [.init(id: 1, title: "Subtarget 1", description: "sdfsdfdsdf sdfsd fsd sfds fdsgdgsdfg dfg dfg dfs dfdfg dfdhds dsffssdf hsdfhdsfhsdhgdh"),
													   .init(id: 2, title: "Subtarget 2")],
				category: .money
			)
		],
		onEdit: {}
	)
	.environmentObject(TargetsViewModel())
}
