import Foundation

// MARK: - Module 5: Local AI support framework for the Tree Hollow
// Rule-based local simulation with no network access, no psychological or medical diagnosis, and no judgment about fate or the future.

enum SafetyCopy {
    static let crisis = "If you are having thoughts of hurting yourself or cannot keep yourself safe, contact local emergency services or a crisis line immediately, or ask someone you trust to stay with you. You do not have to carry this moment alone."
    static let notDiagnosis = "This is emotional companionship and self-reflection. It is not psychological diagnosis or medical advice."
}

enum LocalAICompanion {
    static func reply(to text: String, snapshot: PersonalitySnapshot) -> LocalCompanionReply {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            return LocalCompanionReply(text: "I am here. Take your time. Even one or two words can help you set a little of this down.", followUp: "Where does your body feel tightest right now?", keyword: "Present")
        }

        if containsCrisisLanguage(cleaned) {
            return LocalCompanionReply(
                text: "I hear how painful this is right now. Please do not ask yourself to understand it all at once. \(SafetyCopy.crisis)",
                followUp: "Is there someone you can contact right now? Tell them you need company.",
                keyword: "Safety"
            )
        }

        let category = category(for: cleaned)
        let seed = "\(snapshot.signature)-\(cleaned)-\(DateKey.string(from: Date()))"
        let body = responseBody(for: category, seed: seed)
        let bloodLine = "Your \(snapshot.bloodType.displayName) nature brings out \(snapshot.bloodType.shortTrait). That is not fragility; it means you sense subtle changes more clearly."
        let westLine = "From the \(snapshot.westernZodiac.displayName) personality reference, your overthinking often begins with \(westernFriction(for: snapshot.westernZodiac)). Seeing this layer can help you stop placing every responsibility back on yourself."
        let chineseLine = "The \(snapshot.chineseZodiac.displayName) foundation carries a \(snapshot.chineseZodiac.shortTrait) strength. Use it for one very small act of self-care today."

