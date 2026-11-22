import Foundation

// MARK: - Module 3: Chinese-inspired healing wish slips
// The five themes provide present-moment comfort and self-encouragement only. They contain no fate, fortune, wealth, romance, or future-outcome claims.

private struct WishVerse {
    let line: String
    let interpretation: String
    let action: String
    let keyword: String
}

enum WishOracleEngine {
    static func reading(theme: WishTheme, profile: UserProfile, date: Date = Date()) -> WishReading {
        let snapshot = profile.snapshot
        let dossier = PersonalityEngine.dossier(for: snapshot)
        let seed = "\(snapshot.signature)-\(DateKey.string(from: date))-\(theme.rawValue)"
        let themeVerses = verses(for: theme)
        let verse = themeVerses[StableDigest.index(seed, count: themeVerses.count)]
        let number = StableDigest.index(seed + "-number", count: 88) + 1
        let chineseLine = dossier.chinese.rows.first(where: { $0.label == "Emotional soft spot" })?.content ?? ""
        let bloodLine = dossier.blood.rows.first(where: { $0.label == "Emotional sensitivity" })?.content ?? ""
        let westernLine = dossier.western.rows.first(where: { $0.label == "Relaxation style" })?.content ?? ""

        let interpretation = "\(verse.interpretation) Your personality combination brings together \(snapshot.bloodType.shortTrait), \(snapshot.westernZodiac.shortTrait), and \(snapshot.chineseZodiac.shortTrait): \(bloodLine) \(chineseLine) You have nothing to prove today; simply bring your attention back to yourself."
        let action = "\(verse.action) You can also try your personalized way to unwind: \(westernLine)"

        return WishReading(
            theme: theme,
            title: "\(theme.rawValue) · Today's Gentle Wish Slip \(String(format: "%02d", number))",
            verse: verse.line,
            interpretation: interpretation,
            gentleAction: action,
            keyword: verse.keyword,
            signature: snapshot.signature
        )
    }

    private static func verses(for theme: WishTheme) -> [WishVerse] {
        switch theme {
        case .calm:
            return [
                WishVerse(line: "The lake need not hurry; moonlight becomes clear on its own.", interpretation: "You do not need to flatten every ripple. Let the most urgent one slow first.", action: "Find a quiet place and take five longer exhales than usual.", keyword: "Clarity"),
                WishVerse(line: "Wind passes through bamboo; sound comes and goes.", interpretation: "A thought passing through you does not mean you must follow it.", action: "Write the loudest thought as a sentence from an observer's point of view.", keyword: "Observe"),
                WishVerse(line: "Even a small lamp can light the way home.", interpretation: "Reassurance does not always come from controlling everything. It comes from knowing where the next step is.", action: "Choose only one small thing to do in the next ten minutes.", keyword: "Glimmer"),
                WishVerse(line: "Clouds rest on the water; the water remains calm.", interpretation: "Allowing something to remain unresolved gives your heart room to buffer.", action: "Put one unsolved problem in a box marked 'later'.", keyword: "Space")
            ]
        case .heal:
            return [
                WishVerse(line: "A spring shoot is silent and still growing.", interpretation: "Recovery is quiet and does not need obvious progress every day.", action: "Notice one moment today that feels lighter than yesterday.", keyword: "Sprout"),
                WishVerse(line: "Old wounds leave marks; the heart still turns toward light.", interpretation: "The past can leave traces without being responsible for defining all of you.", action: "Tell yourself, 'I did what I could then.'", keyword: "Reconcile"),
                WishVerse(line: "After the rain, dew still rests on the leaves.", interpretation: "When emotion recedes, your body may need a little more time to catch up.", action: "Pour yourself a glass of warm water and drink it slowly.", keyword: "Afterglow"),
                WishVerse(line: "Leave the cracks open to the light.", interpretation: "You do not have to become whole before you deserve gentleness.", action: "Criticize yourself one time less today and replace it with one specific affirmation.", keyword: "Acceptance")
            ]
        case .ease:
            return [
                WishVerse(line: "A little slower; the road is still here.", interpretation: "Ease is not giving up standards; it is no longer rushing yourself in a way that hurts.", action: "Remove one item from today's list and keep only what truly matters.", keyword: "Blank space"),
                WishVerse(line: "Relax your shoulders and the world grows wider.", interpretation: "When your body relaxes, the knot in your emotions loosens a little too.", action: "Drop your shoulders, unclench your jaw, and take three natural breaths.", keyword: "Release"),
                WishVerse(line: "Half a cup of tea is enough to warm your hands.", interpretation: "Nourishment does not require a grand ritual. A little is enough.", action: "Spend five minutes on something with no purpose.", keyword: "Just enough"),
                WishVerse(line: "When you stop rushing, you can see the flowers.", interpretation: "You do not have to be productive all the time in order to be worthy of affection.", action: "Set aside time today that has no output and no check-in.", keyword: "At ease")
            ]
        case .flow:
            return [
                WishVerse(line: "Water finds its way around the stone.", interpretation: "Direction is not one decision; it is slowly calibrated through movement.", action: "Write the goal as a next step rather than a final answer.", keyword: "Go with the flow"),
                WishVerse(line: "One step, one breath, all part of moving forward.", interpretation: "The small things you complete today are building a sense of steadiness.", action: "Choose one thing you can finish in ten minutes, then stop when it is done.", keyword: "Forward"),
                WishVerse(line: "The wind has a place it comes from and a place it goes.", interpretation: "This pause is not a step backward; it is part of the rhythm.", action: "Complete the lightest action first, then observe the next step.", keyword: "Rhythm"),
                WishVerse(line: "The mountain does not rush; the water does not hurry.", interpretation: "You can rearrange your life at your own speed.", action: "Set a 'good enough' finish line for today.", keyword: "Composure")
            ]
        case .tender:
            return [
                WishVerse(line: "Give gentleness to yourself first.", interpretation: "You are so good at caring for others; today you can put yourself on the list of people to care for.", action: "Comfort yourself in the tone a friend would use with you.", keyword: "Self-kindness"),
                WishVerse(line: "May you have a soft heart and a steady shield.", interpretation: "Sensitivity is not a flaw. It helps you notice subtle things and also means you need boundaries.", action: "Say no gently and clearly to one thing you do not want to take on.", keyword: "Boundaries"),
                WishVerse(line: "The moon does not need to be full every night.", interpretation: "You do not need to be at your best every day in order to be valuable.", action: "Allow one unfinished item today and blame yourself one time less for it.", keyword: "Permission"),
                WishVerse(line: "Even a tender heart needs a shore to rest on.", interpretation: "You do not only need to keep holding on; you can actively look for support.", action: "Tell someone you trust, 'Could you listen to me for a little while today?'", keyword: "Safe shore")
            ]
        }
    }
}