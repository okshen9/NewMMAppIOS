//
//  MockModel.swift
//  NewMMAppIOS
//
//  Created by artem on 24.04.2025.
//


extension TargetsViewModel {
    static func mockWithData() -> TargetsViewModel {
        let viewModel = TargetsViewModel()
        
        // Создаем подцели для первой цели
        let subTargets1: [UserSubTargetDtoModel] = [
            UserSubTargetDtoModel(id: 101, title: "Подцель", description: "Описание цели", 
                    subTargetPercentage: 90, targetSubStatus: .done, rootTargetId: 119, 
                    isDeleted: false, creationDateTime: "2025-04-16T18:05:39.951888", 
                    lastUpdatingDateTime: "2025-04-21T01:12:30.473221", 
                    deadLineDateTime: "2025-04-24T18:04:00"),
            UserSubTargetDtoModel(id: 102, title: "Подцель 2", description: "Описание подцели 2", 
                    subTargetPercentage: 3, targetSubStatus: .done, rootTargetId: 119, 
                    isDeleted: false, creationDateTime: "2025-04-16T18:09:07.409716", 
                    lastUpdatingDateTime: "2025-04-21T01:12:30.473355", 
                    deadLineDateTime: "2025-04-16T18:08:50"),
            UserSubTargetDtoModel(id: 103, title: "и еще одна цель", description: "", 
                    subTargetPercentage: 1, targetSubStatus: .notDone, rootTargetId: 119, 
                    isDeleted: false, creationDateTime: "2025-04-16T18:40:58.346187", 
                    lastUpdatingDateTime: "2025-04-21T01:12:30.473476", 
                    deadLineDateTime: "2025-04-16T18:40:46"),
            UserSubTargetDtoModel(id: 104, title: "И еще одна подцель 2", description: "Что-то там", 
                    subTargetPercentage: 0, targetSubStatus: .notDone, rootTargetId: 119, 
                    isDeleted: false, creationDateTime: "2025-04-16T18:40:58.346281", 
                    lastUpdatingDateTime: "2025-04-21T01:12:30.473587", 
                    deadLineDateTime: "2025-04-16T18:40:56"),
            UserSubTargetDtoModel(id: 105, title: "что-то новое", description: "", 
                    subTargetPercentage: 33, targetSubStatus: .notDone, rootTargetId: 119, 
                    isDeleted: false, creationDateTime: "2025-04-16T18:41:29.061829", 
                    lastUpdatingDateTime: "2025-04-21T01:12:30.473734", 
                    deadLineDateTime: "2025-04-22T23:59:59.999")
        ]
        
        // Создаем подцели для второй цели
        let subTargets2: [UserSubTargetDtoModel] = [
            UserSubTargetDtoModel(id: 113, title: "Подцель 0", description: "Описание подцели", 
                    subTargetPercentage: 50, targetSubStatus: .notDone, rootTargetId: 124, 
                    isDeleted: false, creationDateTime: "2025-04-21T00:49:37.047213", 
                    lastUpdatingDateTime: "2025-04-21T01:18:42.108996", 
                    deadLineDateTime: "2025-04-28T00:48:20"),
            UserSubTargetDtoModel(id: 114, title: "Подцель 1", description: "Описание подцели 1", 
                    subTargetPercentage: 50, targetSubStatus: .done, rootTargetId: 124, 
                    isDeleted: false, creationDateTime: "2025-04-21T00:49:37.047339", 
                    lastUpdatingDateTime: "2025-04-21T01:18:42.109189", 
                    deadLineDateTime: "2025-04-28T00:49:08")
        ]
        
        // Создаем подцели для четвертой цели
        let subTargets4: [UserSubTargetDtoModel] = [
            UserSubTargetDtoModel(id: 111, title: "Sub target 3", description: "", 
                    subTargetPercentage: 50, targetSubStatus: .done, rootTargetId: 123, 
                    isDeleted: false, creationDateTime: "2025-04-20T18:15:32.139753", 
                    lastUpdatingDateTime: "2025-04-21T02:57:58.192417", 
                    deadLineDateTime: "2025-04-20T18:15:13"),
            UserSubTargetDtoModel(id: 112, title: "Subterget2", description: "", 
                    subTargetPercentage: 50, targetSubStatus: .done, rootTargetId: 123, 
                    isDeleted: false, creationDateTime: "2025-04-20T18:15:32.139943", 
                    lastUpdatingDateTime: "2025-04-21T02:57:58.192551", 
                    deadLineDateTime: "2025-04-20T18:15:19")
        ]
        
        // Создаем цели
        let targets: [UserTargetDtoModel] = [
            UserTargetDtoModel(id: 119, title: "Тестовая цель", description: "Какое-то описание", 
                 userExternalId: 33, percentage: 93, deadLineDateTime: "2025-04-25T18:02:00", 
                 streamId: 0, targetStatus: .draft, subTargets: subTargets1, 
                 isDeleted: false, creationDateTime: "2025-04-16T18:05:39.951204", 
                 lastUpdatingDateTime: "2025-04-21T01:12:30.473062", 
                 category: .money),
            
            UserTargetDtoModel(id: 124, title: "Тестовая цель 0", description: "Новая цель", 
                 userExternalId: 33, percentage: 50, deadLineDateTime: "2025-04-30T00:48:00", 
                 streamId: 0, targetStatus: .draft, subTargets: subTargets2, 
                 isDeleted: false, creationDateTime: "2025-04-21T00:49:37.046407", 
                 lastUpdatingDateTime: "2025-04-21T01:18:42.108833", 
                 category: .personal),
            
            UserTargetDtoModel(id: 125, title: "Просто цель", description: "", 
                 userExternalId: 33, percentage: 100, deadLineDateTime: "2025-04-28T01:12:37", 
                 streamId: 0, targetStatus: .done, subTargets: [], 
                 isDeleted: false, creationDateTime: "2025-04-21T01:12:46.682719", 
                 lastUpdatingDateTime: "2025-04-21T01:18:56.19429", 
                 category: .health),
            
            UserTargetDtoModel(id: 123, title: "Adds", description: "Add", 
                 userExternalId: 33, percentage: 100, deadLineDateTime: "2025-04-22T18:15:00", 
                 streamId: 0, targetStatus: .draft, subTargets: subTargets4, 
                 isDeleted: false, creationDateTime: "2025-04-20T18:15:32.139446", 
                 lastUpdatingDateTime: "2025-04-21T02:57:58.192266", 
                 category: .money),
            
            UserTargetDtoModel(id: 126, title: "Семейная цель", description: "", 
                 userExternalId: 33, percentage: 0, deadLineDateTime: "2025-04-28T03:31:28", 
                 streamId: 0, targetStatus: .inProgress, subTargets: [], 
                 isDeleted: false, creationDateTime: "2025-04-21T03:32:03.516152", 
                 lastUpdatingDateTime: nil, 
                 category: .family),
            
            UserTargetDtoModel(id: 128, title: "Цель закрыть мвп", description: "", 
                 userExternalId: 33, percentage: 0, deadLineDateTime: "2025-04-28T11:44:02", 
                 streamId: 0, targetStatus: .inProgress, subTargets: [], 
                 isDeleted: false, creationDateTime: "2025-04-21T11:44:39.531228", 
                 lastUpdatingDateTime: nil, 
                 category: .personal)
        ]
        
        viewModel.targets = targets
        viewModel.isLoading = false
        print("Neshko111+++")
        return viewModel
    }
}
