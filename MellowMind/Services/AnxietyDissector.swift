import Foundation

// MARK: - Module 5: Anxiety Sorter
// Sorts a worry into present-focused sources of strain and gentle actions; it does not diagnose or predict outcomes.

enum AnxietyDissector {
    static func analyze(worry: String, profile: UserProfile) -> AnxietyAnalysis {
        let cleaned = worry.trimmingCharacters(in: .whitespacesAndNewlines)
        let snapshot = profile.snapshot
        let dossier = PersonalityEngine.dossier(for: snapshot)
        let seed = "\(snapshot.signature)-\(cleaned)-\(DateKey.string(from: Date()))"
        let category = category(for: cleaned)
        let hasHealthConcern = ["pain", "sick", "symptom", "body", "hospital", "checkup"].contains(where: { cleaned.localizedCaseInsensitiveContains($0) })
        let bloodWindow = dossier.blood.rows.first(where: { $0.label == "Emotional sensitivity" })?.content ?? ""
        let westernFriction = dossier.western.rows.first(where: { $0.label == "Friction source" })?.content ?? ""
        let chineseSoft = dossier.chinese.rows.first(where: { $0.label == "Emotional soft spot" })?.content ?? ""

        let roots = [
            AnxietyRoot(title: "\(snapshot.westernZodiac.displayName) thinking pattern", detail: "\(westernFriction) This can make your mind rehearse ahead in search of certainty."),
            AnxietyRoot(title: "\(snapshot.bloodType.displayName) emotional reception", detail: "\(bloodWindow) What you pick up may include not only your own feelings, but also tension in the environment and relationships."),
            AnxietyRoot(title: "\(snapshot.chineseZodiac.displayName) sense of responsibility", detail: "\(chineseSoft) You often place 'I must be responsible' before 'I need rest'.")
        ]

        let stateOptions = [
            "The loudest part of this worry may not be the situation itself, but the demand that you must handle it as soon as possible.",
            "You are checking details repeatedly in search of an answer that cannot go wrong. Underneath is a wish for steadiness.",
            "There is visible strain in your words: part of you wants to solve it, while another part blames you for not being able to."
        ]
        let explanationOptions = [
            "Separate three things: what has actually happened, how you are interpreting it, and the next step available to you now. Separating them can reduce one layer of strain.",
            "Anxiety often turns 'maybe' into 'certainly'. You do not have to argue with it today; simply rewrite the sentence as 'What I am worried about is..., and what I know for now is...'.",
            "You are not thinking too much; your feeling system is trying to protect you. Protection also needs boundaries and cannot work overtime forever."
        ]
        let healthAppendix = hasHealthConcern ? " You mentioned something related to your body or health. No medical judgment is made here. If discomfort continues, worsens, or affects daily life, please consult a qualified medical professional." : ""

        let plan: [String]
        switch category {
        case .work:
            plan = ["Write down one thing that must be done today and two things that can wait.", "Mute work notifications for one specific period.", "Tell someone you trust in one sentence what kind of support you need."]
        case .study:
            plan = ["Reduce the current goal to one twenty-minute study block.", "When it is done, write what you completed rather than how much remains.", "Set a stop time for studying tonight so recovery is part of the plan too."]
        case .relationship:
            plan = ["Write the sentence you want to be understood, without rushing to send it.", "Separate the other person's behavior from your judgment of yourself.", "Choose one safe person and make a specific request for company."]
        case .sleep:
            plan = ["Write tomorrow's first small task on paper and leave it for tomorrow.", "Inhale for four counts, exhale for six, and repeat five rounds.", "If you are still awake, allow yourself a low-stimulation audio session instead of more scrolling."]
        case .selfWorth:
            plan = ["Rewrite 'I am not good enough' as 'I am having a hard time right now'.", "Find one concrete thing you completed today.", "Comfort yourself in the tone you would use with a friend."]
        case .emptiness:
            plan = ["Try one small sensory experiment: notice a scent or touch a texture.", "Make five minutes of purposeless time for today.", "Record one moment that made you slightly curious."]
        case .health:
            plan = ["Record symptoms, duration, and triggers instead of repeatedly searching for conclusions.", "Book an appointment or consult a qualified medical professional at an appropriate time.", "Drink a little water now and bring your attention to your feet for three minutes."]
        case .general:
            plan = ["Write one sentence each for the fact, the guess, and the feeling.", "Choose only one small action you can complete today.", "Give yourself ten minutes where you do not solve anything."]
        }

        let keyword = StableDigest.pick(["Break it down", "Boundaries", "Return to now", "Permission", "Ask for help", "Breath", "One certain thing"], seed: seed + "-keyword") ?? "Break it down"
        let affirmation = StableDigest.pick([
            "I can handle one thing at a time.",
            "I allow uncertainty, and I allow myself to ask for help.",
            "My feeling is not a diagnosis; it is a signal that I need care.",
            "I can finish today first and think about tomorrow more slowly."
        ], seed: seed + "-affirmation") ?? "I can handle one thing at a time."

        return AnxietyAnalysis(
            worry: cleaned,
            currentState: (StableDigest.pick(stateOptions, seed: seed + "-state") ?? stateOptions[0]) + healthAppendix,
            roots: roots,
            gentleExplanation: StableDigest.pick(explanationOptions, seed: seed + "-explain") ?? explanationOptions[0],
            actionPlan: plan,
            grounding: "Place both feet flat. Inhale for four counts and exhale for six. As you exhale, imagine your shoulders sinking. Repeat five rounds. If you feel unwell, stop and rest."
            affirmation: affirmation,
            keyword: keyword,
            signature: snapshot.signature
        )
    }

    private enum Category { case work, study, relationship, sleep, selfWorth, emptiness, health, general }

    private static func category(for text: String) -> Category {
        let list: [(Category, [String])] = [
            (.health, ["pain", "sick", "symptom", "body", "hospital", "checkup"]),
            (.work, ["work", "overtime", "boss", "coworker", "project", "layoff"]),
            (.study, ["exam", "study", "grade", "paper", "homework"]),
            (.relationship, ["relationship", "friend", "family", "parents", "love", "breakup", "lonely"]),
            (.sleep, ["cannot sleep", "insomnia", "late night", "sleep"]),
            (.selfWorth, ["useless", "blame myself", "failure", "not good enough"]),
            (.emptiness, ["empty", "lost", "numb", "no direction"])
        ]
        for (category, words) in list where words.contains(where: { text.localizedCaseInsensitiveContains($0) }) {
            return category
        }
        return .general
    }
}