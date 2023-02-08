//
//  Progress.swift
//  BStamp
//
//  Created by wesley on 2023/2/3.
//

import SwiftUI
import LibStamp


struct CircularWaiting:View{
        @Binding var isPresent: Bool
        @Binding var tipsTxt: String
        @State var color:Color = .orange
        let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        @State private var progressVal = 0
        
        var body: some View {
                if isPresent{
                        ProgressView(tipsTxt, value: Float64(progressVal), total: 100)
                                .progressViewStyle(CustomCircularWaitingViewStyle(color: $color))
                                .onReceive(timer) { _ in
                                        progressVal += 10
                                        progressVal = progressVal % 100
                                }
                }
        }
        
}
struct CustomCircularWaitingViewStyle: ProgressViewStyle {
        
        @Binding var color: Color
        
        func makeBody(configuration: Configuration) -> some View {
                ZStack {
                        Circle()
                                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                                .stroke(color, style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 200)
                        
                        configuration.label
                                .fontWeight(.bold)
                                .foregroundColor(color)
                                .frame(width: 180)
                }
        }
}

struct CustomCircularProgressViewStyle: ProgressViewStyle {
        
        func makeBody(configuration: Configuration) -> some View {
                ZStack {
                        Circle()
                                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 200)
                        
                        if let fractionCompleted = configuration.fractionCompleted {
                                Text(fractionCompleted < 1 ?
                                     "Completed \(Int((configuration.fractionCompleted ?? 0) * 100))%"
                                     : "Done!"
                                )
                                .fontWeight(.bold)
                                .foregroundColor(fractionCompleted < 1 ? .orange : .green)
                                .frame(width: 180)
                        }
                }
        }
}

struct RoundedRectProgressViewStyle: ProgressViewStyle {
        func makeBody(configuration: Configuration) -> some View {
                ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 14)
                                .frame(width: 250, height: 28)
                                .foregroundColor(.blue)
                                .overlay(Color.black.opacity(0.5)).cornerRadius(14)
                        
                        RoundedRectangle(cornerRadius: 14)
                                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 250, height: 28)
                                .foregroundColor(.yellow)
                }
                .padding()
        }
}


struct WithBackgroundProgressViewStyle: ProgressViewStyle {
        func makeBody(configuration: Configuration) -> some View {
                ProgressView(configuration)
                        .padding(8)
                        .background(Color.gray.opacity(0.25))
                        .tint(.red)
                        .cornerRadius(8)
        }
}


struct Progress_Previews: PreviewProvider {
        static var previews: some View {
                
                ProgressView("Loading...", value: 20, total: 100)
                        .progressViewStyle(RoundedRectProgressViewStyle())
                
                ProgressView("Loading...", value: 10, total: 100)
                        .progressViewStyle(CustomCircularProgressViewStyle())
                
                
                ProgressView(value: 30, total: 100)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                
                ProgressView("Loading...", value: 10, total: 100)
                        .accentColor(.gray)
                        .foregroundColor(.blue)
        }
}

enum Regex {
        static let ipAddress = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        static let hostname = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
        
        static   let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
}


extension String {
        
        func GoStr() ->GoString {
                let cs = (self as NSString).utf8String
                let buffer = UnsafePointer<Int8>(cs!)
                return GoString(p:buffer, n:strlen(buffer))
        }
        func CStr()->UnsafeMutablePointer<CChar>{
                return UnsafeMutablePointer(mutating: (self as NSString).utf8String!)
        }
        
        var isValidIpAddress: Bool {
                return self.matches(pattern: Regex.ipAddress)
        }
        
        var isValidHostname: Bool {
                return self.matches(pattern: Regex.hostname)
        }
        
        private func matches(pattern: String) -> Bool {
                return self.range(of: pattern,
                                  options: .regularExpression,
                                  range: nil,
                                  locale: nil) != nil
        }
        
        var isValidEmail:Bool{
                let emailPred = NSPredicate(format:"SELF MATCHES %@", Regex.emailRegEx)
                return emailPred.evaluate(with: self)
        }
}

enum TripState{
        case start
        case success
        case failed
}

struct CheckingView:View{
        @Binding var state:TripState
        
        var body: some View{
                switch state {
                case .start:
                        EmptyView()
                case .success:
                        Label("Checked", systemImage: "checkmark.circle.fill").foregroundColor(Color.green)
                case .failed:
                        Label("Checked", systemImage: "checkmark.circle.badge.xmark.fill").foregroundColor(Color.red)
                }
        }
}

extension Binding {
        func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
                Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
        }
}

func taskSleep(seconds:Int)async{
        try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
}
