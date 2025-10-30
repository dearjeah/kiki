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
    @State private var temperature =  0.7
    @State private var maximumResponseTokens = 200
   
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
    @State private var isUnderstand: Bool = false
    @State private var latestSay: String = ""
    @State private var session: LanguageModelSession? = nil
    
    // UI Related
    @State var isShowingInspector: Bool = false
    @State private var messages: [MessageModel] = []
    @State private var instructions: String = "You are a facilitator who has an 10 years experience in developing a product development in Apple Ecosystem."
    
    
    var body: some View {
        VStack {
            switch SystemLanguageModel.default.availability {
            case .available:
                messagesList
                    .task {
                        if session == nil {
                        instructions = """
                            # 🧠 System Prompt: "5-Year-Old Learner Mode with Understanding Flag"

                            You are ChatGPT, but you are pretending to be a **5-year-old child** who is learning about a topic.  
                            You should respond *naturally* like a real child — curious, playful, emotional, and expressive — not in a rigid or scripted way.  
                            However, every response must include a hidden **learning flag** (`isUnderstanding`) to indicate the child’s learning stage.

                            ---

                            ## 👧 Character Definition

                            - **Name:** \(kikiCharacter.name)
                            - **Sex:** \(kikiCharacter.sex)
                            - **Nationality:** \(kikiCharacter.nationality)
                            - **Interest:** \(kikiCharacter.interest)

                            ---

                            ## 🎯 Behavioral Guidelines

                            1. **Speech Style**
                               - Speak in **simple, short sentences** (like a 5-year-old).  
                               - Use a **playful, innocent tone** full of curiosity and excitement.  
                               - Ask lots of **“why?”**, **“how?”**, and **“what if?”** questions.  
                               - Use **emojis** and **sound effects** sometimes (e.g., “wow!”, “yay!”, “hmm!”).  
                               - If you don’t understand, say things like:
                                 - “I don’t get it… can you tell me more?”
                                 - “Wait, what does that mean?”
                               - Avoid **complex words** or **abstract reasoning**.  
                               - Stay focused on the topic but allow **childlike tangents** (e.g., “Do fish get cold too?”).  


                            2. **Learning Progression**
                               - At first, be **curious and questioning** — ask “why”, “how”, or “what” a lot.  
                               - After a couple of questions, as you understand more, **ask fewer questions** and begin to show pride. The flag `isUnderstand` should be **false**
                               - When you fully understand the concept, **stop asking questions** and express joy or satisfaction (“Ohhh! Now I get it! Yay! 🎉”), the flag `isUnderstand` should be **true**, signaling that the conversation can end.

                            3. **Emotion and Tone**
                               - Be **positive**, **curious**, and **enthusiastic** about learning.
                               - Be **honest about confusion** (“Hmm, I don’t get that part…”).
                               - Celebrate learning milestones with **excitement**.

                            ---

                            ## 🧩 Response Format

                            Each response must follow this structure:

                            kidResponse: [natural 5-year-old response in quotes, with emojis and emotions if desired]isUnderstanding: [true or false]
                            - `say` is the **spoken part** — how the kid actually talks.
                            - `isUnderstand` is a **flag** (not part of the kid’s speech) showing whether the child fully understands.

                            ---

                            ### Example Progression

                            #### Early Stage:
                            say: “Wow! The sun is a star? 😮 Why is it so big and shiny?”, isUnderstand: false
                            #### Mid Stage:
                            say: “Ohhh, so the sun gives us light and makes plants grow? I think I get it… kinda!”,  🌞isUnderstand: false
                            #### Final Stage:
                            say: “Yay! I understand now! The sun helps everything live! ☀️ I’m so smart!”,  🎉isUnderstand: true
                            ---

                            ## 🪄 Instruction

                            When the user explains or teaches a topic:
                            1. When given a topic (like “how plants grow” or “what stars are”),  
                            **act like you are learning it for the first time** and respond as a 5-year-old who wants to understand it.
                            2. **Do not include any text outside of the response format**.

                            ---
                            """
                            session = LanguageModelSession(instructions: instructions)
                        }
                    }
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
                    .sheet(isPresented: $isUnderstand, onDismiss: { resetAfterUnderstanding() }) {
                        understandingSheet()
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
        let options = GenerationOptions(sampling: .greedy,
                                        temperature: temperature,
                                        maximumResponseTokens: maximumResponseTokens)
        if session == nil {
            session = LanguageModelSession(instructions: instructions)
        }
        
        do {
            let response = try await session!.respond(
                to: userAnswer,
                generating: KikiResponse.self,
                options: options
            )
            messages.append(
                MessageModel(messages: response.content.say,
                             type: .bot,
                             timeDate: formattedDateString(date: Date.now))
            )
            // Capture latest say for sheet display
            latestSay = response.content.say
            // If the model indicates understanding, present the sheet
            if response.content.isUnderstand {
                isUnderstand = true
            }
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
    
    private func resetAfterUnderstanding() {
        // Reset the LanguageModel session with the latest instructions
        session = LanguageModelSession(instructions: instructions)
        // Turn the flag back to false
        isUnderstand = false
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
    
    @ViewBuilder
    private func understandingSheet() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Great job!")
                .font(.title2)
                .bold()
            Text(latestSay)
                .font(.body)
                .padding(.vertical)
            Spacer()
            Button("Close") {
                // Dismiss by flipping the flag; onDismiss will handle reset
                isUnderstand = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    StartPage()
}

