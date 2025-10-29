//
//  StartPage.swift
//  Kiki
//
//  Created by Delvina J on 29/10/25.
//

import SwiftUI
import FoundationModels

struct StartPage: View {
    // Model Related
   
    @State var isUnderstanding: Bool = false
    @State var kikiCharacter: Kiki = Kiki(
        name: "Kiki",
        sex: .boy,
        interest: .car,
        nationality: .indonesian)
    @State var kidInterest: [String] = ["Car", "Cooking", "Dragon", "Video Game", "Play outside"]
    @State var kidNationality: [String] = ["Brazillian", "Korean", "Indonesia"]
    
    @State var selectedInterest: String = ""
    @State var selectedNationality: String = ""
    
    // Foundation Model Related
    @State var userAnswer: String = ""
    @State var session = LanguageModelSession()
    
    // UI Related
    @State var isShowingInspector: Bool = false
    @State private var messages: [MessageModel] = []
    
    
    var body: some View {
        VStack {
            switch SystemLanguageModel.default.availability {
            case .available:
                messagesList
                    .task {}
                    .toolbar {
                        ToolbarSpacer(.flexible)
                        ToolbarItem {
                            Button {
                                isShowingInspector.toggle()
                            } label: {
                                Image(systemName: "sidebar.trailing")
                            }
                            
                        }
                    }
                    .inspector(isPresented: $isShowingInspector) {
                        VStack(alignment: .leading) {
                            Text("Meet the kid!")
                                .font(.headline)
                                .padding(.bottom)
                            
                            HStack {
                                Text("Kid Name")
                                    .font(.callout)
                                TextField("", text: $kikiCharacter.name)
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading) {
                                Picker("Gender", selection: $kikiCharacter.sex) {
                                    Text("Male").tag(Sex.boy)
                                    Text("Female").tag(Sex.girl)
                                }
                            }.pickerStyle(.segmented)
                            
                            VStack(alignment: .leading) {
                                Picker("Interest", selection: $selectedInterest) {
                                    ForEach(kidInterest, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                            }.pickerStyle(.radioGroup)
                                .padding(.bottom)
                            
                            VStack(alignment: .leading) {
                                Picker("Nationality", selection: $selectedNationality) {
                                    ForEach(kidNationality, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                            }.pickerStyle(.radioGroup)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            TextField("Type your message here and press ⏎", text: $userAnswer)
                                .padding(5)
                                .textFieldStyle(.plain)
                                .padding(5)
                                .onSubmit {
                                    askTheChatbot()
                                }
                        }
                        .glassEffect(.regular.tint(.white).interactive())
                        .padding()
                    }
            case .unavailable(.deviceNotEligible):
                ContentUnavailableView("Apple Intelligence is not available for your device. Please buy a new iphone :)", systemImage: "exclamationmark.octagon")
                
            case .unavailable(.appleIntelligenceNotEnabled):
                VStack{
                    Text("Please enable Apple Intelligence in your Systems Settings")
                }
            case .unavailable(.modelNotReady):
                VStack {
                    Text("Your Apple Intelligence is not ready. Please come back after finished download")
                }
            case .unavailable(_):
                ContentUnavailableView("You are not permitted to use our app >:D", systemImage: "exclamationmark.octagon")
            }
        }
    }
    
    @ViewBuilder
    var messagesList: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                Group {
                    ForEach(messages, id: \.id) { msg in
                        if msg.type == .bot {
                            HStack {
                                MessagesBubble(
                                    text: msg.messages,
                                    date: msg.timeDate,
                                    color: Color.purple
                                ).padding(.leading)
                                Spacer(minLength:50)
                            }
                        } else {
                            HStack {
                                Spacer(minLength:50)
                                MessagesBubble(
                                    text: msg.messages,
                                    date: msg.timeDate,
                                    color: Color.indigo
                                ).padding(.trailing)
                            }
                        }
                    }
                    Spacer(minLength: 70)
                }
                .onAppear {
                    scrollToBottom(scrollView: scrollView)
                }
                .onChange(of: messages) {
                    scrollToBottom(scrollView: scrollView)
                }
                .scrollIndicators(.visible)
            }
        }
    }
}

extension StartPage {
    //MARK: Foundation Models func
    private func generate() async {
//        let options = GenerationOptions(sampling: .greedy,
//                                        temperature: temperature,
//                                        maximumResponseTokens: maximumResponseTokens)
        
        do {
            let response = try await session.respond(
                to: userAnswer
//                options: options
            )
            messages.append(
                MessageModel(messages: response.content,
                             type: .bot,
                             timeDate: formattedDateString(date: Date.now))
            )
            clearPrompt()
        } catch {
            print("response error")
        }
    }
    
    private func askTheChatbot() {
        messages.append(
            MessageModel(messages: userAnswer,
                         type: .user,
                         timeDate: formattedDateString(date: Date.now))
        )
        Task {
            await generate()
        }
    }
    
    private func clearPrompt() {
        userAnswer = ""
    }
    
    
    // UI Related
    private func scrollToBottom(scrollView: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation {
                scrollView.scrollTo(lastMessage, anchor: .bottom)
            }
        }
    }
    
    private func formattedDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // Example: "October 28, 2025"
        formatter.timeStyle = .short // Example: "4:41 PM"
        // Or, for a custom format:
        // formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}

#Preview {
    StartPage()
}

