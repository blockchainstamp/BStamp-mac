//
//  Progress.swift
//  BStamp
//
//  Created by wesley on 2023/2/3.
//

import SwiftUI
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
