import Foundation

// MARK: - Module 4: Daily Emotional Almanac
// Generates only present-day emotional adaptation and daily decompression suggestions. It makes no judgment about the future or outcomes.

enum DailyContentEngine {
    static func starCalendar(for profile: UserProfile, date: Date = Date()) -> StarCalendar {
        let snapshot = profile.snapshot
        let dossier = PersonalityEngine.dossier(for: snapshot)
        let dayKey = DateKey.string(from: date)
        let seed = "\(snapshot.signature)-\(dayKey)-calendar"

        let relaxationIndex = 64 + StableDigest.index(seed + "-index", count: 31)
        let keyword = StableDigest.pick(keywords, seed: seed + "-keyword") ?? keywords[0]
        let frictionGuide = frictionGuide(for: snapshot, dossier: dossier, seed: seed + "-friction")
        let tasks = selectedTasks(seed: seed + "-tasks")
        let chineseReminder = "With the personality reference of the \(snapshot.chineseZodiac.displayName), you can lean into \(snapshot.chineseZodiac.shortTrait) today: place your attention on one small thing you can complete with your own hands, and do not rush to answer every voice."
        let strengthSuggestion = "Strength to use today: \(StableDigest.pick(dossier.dailyStrengths, seed: seed + "-strength") ?? dossier.dailyStrengths[0]). Its value is not to make you busier, but to help you feel more grounded in today."
        let bloodTip = bloodTip(for: snapshot.bloodType, seed: seed + "-blood")

        return StarCalendar(
            date: date,
            relaxationIndex: relaxationIndex,
            frictionGuide: frictionGuide,
            smallTasks: tasks,
            chineseReminder: chineseReminder,
            strengthSuggestion: strengthSuggestion,
            bloodTip: bloodTip,
            keyword: keyword,
            premiumReport: premiumReport(for: snapshot, dossier: dossier, seed: seed + "-premium", tasks: tasks)
        )
    }

    static func dateTitle(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM d · EEEE"
        return formatter.string(from: date)
    }

    static func shortDateTitle(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "M.d"
        return formatter.string(from: date)
    }

    private static func frictionGuide(for snapshot: PersonalitySnapshot, dossier: PersonalityDossier, seed: String) -> String {
        let westernFriction = dossier.western.rows.first(where: { $0.label == "Friction source" })?.content ?? "replaying the same thoughts inside your mind."
        let bloodWindow = dossier.blood.rows.first(where: { $0.label == "Emotional sensitivity" })?.content ?? "feelings arrive faster than words."
        let options = [
            "Today's overthinking-avoidance focus: when '\(westernFriction)' appears, do not jump to a conclusion about yourself. \(bloodWindow) You can write the feeling as one factual sentence, then decide whether action is needed.",
            "You do not need to understand every clue at once. Today, identify the loudest thought, give it one doable action, and let the rest wait until later.",
            "If your mind starts looping through comparisons, leave the comparison for three minutes. Look at one distant color, take a sip of water, and return to your own rhythm.",
            "Change 'I have to solve this now' to 'I can sit with it for a moment'. Emotions often loosen once they are allowed to exist."
        ]
        return StableDigest.pick(options, seed: seed) ?? options[0]
    }

    private static func selectedTasks(seed: String) -> [String] {
        var pool = [
            "Put one unrelated small object back in its place",
            "Listen to a familiar song from beginning to end",
            "Slowly drink a glass of warm water without looking at your phone",
            "Get up and walk for three minutes, then look out the window",
            "Write one sentence beginning with 'I already managed to...'",
            "Shrink the heaviest item on your list into a first step",
            "Inhale for four counts, exhale for six, and repeat five rounds",
            "Send one simple greeting to someone you trust"
        ]
        let firstIndex = StableDigest.index(seed + "-0", count: pool.count)
        let first = pool.remove(at: firstIndex)
        let secondIndex = StableDigest.index(seed + "-1", count: pool.count)
        let second = pool.remove(at: secondIndex)
        let third = pool[StableDigest.index(seed + "-2", count: pool.count)]
        return [first, second, third]
    }

