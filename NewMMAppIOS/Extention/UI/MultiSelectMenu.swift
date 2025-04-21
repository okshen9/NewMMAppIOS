//
//  MultiSelectMenu.swift
//  NewMMAppIOS
//
//  Created by artem on 21.04.2025.
//


import SwiftUI

struct MultiSelectMenu: View {
    @Binding var isPresented: Bool
    let options: [String]
    @Binding var originalSelection: Set<String> // Оригинальные значения
    @State private var tempSelection: Set<String> // Временные значения
    let onCommit: () -> Void

    // Инициализатор для захвата начального состояния
    init(isPresented: Binding<Bool>,
         options: [String],
         originalSelection: Binding<Set<String>>,
         onCommit: @escaping () -> Void) {
        self._isPresented = isPresented
        self.options = options
        self._originalSelection = originalSelection
        self._tempSelection = State(initialValue: originalSelection.wrappedValue)
        self.onCommit = onCommit
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack(spacing: 6) {
                    Text(option)
                        .foregroundColor(tempSelection.contains(option) ? Color.headerText : Color(uiColor: .systemGray))
                    Spacer()
                    ZStack {
                        Image(systemName: "checkmark")
                            .resizable()
                            .foregroundColor(.clear)
                        if tempSelection.contains(option) {
                            Image(systemName: "checkmark")
                                .resizable()
                                .foregroundColor(.accentColor)
                        }
                    }
                    .frame(width: 16, height: 16)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if tempSelection.contains(option) {
                        tempSelection.remove(option)
                    } else {
                        tempSelection.insert(option)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            Divider()
                .padding(.top)
            Button("Сохранить") {
                originalSelection = tempSelection // Сохраняем изменения
                onCommit()
                isPresented = false
            }
            .foregroundStyle(Color.accentColor)
            .bold()
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        // Сбрасываем при закрытии через жесты
        .onChange(of: isPresented) { oldValue, newValue in
            if !newValue {
                tempSelection = originalSelection
            }
        }
    }
}

extension View {
    func customMenu(
        isPresented: Binding<Bool>,
        options: [String],
        selected: Binding<Set<String>>,
        onCommit: @escaping () -> Void
    ) -> some View {
        self.popover(isPresented: isPresented) {
            MultiSelectMenu(
                isPresented: isPresented,
                options: options,
                originalSelection: selected,
                onCommit: onCommit
            )
            .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    @Previewable @State var showMenu = false
    @Previewable @State var showMenuToolbar = false
    @Previewable @State var selectedOptions: Set<String> = []
    let filters = ["Фильтр 1", "Фильтр 2", "Фильтр 3"]
    NavigationStack {
            Text("Выбрано: \(selectedOptions.joined(separator: ", "))")
            .onLongPressGesture {
                    showMenu.toggle()
                }
                .popover(isPresented: $showMenu) {
                    MultiSelectMenu(
                        isPresented: $showMenu,
                        options: filters,
                        originalSelection: $selectedOptions
                    ) {
                        print("Сохранено: \(selectedOptions)")
                    }
                    .presentationCompactAdaptation(.popover)
                }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showMenuToolbar.toggle()
                } label: {
                    Label("Фильтры", systemImage: "line.3.horizontal.decrease.circle")
                }
                .popover(isPresented: $showMenuToolbar) {
                    MultiSelectMenu(
                        isPresented: $showMenuToolbar,
                        options: filters,
                        originalSelection: $selectedOptions
                    ) {
                        print("Сохранено: \(selectedOptions)")
                    }
                    .presentationCompactAdaptation(.popover)
                }
            }
        }
    }
}
