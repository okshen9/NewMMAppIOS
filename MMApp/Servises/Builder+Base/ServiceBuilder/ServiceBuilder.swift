//
//  ServiceBuilder.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

// swiftlint:disable all
/// Алиас для протоколов с реквестами
//typealias RequestCompositeProtocol = ReactionRequestProtocol & MediaContentRequestProtocol &
//    ChannelRequestProtocol & PushRequestProtocol & NotificationRequestProtocol & CommentsRequestProtocol & PersonalAccountRequestProtocol & SupportRequestProtocol & NotificationsRequestProtocol & DonateRequestProtocol & DonateContractRequestProtocol &
//    DonatePaymentRequestProtocol & SpritesRequestProtocol & AdAPIFactoryProtocol & CategoryRequestProtocol & StickersRequestProtocol & PartnersRequestProtocol & ChatRequestProtocol & PlaylistsRequestProtocol  & ViewsHistoryRequestProtocol & ContentRequestProtocol & PartnersOffersRequestProtocol & PartnersWithdrawRequestProtocol & HashtagsRequestProtocol
//
///// Алиас для протоколов с сервисами
//typealias ServiceCompositeProtocol = ReactionServiceProtocol & MediaContentServiceProtocol &
//    ChannelServiceProtocol & PushServiceProtocol & NotificationSericeProtocol &
//    CommentsServiceProtocol & PersonalAccountServiceProtocol & SupportServiceProtocol &
//    NotificationsServiceProtocol & DonateServiceProtocol & DonateContractServiceProtocol & DonatePaymentServiceProtocol & SpritesServiceProtocol & CategoryServiceProtocol & StickersServiceProtocol & PartnersServiceProtocol & ChatServiceProtocol & PlaylistsServiceProtocol & ViewsHistoryServiceProtocol & ContentServiceProtocol & PartnersOffersServiceProtocol & PartnersWithdrawServiceProtocol & HashtagsServiceProtocol


final class ServiceBuilder: AbstractService {
    private(set) var apiFactory: APIFactory //RequestCompositeProtocol
    
    /// Инициализатор
    /// - Parameters:
    ///   - apiFactory: фабрика АПИ
    ///   - dataTaskBuilder: билдер дата тасок
    init(
        apiFactory: APIFactory = APIFactory.global,
        dataTaskBuilder: APIDataTasksBuilder = APIDataTasksBuilder(apiFactory: APIFactory.global))
    {
        self.apiFactory = apiFactory
        super.init(dataTaskBuilder: dataTaskBuilder)
    }
}
