
import Foundation

@resultBuilder
struct AttributedStringBuilder {

    static func buildBlock(_ components: AttributedStringConvertible...) -> some AttributedStringConvertible {
        Build { environment in
            components.flatMap { $0.attributedString(environment: environment) }
        }
    }

    static func buildOptional(_ component: AttributedStringConvertible?) -> some AttributedStringConvertible {
        Build { environment in
            component?.attributedString(environment: environment) ?? []
        }
    }
}

struct Lines<Content: AttributedStringConvertible>: AttributedStringConvertible {

    @AttributedStringBuilder
    let content: Content

    func attributedString(environment: Environment) -> [NSAttributedString] {
        [single(environment: environment)]
    }

    func single(environment: Environment) -> NSAttributedString {
        let pieces = content.attributedString(environment: environment)
        guard let first = pieces.first else { return .init() }
        let result = NSMutableAttributedString(attributedString: first)
        for piece in pieces.dropFirst() {
            result.append(.init(string: "\n", attributes: environment.attributes))
            result.append(piece)
        }
        return result
    }
}

struct Build: AttributedStringConvertible {

    let content: (Environment) -> [NSAttributedString]

    func attributedString(environment: Environment) -> [NSAttributedString] {
        content(environment)
    }
}

#if DEBUG

@AttributedStringBuilder
var example: some AttributedStringConvertible {
    "Hello, World!"
    "Another String"
}

import SwiftUI

struct DebugPreview: PreviewProvider {
    static var previews: some View {

        let string = Lines {
            example
        }.single(environment: .init())

        Text(AttributedString(string))
    }
}
#endif
