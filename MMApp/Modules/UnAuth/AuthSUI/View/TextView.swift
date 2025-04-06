//
//  TextView.swift
//  TestUISwift
//
//  Created by artem on 25.03.2025.
//

import SwiftUI

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
