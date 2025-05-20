//
//  TextView.swift
//  TestUISwift
//
//  Created by artem on 25.03.2025.
//

import SwiftUI
///  Текст с гипер ссылками
struct LinkedText: View {
    enum LinkType {
        case terms, privacy
    }

    let text: String
    let links: [String: LinkType]
    let action: (LinkType) -> Void

    var body: some View {
        TextView(text: text, links: links, action: action)
            .frame(height: 100)
    }
}

struct TextView: UIViewRepresentable {
    let text: String
    let links: [String: LinkedText.LinkType]
    let action: (LinkedText.LinkType) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true // Исправлено
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.delegate = context.coordinator

        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: text.utf16.count)
        attributedString.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 12),
            range: fullRange
        )
        attributedString.addAttribute(
            .foregroundColor,
//            value: UIColor.subtitleText,
            value: UIColor.black,
            range: fullRange
        )

        // Добавляем кастомные атрибуты
        for (substring, linkType) in links {
            let linkRange = (text as NSString).range(of: substring)
            attributedString.addAttribute(
                .customLink, // Используем новый ключ
                value: linkType.rawValue,
                range: linkRange
            )
            attributedString.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: linkRange
            )
        }

        textView.attributedText = attributedString
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action, links: links)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let action: (LinkedText.LinkType) -> Void
        let links: [String: LinkedText.LinkType]

        init(action: @escaping (LinkedText.LinkType) -> Void,
             links: [String: LinkedText.LinkType]) {
            self.action = action
            self.links = links
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange else { return }

            let location = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)

            textView.attributedText.enumerateAttribute(
                .customLink, // Используем тот же ключ
                in: NSRange(location: 0, length: textView.attributedText.length)
            ) { value, range, _ in
                if let linkValue = value as? String,
                   location >= range.location && location <= range.location + range.length {

                    DispatchQueue.main.async {
                        if let linkType = LinkedText.LinkType(rawValue: linkValue) {
                            self.action(linkType)
                        }
                        textView.selectedTextRange = nil
                    }
                }
            }
        }
    }
}

// Кастомный ключ для атрибутов
extension NSAttributedString.Key {
    static let customLink = NSAttributedString.Key("CustomLinkAttribute")
}

// Реализация RawRepresentable
extension LinkedText.LinkType: RawRepresentable {
    public init?(rawValue: String) {
        switch rawValue {
        case "terms": self = .terms
        case "privacy": self = .privacy
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .terms: return "terms"
        case .privacy: return "privacy"
        }
    }
}
// MARK: - Чистая SwiftUI реализация

struct SwiftUILinkedText: View {
    let text: String
    let links: [String: LinkedText.LinkType]
    let action: (LinkedText.LinkType) -> Void
    
    var body: some View {
        Text(.init(attributedString()))
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
    }
    
    private func attributedString() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: text.utf16.count)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 12),
            range: fullRange
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.black,
            range: fullRange
        )
        
        for (substring, linkType) in links {
            if let range = text.range(of: substring) {
                let nsRange = NSRange(range, in: text)
                
                attributedString.addAttribute(
                    .link,
                    value: "action://\(linkType.rawValue)",
                    range: nsRange
                )
                
                attributedString.addAttribute(
                    .foregroundColor,
                    value: UIColor.blue,
                    range: nsRange
                )
                
                attributedString.addAttribute(
                    .underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: nsRange
                )
            }
        }
        
        return attributedString
    }
}

extension Text {
    init(_ attributedString: NSAttributedString) {
        self.init(AttributedString(attributedString))
    }
}

struct SwiftUILinkedTextModifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "action" {
                    let actionString = url.host ?? ""
                    if let linkType = LinkedText.LinkType(rawValue: actionString) {
                        // Здесь можно обработать действие
                        NotificationCenter.default.post(
                            name: Notification.Name("LinkedTextAction"),
                            object: nil,
                            userInfo: ["linkType": linkType]
                        )
                    }
                    return .handled
                }
                return .systemAction
            })
    }
}

extension View {
    func handleLinkedTextActions(action: @escaping (LinkedText.LinkType) -> Void) -> some View {
        self.modifier(SwiftUILinkedTextModifier())
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LinkedTextAction"))) { notification in
                if let linkType = notification.userInfo?["linkType"] as? LinkedText.LinkType {
                    action(linkType)
                }
            }
    }
}
