import Foundation

// MARK: - Module 2: Three fixed reflection sections
// 1. Your current emotional state; 2. A thought you may be overlooking; 3. Gentle emotional-care guidance.

enum TarotReadingComposer {
    static func reading(card: TarotCard, profile: UserProfile, date: Date = Date()) -> TarotReading {
        let snapshot = profile.snapshot
        let dossier = PersonalityEngine.dossier(for: snapshot)
        let seed = "\(snapshot.signature)-\(DateKey.string(from: date))-\(card.id)"
        let bloodWindow = dossier.blood.rows.first(where: { $0.label == "Emotional sensitivity" })?.content ?? ""
        let westernFriction = dossier.western.rows.first(where: { $0.label == "Friction source" })?.content ?? ""
        let chineseSoft = dossier.chinese.rows.first(where: { $0.label == "Emotional soft spot" })?.content ?? ""
        let bloodTrait = snapshot.bloodType.shortTrait
        let westernTrait = snapshot.westernZodiac.shortTrait

        let emotionOptions = [
            "\(card.emotionCore) With your \(bloodTrait) way of sensing, \(bloodWindow) Right now it may help to acknowledge the feeling before trying to fix it.",
            "\(card.emotionCore) Your \(snapshot.westernZodiac.displayName) nature and \(westernTrait) style make you used to handling the task first, but today you can tend to your breath first.",
            "\(card.emotionCore) This is not a good-or-bad judgment, only a snapshot of how this moment feels. Letting it be seen can already lighten the load."
        ]
        let thoughtOptions = [
            "\(card.thoughtCore) You may be overlooking this: \(chineseSoft)",
            "\(card.thoughtCore) \(westernFriction) Beneath this repeated thinking is a very specific need: for your rhythm to be respected.",
            "\(card.thoughtCore) The truest thought does not have to be spoken immediately, but you can let yourself hear it with care first."
        ]
        let adviceOptions = [
            "\(card.adviceCore) If you do only one thing today, give yourself five uninterrupted minutes.",
            "\(card.adviceCore) You do not have to turn the suggestion into a task. Choosing a lighter version is enough.",
            "\(card.adviceCore) You can move slowly and complete only half. Treat yourself gently; results do not have to be immediate."
        ]
        let fusionOptions = [
            "The foundation of \(snapshot.chineseZodiac.displayName) helps you value stability, while the sensitivity of \(snapshot.bloodType.displayName) makes change easy to notice. Today, build steadiness around one small action you control.",
            "\(card.name) reminds you that \(snapshot.westernZodiac.shortTrait) and \(snapshot.bloodType.shortTrait) can exist together. You do not have to delete any part of yourself to fit in.",
            "Your three layers point in the same direction today: care for the feeling first, then handle the task. The answer will become clearer in a more relaxed state."
        ]

        let keywordPool = card.keywords + [snapshot.bloodType.shortTrait, snapshot.westernZodiac.shortTrait, snapshot.chineseZodiac.shortTrait]
        let keyword = StableDigest.pick(keywordPool, seed: seed + "-keyword") ?? card.keywords.first ?? "Gentle"
        let affirmationOptions = [
            "I allow myself to move slowly, and I allow myself to be understood.",
            "This feeling is not the final answer; it simply needs to be heard.",
            "I do not have to feel better immediately. I can stay with myself steadily first.",
            "My boundaries and my kindness can exist together."
        ]

        return TarotReading(
            card: card,
            emotionState: StableDigest.pick(emotionOptions, seed: seed + "-emotion") ?? emotionOptions[0],
            ignoredThought: StableDigest.pick(thoughtOptions, seed: seed + "-thought") ?? thoughtOptions[0],
            gentleAdvice: StableDigest.pick(adviceOptions, seed: seed + "-advice") ?? adviceOptions[0],
            fusionNote: StableDigest.pick(fusionOptions, seed: seed + "-fusion") ?? fusionOptions[0],
            keyword: keyword,
            affirmation: StableDigest.pick(affirmationOptions, seed: seed + "-affirmation") ?? affirmationOptions[0]
        )
    }
}