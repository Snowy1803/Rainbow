//
//  StringGenerator.swift
//  Rainbow
//
//  Created by Wei Wang on 15/12/23.
//
//  Copyright (c) 2018 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

protocol StringGenerator {
    func generate(for entry: Rainbow.Entry) -> String
}

struct ConsoleStringGenerator: StringGenerator {
    func generate(for entry: Rainbow.Entry) -> String {

        var foregroundChanged = false
        var backgroundChanged = false
        var styleChanged = false
        
        let strings: [String] = entry.segments.map {
            
            if $0.text.isEmpty {
                return ""
            }
            
            var codes: [UInt8] = []
            
            if (foregroundChanged && $0.color == nil) || (backgroundChanged && $0.backgroundColor == nil) || styleChanged {
                codes.append(0)
            }
            
            foregroundChanged = $0.color != nil
            backgroundChanged = $0.backgroundColor != nil
            styleChanged = !($0.styles?.isEmpty ?? true)
            
            if let color = $0.color {
                codes += color.value
            }
            if let backgroundColor = $0.backgroundColor {
                codes += backgroundColor.value
            }
            if let styles = $0.styles {
                codes += styles.flatMap{ $0.value }
            }

            if codes.isEmpty {
                return $0.text
            } else {
                return "\(ControlCode.CSI)\(codes.map{String($0)}.joined(separator: ";"))m\($0.text)"
            }
        }

        return strings.joined() + (entry.isPlain ? "" : "\(ControlCode.CSI)0m")
    }
}
