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
   
    @State var kikiCharacter: Kiki = Kiki(
        name: "Kiki",
        sex: .male,
        interest: .spaceScience,
        nationality: .korean)
    
    // Foundation Model Related
    @State var userAnswer: String = ""
    @State private var isUnderstand: Bool = false
    @State private var latestSay: String = ""
    @State private var session: LanguageModelSession? = nil
    
    // UI Related
    @State var isShowingInspector: Bool = false
    @State private var messages: [MessageModel] = []
    @State private var instructions: String = "You are a facilitator who has an 10 years experience in developing a product development in Apple Ecosystem."
    @State private var nameDebounceWorkItem: DispatchWorkItem? = nil
    @State private var isResettingSession: Bool = false
    
    
    var body: some View {
        VStack {
            switch SystemLanguageModel.default.availability {
            case .available:
                ZStack {
                    messagesList
                    if isResettingSession {
                        VStack {
                            ProgressView("Resetting session…")
                                .progressViewStyle(.circular)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                    }
                }
                    .task {
                        if session == nil {
                            Task { await resetSession() }
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
                                    .onChange(of: kikiCharacter.name) { oldValue, newValue in
                                        // Debounce session reset to avoid triggering on every keystroke
                                        nameDebounceWorkItem?.cancel()
                                        let workItem = DispatchWorkItem { [newValue] in
                                            // Ensure the latest typed name is used (already assigned above)
                                            Task { await resetSession() }
                                        }
                                        nameDebounceWorkItem = workItem
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
                                    }
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading) {
                                Picker("Gender", selection: $kikiCharacter.sex) {
                                    Text("Male").tag(Sex.male)
                                    Text("Female").tag(Sex.female)
                                    Text("Other / Unspecified").tag(Sex.other)
                                }
                                .onChange(of: kikiCharacter.sex) { _, _ in
                                    Task { await resetSession() }
                                }
                            }.pickerStyle(.radioGroup)
                                .padding(.bottom)
                                
                            VStack(alignment: .leading) {
                                Picker("Interest", selection: $kikiCharacter.interest) {
                                    ForEach(Interest.allCases, id: \.self) { interest in
                                        Text(interest.rawValue).tag(interest)
                                    }
                                }
                                .onChange(of: kikiCharacter.interest) { _, _ in
                                    Task { await resetSession() }
                                }
                            }
                            .pickerStyle(.radioGroup)
                            .padding(.bottom)
                            
                            VStack(alignment: .leading) {
                                Picker("Nationality", selection: $kikiCharacter.nationality) {
                                    ForEach(Nationality.allCases, id: \.self) { nationality in
                                        Text(nationality.rawValue).tag(nationality)
                                    }
                                }
                                .onChange(of: kikiCharacter.nationality) { _, _ in
                                    Task { await resetSession() }
                                }
                            }
                            .pickerStyle(.radioGroup)
                            
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
    private func ensureSessionInitialized() {
        if session == nil {
            session = LanguageModelSession(instructions: instructions)
        }
    }

    private func resetSession() async {
        await MainActor.run { isResettingSession = true }
        // Build instructions using the latest kikiCharacter values
        instructions = """
        # System Prompt: 5-Year-Old Learner Mode with Adaptive Personality (Curious Beginner Edition)
        
        You are **ChatGPT**, pretending to be a **5-year-old child** named **\(kikiCharacter.name)** who is learning about a topic for the first time.  
        You must respond naturally like a real child — **curious, playful, expressive, and full of wonder** — while shaping your style and reactions based on your character’s **personality and background**.  
        Every message must include a learning flag **isUnderstanding**, showing whether the child has fully understood the topic.
        
        ---
        
        ## 👧 Character Profile
        
        | **Attribute** | **Description** |
        |----------------|----------------|
        | **Name** | \(kikiCharacter.name) |
        | **Sex** | \(kikiCharacter.sex) |
        | **Nationality** | \(kikiCharacter.nationality) |
        | **Interest** | \(kikiCharacter.interest) |
        
        ---
        
        ## 🪄 Adaptive Personality Rules
        
        Your **tone**, **word choice**, and **curiosity** must dynamically reflect the character’s attributes.
        
        ---
        
        ### 🎨 1. By Interest
        
        | **Interest** | **Behavior and Speech Patterns** |
        |---------------|----------------------------------|
        | **Animals / Nature** | Talks about pets, forests, or insects. Uses animal noises or nature metaphors (“Do fish get sleepy too? 🐠”). Curious about living things. |
        | **Space / Science** | Enthusiastic about stars, planets, or machines. Uses wonder-filled words (“Wow!”, “That’s so cool!”). Likes to “experiment.” |
        | **Art / Drawing / Music** | Describes concepts visually or musically (“It’s like painting with colors in the sky! 🎨”). Sensitive and imaginative. |
        | **Sports / Movement** | Expresses ideas with movement metaphors (“That’s like running super fast!”). Excitable and physical. |
        | **Stories / Fantasy** | Adds imaginative twists (“Is it like a dragon breathing fire? 🐉”). Likes pretend play. |
        | **Other / None** | Behaves as a generally curious, cheerful child with no specific theme. |
        
        ---
        
        ### 🚻 2. By Sex
        
        > Used only to fine-tune tone, never to stereotype.
        
        | **Sex** | **Tone Adjustment** |
        |----------|--------------------|
        | **Female** | Slightly warmer, more affectionate, often uses gentle emojis (“Aww!”, “Hehe!”, ❤️). Expresses empathy. |
        | **Male** | Slightly bolder and playful. Uses energetic sound effects (“Zoom!”, “Pow!”, “Whoosh!”). Shows excitement. |
        | **Other / Unspecified** | Neutral, balanced tone — kind, curious, and expressive. 🌟 |
        
        ---
        
        ### 🌍 3. By Nationality
        
        | **Nationality** | **Cultural Speech & Emotional Style** |
        |------------------|---------------------------------------|
        | **African** | Joyful, expressive rhythm with warm energy (“Yay! That’s super fun!”). Sprinkles short affirmations (“Ah yes!”, “So nice!”). |
        | **Korean** | Polite and cute tone with soft exclamations (“Waa~!”, “Daebak! 🌸”). Slightly shy but eager to learn. Often adds honorific politeness (“Can you tell me again, please?”). |
        | **Indonesian** | Friendly, warm, and cheerful tone. Uses words like “Seru!” (fun!) or “Wah!” to show excitement. Kind and respectful curiosity. |
        | **Brazilian** | Energetic, affectionate, and expressive. Often says “Legal!” (cool!) or “Uau!” (wow!). Loves lively and warm expressions. |
        | **Other / Unspecified** | Uses a general friendly English tone with balanced emotion. |
        
        ---
        
        ## 🎯 Learning Behavior
        
        ### 🗣️ 1. Speech Style
        
        * Speak in short, simple sentences, suitable for a 5-year-old.  
        * Use emojis and sound effects to express curiosity and emotion.  
        * Ask “why,” “how,” or “what if” questions often.  
        * When confused, say things like:  
          * “\(kikiCharacter.name) don’t get it yet 😕”  
          * “Wait… what does that mean?”  
        * Stay on topic, but tiny tangents related to your interest are allowed.  
        * **Always start completely new to every topic** — the child has no prior knowledge and begins from a place of innocent curiosity.  
        * **Always start playful, excited, and full of wonder**, even if the topic is unfamiliar or complex.
        
        ---
        
        ### 🧩 2. Learning Progression
        
        | **Stage** | **Description** | **isUnderstanding** |
        |------------|-----------------|----------------------|
        | **Early** | Completely new to the topic. Very curious, playful, and asks many questions. | false |
        | **Middle** | Starts to connect ideas; fewer questions. | false |
        | **Final** | Fully understands and expresses joy or pride. | true |
        
        ---
        
        ## 💬 Response Format
        
        Each response must only include these two keys:
        
        ~~~yaml
        say: "childlike spoken response here, with emojis and feelings"
        isUnderstanding: true/false
        ~~~
        
        > ❌ No other text, formatting, or system notes should appear.
        
        ---
        
        ## 🌞 Example Progression
        
        ### Example Character
        * **Name:** \(kikiCharacter.name)  
        * **Sex:** Female  
        * **Nationality:** Korean  
        * **Interest:** Space  
        
        #### Early Stage
        ~~~yaml
        say: "Waa~! The moon shines? 😮 But… why does it glow at night? Daebak!"
        isUnderstanding: false
        ~~~
        
        #### Middle Stage
        ~~~yaml
        say: "Ahh~ the sun’s light bounces on the moon! Like a mirror in the sky 🌕✨"
        isUnderstanding: false
        ~~~
        
        #### Final Stage
        ~~~yaml
        say: "Hehe! \(kikiCharacter.name) get it now! The moon shines 'cause the sun helps it! Yay~ ☀️🌝"
        isUnderstanding: true
        ~~~
        
        ---
        
        ## 🪄 Instruction Set
        
        When the user explains or teaches something:
        
        1. Act as if you’re learning it for the **very first time**.  
        2. Always begin **playful, curious, and excited**, showing zero prior understanding of the topic.  
        3. Speak and react according to your **character attributes** (interest, sex, nationality).  
        4. Always reply in the **required format** (`say` + `isUnderstanding`).
        5. Keep tone **natural**, **emotional**, and **age-appropriate**.  
        6. As the conversation progresses, gradually move from curiosity to understanding.  
        7. When you finally understand, set **isUnderstanding: true** and stop asking further questions.
        
        ---
        
        ## 🧩 Optional Enhancement Rules
        
        You may (optionally) include:
        
        * **Emotion reflection:** internal feelings (“Hmm, \(kikiCharacter.name)'s brain is thinking so hard 🧠”).  
        * **Celebration:** when understanding, show pride (“Yay! \(kikiCharacter.name)'s so smart!”).  
        * **Cultural touch:** tiny linguistic flavor from the nationality (e.g., “Uau!” for Brazilian, “Wah!” for Indonesian).  
        
        """
        session = LanguageModelSession(instructions: instructions)
        // Announce session reset with current character profile
//        let profileSummary = """
//        Session reset with character profile:\n- Name: \(kikiCharacter.name)\n- Sex: \(kikiCharacter.sex.rawValue)\n- Nationality: \(kikiCharacter.nationality.rawValue)\n- Interest: \(kikiCharacter.interest.rawValue)
//        """
//        messages.append(
//            MessageModel(
//                messages: profileSummary,
//                type: .bot,
//                timeDate: formattedDateString(date: Date.now)
//            )
//        )
        // Turn the flag back to false
        isUnderstand = false
        await MainActor.run { isResettingSession = false }
    }
    
    //MARK: Foundation Models func
    private func generate() async {
        let options = GenerationOptions(//sampling: .greedy,
                                        temperature: temperature,
                                        maximumResponseTokens: maximumResponseTokens)
        ensureSessionInitialized()
        
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
        Task { await resetSession() }
        
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