    private static func bloodTip(for bloodType: BloodType, seed: String) -> String {
        let options: [String]
        switch bloodType {
        case .a:
            options = [
                "Type A care tip: set aside a period when you do not need to respond, and turn down the radar that watches over everyone else for a while.",
                "Type A care tip: when self-blame appears, repeat the thought using the tone you would use with a friend.",
                "Type A care tip: write unfinished tasks into an external list so your mind does not have to hold all of them."
            ]
        case .b:
            options = [
                "Type B care tip: say or write what you feel directly; do not let it circle inside your body.",
                "Type B care tip: allow yourself to change pace. Do the part that interests you first, then return to what needs patience.",
                "Type B care tip: after a lively period, take ten minutes alone. Quiet is not distance; it is recharging."
            ]
        case .ab:
            options = [
                "Type AB care tip: before analyzing rationally, give the feeling a name so your mind does not override your heart.",
                "Type AB care tip: choose only one answer that truly matters today; the other options can wait in storage.",
                "Type AB care tip: replace 'I am fine' with 'I need a little time', and let the relationship move closer to you."
            ]
        case .o:
            options = [
                "Type O care tip: before taking on a responsibility, ask, 'Does this truly have to be mine right now?'",
                "Type O care tip: trade forcing yourself through for a short rest. Recovering energy is not lowering your standards.",
                "Type O care tip: do one small, joyful thing entirely for yourself, with no productivity attached."
            ]
        }
        return StableDigest.pick(options, seed: seed) ?? options[0]
    }

    private static func premiumReport(
        for snapshot: PersonalitySnapshot,
        dossier: PersonalityDossier,
        seed: String,
        tasks: [String]
    ) -> PremiumReport {
        let bloodHidden = dossier.blood.rows.first(where: { $0.label == "Hidden nature" })?.content ?? ""
        let westernRelease = dossier.western.rows.first(where: { $0.label == "Relaxation style" })?.content ?? ""
        let chineseStrength = dossier.chinese.rows.first(where: { $0.label == "Personality strength" })?.content ?? ""
        let openingOptions = [
            "This report does not judge whether you are doing well or badly. It simply helps lay out today's three layers of feeling: which one needs to be seen, which one needs settling, and which one can wait.",
            "You can treat today as a gentle act of self-observation, not an exam that must produce an answer. The following is only a reference for your present rhythm.",
            "The point today is not to change your personality, but to give it a more comfortable place to land. Read slowly, and feel free to carry away only one sentence."
        ]
        let openings = StableDigest.pick(openingOptions, seed: seed + "-open") ?? openingOptions[0]

        let sections = [
            PremiumReportSection(
                title: "Emotional layers",
                body: "\(bloodHidden) Notice today whether your body is already tense when you say, 'I am fine.' There is no need to explain it right away. Lower your shoulders and give the feeling a place without judgment."
            ),
            PremiumReportSection(
                title: "Relationships and boundaries",
                body: "Your \(snapshot.westernZodiac.displayName) approach helps you value a \(snapshot.westernZodiac.shortTrait) rhythm. Practice one small boundary today: pause for three seconds before agreeing, and check whether the request is truly yours to carry."
            ),
            PremiumReportSection(
                title: "Strength and action",
                body: "\(chineseStrength) Apply this strength to one concrete action: \(tasks.first ?? "complete one small thing that takes ten minutes or less"). The action does not need to be grand; it only needs to remind you, 'I can care for myself.'"
            )
        ]

        return PremiumReport(
            title: "Your Emotional Care Book for Today",
            opening: openings,
            sections: sections,
            eveningRitual: "Evening close: \(westernRelease) Before bed, write today's unfinished matters into one sentence beginning with 'I will handle this tomorrow', then take three slow exhales."
            reflectionPrompt: "At what moment today did you most need to be understood? What would that sentence sound like if you said it more gently?"
        )
    }

    private static let keywords = [
        "Lightness", "Boundaries", "Slow down", "Understood", "Return to your body", "Blank space", "Self-care", "Clarity", "Flexibility", "Reassurance", "Restart", "Breath"
    ]
}