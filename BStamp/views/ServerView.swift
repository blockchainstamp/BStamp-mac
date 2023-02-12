//
//  ServerView.swift
//  BStamp
//
//  Created by wesley on 2023/2/12.
//

import SwiftUI

struct ServerView: View {
        @State var imapPort:String = "996"
        @State var smtpPort:String = "443"
        @State var logLevels:[String] = ["trace","debug","info","warn","error","fatal","panic"]
        @State var logVel:String = "info"
        @State var text:String = ""
        @State var curStatus:Bool = true
        var body: some View {
                NavigationSplitView{
                        VStack{
                                LogoImgView()
                                TextField("Smtp Port:", text: $smtpPort)
                                TextField("Imap Port:", text: $imapPort)
                                Picker("log level", selection: $logVel) {
                                        ForEach(logLevels, id: \.self){ leve in
                                                Text(leve)
                                        }
                                }
                                Spacer()
                                Button(action: {
                                        startOrStopService()
                                }) {
                                        if curStatus{
                                                Text("Start Service").fontWeight(.heavy)
                                                        .font(.system(size: 18))
                                                        .frame(width: 120, height: 20)
                                                        .foregroundColor(.green)
                                                        .padding()
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 16)
                                                                        .stroke(.green, lineWidth: 2)
                                                        )
                                        }else{
                                                Text("Stop Service").fontWeight(.heavy)
                                                        .font(.system(size: 18))
                                                        .frame(width: 120, height: 20)
                                                        .foregroundColor(.red)
                                                        .padding()
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 16)
                                                                        .stroke(.red, lineWidth: 2)
                                                        )
                                        }
                                }.buttonStyle(.plain)
                                
                                
                                Spacer()
                        }.padding()
                }detail:{
                        TextArea(text: $text)
                                        .border(Color.black)
                }
        }
        
        private func startOrStopService(){
                
        }
}

struct TextArea: NSViewRepresentable {
        @Binding var text: String
        
        func makeNSView(context: Context) -> NSScrollView {
                context.coordinator.createTextViewStack()
        }
        
        func updateNSView(_ nsView: NSScrollView, context: Context) {
                if let textArea = nsView.documentView as? NSTextView, textArea.string != self.text {
                        textArea.string = self.text
                }
        }
        
        func makeCoordinator() -> Coordinator {
                Coordinator(text: $text)
        }
        
        class Coordinator: NSObject, NSTextViewDelegate {
                var text: Binding<String>
                
                init(text: Binding<String>) {
                        self.text = text
                }
                
                func textView(_ textView: NSTextView, shouldChangeTextIn range: NSRange, replacementString text: String?) -> Bool {
                        defer {
                                self.text.wrappedValue = (textView.string as NSString).replacingCharacters(in: range, with: text!)
                        }
                        return true
                }
                
                fileprivate lazy var textStorage = NSTextStorage()
                fileprivate lazy var layoutManager = NSLayoutManager()
                fileprivate lazy var textContainer = NSTextContainer()
                fileprivate lazy var textView: NSTextView = NSTextView(frame: CGRect(), textContainer: textContainer)
                fileprivate lazy var scrollview = NSScrollView()
                
                func createTextViewStack() -> NSScrollView {
                        let contentSize = scrollview.contentSize
                        
                        textContainer.containerSize = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
                        textContainer.widthTracksTextView = true
                        
                        textView.minSize = CGSize(width: 0, height: 0)
                        textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
                        textView.isVerticallyResizable = true
                        textView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
                        textView.autoresizingMask = [.width]
                        textView.delegate = self
                        
                        scrollview.borderType = .noBorder
                        scrollview.hasVerticalScroller = true
                        scrollview.documentView = textView
                        
                        textStorage.addLayoutManager(layoutManager)
                        layoutManager.addTextContainer(textContainer)
                        
                        return scrollview
                }
        }
}
struct ServerView_Previews: PreviewProvider {
        static var previews: some View {
                ServerView()
        }
}
