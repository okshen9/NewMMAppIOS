//
//  TargetsViewModel.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation

extension TargetsView {
    @discardableResult func loadTargets() -> [UserTarget] {
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date()

        targets = [
            // Категория: Деньги
            UserTarget(
                id: 1,
                title: "Накопить на вертолёт",
                description: "Купить вертолёт для личного пользования",
                userExternalId: 1,
                percentage: 25.0,
                deadLineDateTime: currentDate.addingTimeInterval(86400 * 30), // +30 дней
                streamId: 1,
                targetStatus: "DRAFT",
                subTargets: [
                    UserSubTarget(
                        id: 1,
                        title: "Откладывать по 1000$ в месяц",
                        description: "Ежемесячные накопления",
                        subTargetPercentage: 50.0,
                        targetStatus: "IN_PROGRESS",
                        rootTargetId: 1,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 30)
                    ),
                    UserSubTarget(
                        id: 2,
                        title: "Инвестировать в акции",
                        description: "Вложить 5000$ в акции",
                        subTargetPercentage: 30.0,
                        targetStatus: "NOT_STARTED",
                        rootTargetId: 1,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 60)
                    ),
                    UserSubTarget(
                        id: 3,
                        title: "Сократить расходы",
                        description: "Уменьшить траты на 20%",
                        subTargetPercentage: 20.0,
                        targetStatus: "IN_PROGRESS",
                        rootTargetId: 1,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 90)
                    )
                ],
                isDeleted: false,
                creationDateTime: currentDate,
                lastUpdatingDateTime: currentDate,
                category: .money
            ),
            UserTarget(
                id: 2,
                title: "Купить квартиру",
                description: "Приобрести жильё в центре города",
                userExternalId: 1,
                percentage: 10.0,
                deadLineDateTime: currentDate.addingTimeInterval(86400 * 365), // +1 год
                streamId: 1,
                targetStatus: "DRAFT",
                subTargets: [
                    UserSubTarget(
                        id: 4,
                        title: "Накопить на первый взнос",
                        description: "Собрать 20% от стоимости",
                        subTargetPercentage: 15.0,
                        targetStatus: "IN_PROGRESS",
                        rootTargetId: 2,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 180)
                    ),
                    UserSubTarget(
                        id: 5,
                        title: "Выбрать район",
                        description: "Определиться с локацией",
                        subTargetPercentage: 5.0,
                        targetStatus: "NOT_STARTED",
                        rootTargetId: 2,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 60)
                    ),
                    UserSubTarget(
                        id: 6,
                        title: "Оформить ипотеку",
                        description: "Подготовить документы",
                        subTargetPercentage: 0.0,
                        targetStatus: "NOT_STARTED",
                        rootTargetId: 2,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 270)
                    )
                ],
                isDeleted: false,
                creationDateTime: currentDate,
                lastUpdatingDateTime: currentDate,
                category: .money
            ),

            // Категория: Личное
            UserTarget(
                id: 3,
                title: "Научиться играть на гитаре",
                description: "Освоить базовые аккорды",
                userExternalId: 1,
                percentage: 40.0,
                deadLineDateTime: currentDate.addingTimeInterval(86400 * 90), // +3 месяца
                streamId: 1,
                targetStatus: "IN_PROGRESS",
                subTargets: [
                    UserSubTarget(
                        id: 7,
                        title: "Купить гитару",
                        description: "Выбрать и приобрести инструмент",
                        subTargetPercentage: 100.0,
                        targetStatus: "COMPLETED",
                        rootTargetId: 3,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 7)
                    ),
                    UserSubTarget(
                        id: 8,
                        title: "Выучить аккорды",
                        description: "Освоить Am, C, G, F",
                        subTargetPercentage: 50.0,
                        targetStatus: "IN_PROGRESS",
                        rootTargetId: 3,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 30)
                    ),
                    UserSubTarget(
                        id: 9,
                        title: "Сыграть первую песню",
                        description: "Исполнить 'Knockin' on Heaven's Door'",
                        subTargetPercentage: 10.0,
                        targetStatus: "NOT_STARTED",
                        rootTargetId: 3,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 60)
                    )
                ],
                isDeleted: false,
                creationDateTime: currentDate,
                lastUpdatingDateTime: currentDate,
                category: .personal
            ),

            // Категория: Семья
            UserTarget(
                id: 4,
                title: "Организовать семейный отпуск",
                description: "Поездка на море всей семьёй",
                userExternalId: 1,
                percentage: 60.0,
                deadLineDateTime: currentDate.addingTimeInterval(86400 * 120), // +4 месяца
                streamId: 1,
                targetStatus: "IN_PROGRESS",
                subTargets: [
                    UserSubTarget(
                        id: 10,
                        title: "Выбрать место",
                        description: "Определиться с курортом",
                        subTargetPercentage: 100.0,
                        targetStatus: "COMPLETED",
                        rootTargetId: 4,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 7)
                    ),
                    UserSubTarget(
                        id: 11,
                        title: "Забронировать отель",
                        description: "Найти подходящий вариант",
                        subTargetPercentage: 50.0,
                        targetStatus: "IN_PROGRESS",
                        rootTargetId: 4,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 30)
                    ),
                    UserSubTarget(
                        id: 12,
                        title: "Купить билеты",
                        description: "Забронировать авиабилеты",
                        subTargetPercentage: 20.0,
                        targetStatus: "NOT_STARTED",
                        rootTargetId: 4,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 60)
                    )
                ],
                isDeleted: false,
                creationDateTime: currentDate,
                lastUpdatingDateTime: currentDate,
                category: .family
            ),

            // Категория: Здоровье
            UserTarget(
                id: 5,
                title: "Похудеть на 10 кг",
                description: "Достичь идеального веса",
                userExternalId: 1,
                percentage: 70.0,
                deadLineDateTime: currentDate.addingTimeInterval(86400 * 180), // +6 месяцев
                streamId: 1,
                targetStatus: "IN_PROGRESS",
                subTargets: [
                    UserSubTarget(
                        id: 13,
                        title: "Составить план питания",
                        description: "Перейти на здоровую диету",
                        subTargetPercentage: 100.0,
                        targetStatus: "COMPLETED",
                        rootTargetId: 5,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 7)
                    ),
                    UserSubTarget(
                        id: 14,
                        title: "Начать тренировки",
                        description: "Занятия 3 раза в неделю",
                        subTargetPercentage: 50.0,
                        targetStatus: "IN_PROGRESS",
                        rootTargetId: 5,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 30)
                    ),
                    UserSubTarget(
                        id: 15,
                        title: "Пройти обследование",
                        description: "Проверить здоровье у врача",
                        subTargetPercentage: 20.0,
                        targetStatus: "NOT_STARTED",
                        rootTargetId: 5,
                        isDeleted: false,
                        creationDateTime: currentDate,
                        lastUpdatingDateTime: currentDate,
                        deadLineDateTime: currentDate.addingTimeInterval(86400 * 90)
                    )
                ],
                isDeleted: false,
                creationDateTime: currentDate,
                lastUpdatingDateTime: currentDate,
                category: .health
            )
        ]
        return targets
    }
    
    
}
