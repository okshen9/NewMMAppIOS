import SwiftUI

struct EmptyView: View {
    @StateObject private var viewModel = EmptyViewModel()
    @State private var servise: EventsServiceProtocol = ServiceBuilder()

    var body: some View {
        VStack {
            Text("Скоро будет контент")
                .foregroundColor(.mainRed)
            Button(action: {
                Task {
                    let createEvent = try? await servise.createEvent(model: EventDTO(id: nil, title: "test", startDate: Date().toApiString, endDate: Date().toApiString, type: "nil", creatorExternalId: "11", assigneeExternalIds: ["11"], issueId: 1, description: "test"))
                }
            }, label: {
                Text("createEvent")
            })
            
            Button(action: {
                Task {
                    let createEvent = try? await servise.getEventById(id: 1)
                }
            }, label: {
                Text("getEventById")
            })
            
            Button(action: {
                Task {
                    let createEvent = try? await servise.updateEvent(id: 1, model: EventDTO(id: nil, title: "test", startDate: Date().toApiString, endDate: Date().toApiString, type: "nil", creatorExternalId: "11", assigneeExternalIds: ["11"], issueId: 1, description: "test"))
                }
            }, label: {
                Text("updateEvent")
            })
            
            Button(action: {
                Task {
                    let createEvent = try? await servise.getAllEvents()
                }
            }, label: {
                Text("getAllEvents")
            })
            
            Button(action: {
                Task {
                    let createEvent = try? await servise.searchEvents(searchParams: [.type([.targetDone,.targetInProgress])])
                }
            }, label: {
                Text("searchEvents")
            })
            
        }
    }
}

// MARK: - Constants
extension EmptyView {
    private enum Constants {
        static let title = "Выберите карту"
    }
}

#Preview {
    EmptyView()
}
