//
//  TextEditor.swift
//  Buddymate
//
//  Created by Dylan Elliott on 30/9/21.
//
import Foundation
import HighlightedTextEditor
import UIKit

extension HighlightRule {
    static let boldItalics = try! NSRegularExpression(pattern: "_[^_]+_", options: [])
    static let uncheckedTodo = try! NSRegularExpression(pattern: "\\s*- \\[ \\]", options: [])
    static let checkedTodo = try! NSRegularExpression(pattern: "\\s*- \\[x\\]", options: [])
    static let tagged = try! NSRegularExpression(pattern: "#\\w+", options: [])

    static let linkStyle = TextFormattingRule(fontTraits: [.traitBold])
    
    static var markDylan: [HighlightRule] { return HighlightedTextEditor.markdown + [
        HighlightRule(pattern: uncheckedTodo, formattingRules: [
            linkStyle,
            TextFormattingRule(key: .link, value: MarkdownToken.uncheckedTodo.rawValue)
        ]),
        HighlightRule(pattern: checkedTodo, formattingRules: [
            linkStyle,
            TextFormattingRule(key: .link, value: MarkdownToken.checkedTodo.rawValue)
        ]),
        HighlightRule(pattern: tagged, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor.white),
            TextFormattingRule(key: .backgroundColor, value: UIColor.systemGreen)
        ])
    ]
    }
    
    enum MarkdownToken: String {
        case uncheckedTodo
        case checkedTodo
    }

    enum MarkdownSymbol {
        enum Todo: String {
            case checked = "- [x]"
            case unchecked = "- [ ]"
        }
    }
}