        let textResponse = "\(body)\n\n\(bloodLine)\(westLine)\n\n\(chineseLine)"
        let followUp = followUpQuestion(for: category, seed: seed)
        let keyword = StableDigest.pick(keywords(for: category), seed: seed + "-keyword") ?? "Companionship"
        return LocalCompanionReply(text: textResponse, followUp: followUp, keyword: keyword)
    }

    private enum Category {
        case work, study, relationship, sleep, selfWorth, emptiness, health, general
    }

    private static func category(for text: String) -> Category {
        let categories: [(Category, [String])] = [
            (.health, ["pain", "sick", "symptom", "body", "hospital", "medicine"]),
            (.work, ["work", "overtime", "boss", "coworker", "office", "project", "layoff"]),
            (.study, ["exam", "study", "grade", "homework", "paper", "school"]),
            (.relationship, ["friend", "family", "parents", "relationship", "love", "breakup", "partner", "lonely"]),
            (.sleep, ["cannot sleep", "insomnia", "late night", "night", "sleep"]),
            (.selfWorth, ["useless", "blame myself", "failure", "not good enough", "hate myself", "awful"]),
            (.emptiness, ["empty", "lost", "pointless", "numb", "no direction"])
        ]
        for (category, words) in categories {
            if words.contains(where: { text.localizedCaseInsensitiveContains($0) }) {
                return category
            }
        }
        return .general
    }

    private static func responseBody(for category: Category, seed: String) -> String {
        let options: [String]
        switch category {
        case .work:
            options = [
                "It sounds like work has taken up a great deal of your attention, even during rest. We do not need to discuss how to become stronger first; today, take a little of yourself back from being always available.",
                "It is not that you are unwilling to try. After a long stretch of tension, your body is asking for a real pause. Speaking about the pressure does not mean your ability is lacking.",
                "The tiredness work creates is sometimes less about too many tasks and more about a boundary that never closes. Turning off notifications for a short while will not make the world collapse."
            ]
        case .study:
            options = [
                "Study pressure can make the result feel enormous and the present you feel very small. Your task today is not to prove everything, but to care for the person who is trying.",
                "You may be chasing a higher standard while rarely acknowledging what is already complete. Notice what you did today before deciding the next step.",
                "Anxiety does not mean you are not good enough; it means this matters to you. Make the important thing smaller so your mind has somewhere to land."
            ]
        case .relationship:
            options = [
                "Pain in a relationship often comes from 'I care deeply' and 'I am afraid to say it' existing at the same time. You do not have to swallow every hurt or explain everything in one conversation.",
                "You are good at understanding others, but understanding should not require disappearing. You can express one true need gently.",
                "Loneliness is sometimes not about having no one around, but about not being truly understood. Try naming the feeling more precisely, even if only to yourself."
            ]
        case .sleep:
            options = [
                "At night, feelings that were set aside during the day can become louder. You do not need to solve everything now; let your body receive a signal of safety first.",
                "The more you urge yourself to sleep, the more awake you may feel. It is okay to allow yourself to be awake for now and do something low-stimulation until sleep returns.",
                "A poor night's sleep does not mean your whole life is out of control. Lower the standard to 'a little rest still counts'."
            ]
        case .selfWorth:
            options = [
                "Your tone toward yourself may be harsher than the facts. Pause before turning a temporary difficulty into a conclusion about who you are.",
                "Self-blame is often a forceful way of hoping to improve, but improvement does not require hurting yourself. You can be honest with yourself and kind to yourself at the same time.",
                "What you need now is not more criticism, but a point from which to begin again. Completing even one small thing deserves acknowledgment."
            ]
        case .emptiness:
            options = [
                "Feeling empty or lost does not necessarily mean something is wrong with you. It may mean you have not heard your own preferences for a long time. Start with one very small sensation.",
                "Not every blank space needs to be filled immediately. Allow yourself to have no direction for a while; your body will slowly offer a clue.",
                "When life is only made of things you should do, enthusiasm leaves first. Give yourself one small thing today that has no purpose except that you want to do it."
            ]
        case .health:
            options = [
                "I hear your concern about your body. Emotional companionship cannot replace professional assessment. If discomfort persists or affects your daily life, contact a qualified medical professional promptly. For now, let us bring you back from repeated searching for three minutes.",
                "When worried about your body, it is easy to keep checking and drawing conclusions. You can record symptoms and timing and leave the assessment to a professional instead of carrying every possibility alone.",
                "First do one thing that brings you back to your body: drink water, sit down, feel your feet. Health worries deserve attention, but you do not need to keep guessing alone."
            ]
        case .general:
            options = [
                "Thank you for writing this down. Once a worry is named, it no longer has to sit only on your shoulders.",
                "I hear you. You do not need to find the correct answer immediately; first give your feeling a place without judgment.",
                "What you are experiencing deserves to be taken seriously, not brushed aside with 'just think positive'. We can work with only the next small step."
            ]
        }
        return StableDigest.pick(options, seed: seed + "-body") ?? options[0]
    }

    private static func followUpQuestion(for category: Category, seed: String) -> String {
        let options: [String]
        switch category {
        case .work:
            options = ["What work task can be clearly postponed or handed off today?", "If you gave yourself ten minutes away from work, what would you do?", "What do you need most right now: rest, support, or a clear boundary?"]
        case .study:
            options = ["What is the smallest thing you have already completed today?", "If you cut the goal in half, what would you do first?", "Who would you like to see your effort?"]
        case .relationship:
            options = ["If you were not afraid of damaging the relationship, what would you most want to say?", "What need in this relationship do you want to have seen?", "Who could you ask for a specific kind of company?"]
        case .sleep:
            options = ["Which unfinished task can you leave to tomorrow tonight?", "Which part of your body needs to relax first?", "What kind of sound would help you settle?"]
        case .selfWorth:
            options = ["If a friend were in your position, how would you comfort them?", "What happened today that shows you are not the way you described yourself?", "Which self-blame sentence could you replace with a more accurate description?"]
        case .emptiness:
            options = ["When did you last feel briefly interested in something?", "If usefulness were not required, what would you most want to do today?", "What five-minute experiment would you be willing to try for yourself?"]
        case .health:
            options = ["Would you write the worry down and consult a professional when appropriate?", "What concrete action would help you feel a little safer now?", "Who could help you process this worry?"]
        case .general:
            options = ["How would you most like to be understood right now?", "If you could care for only one feeling, which would you choose?", "Was there a moment today when you felt a little lighter?"]
        }
        return StableDigest.pick(options, seed: seed + "-followup") ?? options[0]
    }

    private static func keywords(for category: Category) -> [String] {
        switch category {
        case .work: return ["Boundaries", "Pause", "After hours"]
        case .study: return ["Break it down", "Permission", "Small steps"]
        case .relationship: return ["Expression", "Understood", "Closeness"]
        case .sleep: return ["Night", "Settling", "Blank space"]
        case .selfWorth: return ["Gentleness", "Seeing", "Restart"]
        case .emptiness: return ["Explore", "Sensation", "Open space"]
        case .health: return ["Ask for help", "Return to body", "Professional support"]
        case .general: return ["Listening", "Companionship", "This moment"]
        }
    }

    private static func westernFriction(for zodiac: WesternZodiac) -> String {
        PersonalityEngine.westernTriad(for: zodiac).rows.first(where: { $0.label == "Friction source" })?.content ?? "placing too much responsibility back on yourself"
    }

    private static func containsCrisisLanguage(_ text: String) -> Bool {
        let terms = ["kill myself", "suicide", "hurt myself", "self-harm", "end my life", "do not want to live", "want to die"]
        return terms.contains(where: { text.localizedCaseInsensitiveContains($0) })
    }
}