//
//  Suggestion.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 21/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import UIKit

class SuggestionAttribute: Equatable, ExpressibleByStringLiteral {
    typealias StringLiteralType = String
    
    var order: Int?
    var text: String?
    
    public static func ==(lhs: SuggestionAttribute, rhs: SuggestionAttribute) -> Bool {
        return lhs.order == rhs.order
    }
    
    public required init(stringLiteral value: String) {
        let components = value.components(separatedBy: ",")
        
        if components.count == 2 {
            self.order = Int(components[0]) ?? -1
            self.text = components[1]
        }
    }
    
    public required convenience init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

enum SuggestionSourceEnum: SuggestionAttribute, Comparable, RawRepresentable, CaseIterable {
    typealias RawValue = SuggestionAttribute
    
    case speakerFirstname = "1, speaker"
    case speakerLastname  = "2, speaker"
    case title            = "3, title"
    case details          = "4, details"
    case twitter          = "5, twitter"
    
    static let sourceCriteriaLimit: String = ":"
    
    static func ==(lhs: SuggestionSourceEnum, rhs: SuggestionSourceEnum) -> Bool {
        return lhs.rawValue.order == rhs.rawValue.order
    }

    static func <(lhs: SuggestionSourceEnum, rhs: SuggestionSourceEnum) -> Bool {
        guard let lhsOrder = lhs.rawValue.order, let rhsOrder = rhs.rawValue.order else { return false }
        
        return lhsOrder < rhsOrder
    }
    
    func getSearchText() -> String {
        return self.rawValue.text ?? ""
    }
    
    func getImage() -> UIImage? {
        switch self {
        case .speakerFirstname, .speakerLastname:
            return UIImage(named: "speaker-black")
        case .title:
            return UIImage(named: "title")
        case .details:
            return UIImage(named: "details")
        case .twitter:
            return UIImage(named: "twitter-black")
        }
    }
    
    func getAttributedText(for completeWord: String) -> NSAttributedString {
        var attributed = NSMutableAttributedString()
        
        attributed = NSMutableAttributedString(string: getSearchText() + SuggestionSourceEnum.sourceCriteriaLimit, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)])
            
        attributed.append(NSMutableAttributedString(string: completeWord, attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 13),
                                                                                       NSMutableAttributedString.Key.foregroundColor: UIColor.tertiaryText]))
        return attributed
    }
    
    static func isSource(text: String) -> Bool {
        return SuggestionSourceEnum.allCases.filter { $0.rawValue.text == text }.count > 0
    }
}

class SuggestionSource {
    var source: SuggestionSourceEnum
    var inTalks: [TalkModel]
    
    init(source: SuggestionSourceEnum, inTalks: [TalkModel]) {
        self.source = source
        self.inTalks = inTalks
    }
    
}


class Suggestion {
    var text: String
    var completeWord: String
    private var attributedText: NSAttributedString
    var sources: [SuggestionSource]
    var inTalks: [TalkModel]
    
    func description() -> String {
       return "\(text) - \(completeWord) - \(sources)"
    }
    
    init(text: String, completeWord: String) {
        
        self.text           = text
        self.completeWord   = completeWord
        self.attributedText = NSAttributedString()
        self.sources        = []
        self.inTalks        = []
        
        self.attributedText = setAttributedText()
    }
    
    func getAttributedText() -> NSAttributedString {
        return self.attributedText
    }
    
    private func setAttributedText() -> NSAttributedString {
        var attributed = NSMutableAttributedString()
        
        if let index = completeWord.startIndex(of: text) {
            let str = String(completeWord.prefix(upTo: index))
            attributed = NSMutableAttributedString(string: str, attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                                                             NSMutableAttributedString.Key.foregroundColor: UIColor.tertiaryText])
        }
        
        attributed.append(NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)]))
        
        if let index = completeWord.endIndex(of: text) {
            let str = String(completeWord.suffix(from: index))
            attributed.append(NSMutableAttributedString(string: str, attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                                                                  NSMutableAttributedString.Key.foregroundColor: UIColor.tertiaryText]))
        }
        
        return attributed
    }
    
    func add(talk: TalkModel) {
        guard !inTalks.contains(talk) else { return }
        
        inTalks.append(talk)
    }
    
    func add(source: SuggestionSourceEnum, for talk: TalkModel) {
        if let src = (sources.filter { $0.source == source }.first) {
            if (!src.inTalks.contains(talk)) {
                src.inTalks.append(talk)
            }
        }
        else {
            sources.append(SuggestionSource(source: source, inTalks: [talk]))
        }
    }
}



