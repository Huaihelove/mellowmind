import Foundation

// MARK: - Module 1: Blood type + Western zodiac + Chinese zodiac personality profile

enum PersonalityEngine {
    static func dossier(for profile: UserProfile) -> PersonalityDossier {
        dossier(for: profile.snapshot)
    }

    static func dossier(for snapshot: PersonalitySnapshot) -> PersonalityDossier {
        let blood = bloodTriad(for: snapshot.bloodType)
        let western = westernTriad(for: snapshot.westernZodiac)
        let chinese = chineseTriad(for: snapshot.chineseZodiac)
        let seed = snapshot.signature

        let fusionOptions = [
            "\(snapshot.chineseZodiac.shortTrait) is your natural foundation. \(snapshot.westernZodiac.shortTrait) is the rhythm you bring to the world, and \(snapshot.bloodType.shortTrait) helps you stay sensitive in relationships. Together they read like a light that is soft outside and bright within: observe first, move closer, then respond with care.",
            "Your \(snapshot.chineseZodiac.shortTrait) gives you a steady inner tone, \(snapshot.westernZodiac.shortTrait) helps you find your own method in change, and \(snapshot.bloodType.shortTrait) gives you a fine awareness of other people's emotions. You do not have to be strong all the time; letting yourself be supported is also a skill.",
            "The sensitivity of \(snapshot.bloodType.shortTrait) meets the approach of \(snapshot.westernZodiac.shortTrait), and is held by the foundation of \(snapshot.chineseZodiac.shortTrait). Together they form your own gentle order. You are good at making confusion clear, but remember to put yourself back on the list too.",
            "You carry a quiet strength woven from \(snapshot.chineseZodiac.shortTrait) and \(snapshot.bloodType.shortTrait), while \(snapshot.westernZodiac.shortTrait) opens a window for it. When overthinking appears, it is not a lack of effort; your feeling system is simply more finely tuned and needs a softer pace.",
            "\(snapshot.westernZodiac.shortTrait) leads you to meet the world in your own way, \(snapshot.bloodType.shortTrait) helps you read the small details in the air, and \(snapshot.chineseZodiac.shortTrait) reminds you that stability does not come from controlling everything. It comes from knowing you can slow down.",
            "With \(snapshot.chineseZodiac.shortTrait), you often put responsibility first; \(snapshot.westernZodiac.shortTrait) makes you want to do things gracefully; and \(snapshot.bloodType.shortTrait) lets you notice even another person's silence. Today, move a little attention from 'I should' back to 'I need'.",
        ]

        let strengths = [
            "Break something complex into one clear, small step",
            "Offer the right response when someone is feeling low",
            "Notice subtle changes before they become bigger problems",
            "Bring a gentle order to ordinary days",
            "Keep your own judgment under pressure",
            "Build reassuring relationships through sincerity",
            "Care for the most important feeling first when things feel messy",
            "Turn inspiration into a small action you can actually take",
            "Let different opinions exist at the same time",
            "Keep your kindness even when you are tired",
            "Sense beauty and emotional shifts with real acuity",
            "Break long-term goals into a pace you can sustain"
        ]

        let reminders = [
            "You do not have to score full marks on everything today. Finishing can help you relax more than perfecting.",
            "When thoughts multiply, return to your breath and the soles of your feet before handling the next thing.",
            "You can be kind and still have boundaries. Declining something unimportant will not damage a healthy relationship.",
            "Try replacing 'I should' with 'what I need right now'. The answer will sound more like you.",
            "Feel first, explain later. An emotion is not a problem that must be repaired immediately.",
            "Give yourself ten minutes with no output. That is not waste; it is recovery.",
            "You do not need to prove yourself to everyone. People who understand you will see your care."
        ]

        return PersonalityDossier(
            chinese: chinese,
            western: western,
            blood: blood,
            fusionSummary: StableDigest.pick(fusionOptions, seed: seed + "-fusion") ?? fusionOptions[0],
            signature: "\(snapshot.bloodType.displayName) · \(snapshot.westernZodiac.displayName) · Chinese zodiac: \(snapshot.chineseZodiac.displayName)",
            dailyStrengths: strengths,
            gentleReminders: reminders
        )
    }

    static func dailyInsight(for profile: UserProfile, date: Date = Date()) -> DailyPersonalityInsight {
        let snapshot = profile.snapshot
        let dossier = dossier(for: snapshot)
        let dayKey = DateKey.string(from: date)
        let seed = "\(snapshot.signature)-\(dayKey)-insight"

        let advantage = StableDigest.pick(dossier.dailyStrengths, seed: seed + "-strength") ?? dossier.dailyStrengths[0]
        let titleOptions = [
            "Turn sensitivity into clarity",
            "Move one small thing forward with kindness",
            "Settle yourself before responding to the world",
            "Give your feelings an outlet",
            "Leave a little breath inside the order",
            "Bring your attention back to now",
            "Allow yourself to move half a beat slower",
            "Turn sincerity toward yourself"
        ]
        let title = StableDigest.pick(titleOptions, seed: seed + "-title") ?? titleOptions[0]
        let reminder = StableDigest.pick(dossier.gentleReminders, seed: seed + "-reminder") ?? dossier.gentleReminders[0]
        let action = StableDigest.pick(dailyActions, seed: seed + "-action") ?? dailyActions[0]
        let boundary = StableDigest.pick(boundaryActions, seed: seed + "-boundary") ?? boundaryActions[0]
        let affirmation = StableDigest.pick(affirmations, seed: seed + "-affirmation") ?? affirmations[0]

        let guide = [
            "Where your strength lands: \(advantage). You can begin with something you can finish in ten minutes.",
            reminder,
            "Today's small practice: \(action)",
            "If overthinking returns: \(boundary)"
        ]

        return DailyPersonalityInsight(
            date: date,
            advantageTitle: title,
            advantage: "Your personality strength today is: \(advantage). You do not need this ability to please anyone; use it in your own life first.",
            guide: guide,
            affirmation: affirmation,
            signature: snapshot.signature
        )
    }

    private static let dailyActions = [
        "Turn off one unnecessary notification and give your attention a quiet pocket.",
        "Pause for three seconds at the first sip of water, notice the temperature, then continue.",
        "Write the thought that keeps circling into one short sentence you can act on.",
        "Tidy one small area in view and let the space carry some of the weight for you.",
        "Play a song without rushing it. Just listen, and do nothing else.",
        "Rewrite 'I must' as 'I can choose today', then read it once."
    ]

    private static let boundaryActions = [
        "Ask yourself: is this a fact, a guess, or my judgment about myself?",
        "Delay the answer for ten minutes. You do not have to respond to everyone in the first second.",
        "Step away from the screen, take three slow breaths, then decide whether to keep thinking.",
        "Allow this to have no answer for now. Finish today first.",
        "Take a sheet of paper and divide the worry into 'what I can do' and 'what I cannot control yet'."
    ]

    private static let affirmations = [
        "I am slowly returning to steadiness at my own pace.",
        "My feelings deserve to be heard, and my boundaries deserve respect.",
        "I do not need to be perfect. I am enough today.",
        "I can care for myself before caring for the world.",
        "The answer does not have to arrive immediately. Ease can come first."
    ]

    static func bloodTriad(for type: BloodType) -> PersonaTriad {
        let rows: [PersonaRow]
        switch type {
        case .a:
            rows = [
                PersonaRow(label: "Emotional sensitivity", content: "You are sensitive to changes in tone, environment, and other people's state, often sensing subtle shifts in the air before anyone names them."),
                PersonaRow(label: "Relational style", content: "You tend to care for other people's feelings first. You are thoughtful and attentive, and can easily place your true needs behind theirs."),
                PersonaRow(label: "Hidden nature", content: "It is not that you have no temper; you are simply used to processing it alone. When you feel understood, you become especially soft.")
            ]
        case .b:
            rows = [
                PersonaRow(label: "Emotional sensitivity", content: "Your emotions arrive directly and often clear quickly, like a breeze. Give them room to be expressed so they do not build up."),
                PersonaRow(label: "Relational style", content: "You are sincere and clear about boundaries. You enjoy easy, honest connection and do not want too many rules around you."),
                PersonaRow(label: "Hidden nature", content: "Beyond the lively surface, there is a part of you that needs quiet time to recharge. You just do not often explain it.")
            ]
        case .ab:
            rows = [
                PersonaRow(label: "Emotional sensitivity", content: "You often feel reason and emotion pulling at the same time. You can see many sides of a problem, which also makes repeated thinking more likely."),
                PersonaRow(label: "Relational style", content: "You are measured and considerate with others. You are willing to help, but do not easily hand all of your inner world to someone else."),
                PersonaRow(label: "Hidden nature", content: "You look calm on the outside, but inside you deeply value steady, reliable responses.")
            ]
        case .o:
            rows = [
                PersonaRow(label: "Emotional sensitivity", content: "Your emotional energy is strong and easily sparked by goals. When you face a setback, you may carry the pressure on your own shoulders first."),
                PersonaRow(label: "Relational style", content: "You are direct and dependable and are willing to look after the people around you, though you may sometimes forget that you need care too."),
                PersonaRow(label: "Hidden nature", content: "You appear strong, but inside you still hope someone will notice your tiredness, not only your ability.")
            ]
        }
        return PersonaTriad(
            category: "Blood-type personality reference",
            title: type.displayName,
            glyph: "drop",
            summary: "Your emotional foundation: \(type.shortTrait)",
            rows: rows,
            accentHex: type.accentHex
        )
    }

    static func westernTriad(for zodiac: WesternZodiac) -> PersonaTriad {
        let rows: [PersonaRow]
        switch zodiac {
        case .aries:
            rows = [
                PersonaRow(label: "Daily approach", content: "You act first and adjust along the way, looking for a way through as soon as a problem appears."),
                PersonaRow(label: "Friction source", content: "Wanting to prove yourself quickly, or losing patience while waiting for an outcome."),
                PersonaRow(label: "Relaxation style", content: "Break a large goal into one ten-minute action and let your body move first.")
            ]
        case .taurus:
            rows = [
                PersonaRow(label: "Daily approach", content: "You move steadily at your own pace and value a sense of certainty."),
                PersonaRow(label: "Friction source", content: "You can freeze when change arrives and recheck details repeatedly."),
                PersonaRow(label: "Relaxation style", content: "Settle yourself through touch and taste: a warm drink, a walk, or tidying your desk.")
            ]
        case .gemini:
            rows = [
                PersonaRow(label: "Daily approach", content: "You understand the world through conversation, information, and changing perspectives."),
                PersonaRow(label: "Friction source", content: "Too many ideas and options can keep your mind circling."),
                PersonaRow(label: "Relaxation style", content: "Write the thoughts down and keep only the one most important thing for today.")
            ]
        case .cancer:
            rows = [
                PersonaRow(label: "Daily approach", content: "You sense the atmosphere first, then decide how to respond."),
                PersonaRow(label: "Friction source", content: "Over-empathizing and carrying other people's emotions on your own back."),
                PersonaRow(label: "Relaxation style", content: "Return to a familiar small space, make a simple warm meal, and listen to soothing sound.")
            ]
        case .leo:
            rows = [
                PersonaRow(label: "Daily approach", content: "You want to be seen and are willing to express yourself sincerely."),
                PersonaRow(label: "Friction source", content: "Worrying that you are not enough and using bravado to cover insecurity."),
                PersonaRow(label: "Relaxation style", content: "Give yourself a private small win and sincerely appreciate yourself once.")
            ]
        case .virgo:
            rows = [
                PersonaRow(label: "Daily approach", content: "You analyze before acting and are good at organizing confusion into clarity."),
                PersonaRow(label: "Friction source", content: "High standards can make you criticize yourself over details."),
                PersonaRow(label: "Relaxation style", content: "Set 'eighty percent is complete' and give the remaining time back to your breath.")
            ]
        case .libra:
            rows = [
                PersonaRow(label: "Daily approach", content: "You value balance and comfort within relationships."),
                PersonaRow(label: "Friction source", content: "Fear of disappointing others can leave you unable to decide."),
                PersonaRow(label: "Relaxation style", content: "Ask what you want first, then answer. It is also okay to wait before replying.")
            ]
        case .scorpio:
            rows = [
                PersonaRow(label: "Daily approach", content: "You invest deeply and prefer to observe in quiet."),
                PersonaRow(label: "Friction source", content: "Not wanting to show vulnerability can let emotion build until it floods out at once."),
                PersonaRow(label: "Relaxation style", content: "Tell one trusted person a true sentence, or write it into an encrypted sealed wish.")
            ]
        case .sagittarius:
            rows = [
                PersonaRow(label: "Daily approach", content: "You ease pressure through exploration and a sense of open space."),
                PersonaRow(label: "Friction source", content: "You are sensitive to restriction and may find it hard to stay settled in the present."),
                PersonaRow(label: "Relaxation style", content: "Shrink the far horizon into one new route today and give freedom a concrete outlet.")
            ]
        case .capricorn:
            rows = [
                PersonaRow(label: "Daily approach", content: "You gain security through planning and responsibility."),
                PersonaRow(label: "Friction source", content: "Treating everything as a duty can leave no permission to rest."),
                PersonaRow(label: "Relaxation style", content: "Put an unproductive blank space on the schedule. Rest also counts as completion.")
            ]
        case .aquarius:
            rows = [
                PersonaRow(label: "Daily approach", content: "You step back to see the problem and keep an independent perspective."),
                PersonaRow(label: "Friction source", content: "Reason can override feeling, making it hard to name what actually hurts."),
                PersonaRow(label: "Relaxation style", content: "Name the emotion through body sensation first, then decide whether it needs explaining.")
            ]
        case .pisces:
            rows = [
                PersonaRow(label: "Daily approach", content: "Your sensitivity is rich, and music, stories, and atmosphere can move you easily."),
                PersonaRow(label: "Friction source", content: "Blurred boundaries can lead you to absorb the emotions around you."),
                PersonaRow(label: "Relaxation style", content: "Express yourself through sound or images, then give yourself ten quiet minutes.")
            ]
        }
        return PersonaTriad(
            category: "Western-zodiac personality reference",
            title: zodiac.displayName,
            glyph: zodiac.glyph,
            summary: "Your way of moving through the world: \(zodiac.shortTrait)",
            rows: rows,
            accentHex: "B9A8D6"
        )
    }

    static func chineseTriad(for zodiac: ChineseZodiac) -> PersonaTriad {
        let rows: [PersonaRow]
        switch zodiac {
        case .rat:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You observe with fine attention and have a gift for noticing opportunities and details."),
                PersonaRow(label: "Personality strength", content: "You react quickly and think creatively, arranging small things with care."),
                PersonaRow(label: "Emotional soft spot", content: "Thinking too much can quietly drain your energy.")
            ]
        case .ox:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are grounded and value commitment and stability."),
                PersonaRow(label: "Personality strength", content: "You have endurance and can build something slowly over time."),
                PersonaRow(label: "Emotional soft spot", content: "You are not good at calling a stop and may keep pushing through even when tired.")
            ]
        case .tiger:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are born with energy and a sense of purpose."),
                PersonaRow(label: "Personality strength", content: "You are willing to speak up and protect the people you care about."),
                PersonaRow(label: "Emotional soft spot", content: "When misunderstood, you may defend yourself quickly even though you care deeply.")
            ]
        case .rabbit:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are gentle, sensitive, and value safety and harmony."),
                PersonaRow(label: "Personality strength", content: "You know how to care for the atmosphere and respond to others with subtlety."),
                PersonaRow(label: "Emotional soft spot", content: "In conflict, you may give way first and keep the hurt to yourself.")
            ]
        case .dragon:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You carry an upward energy and a strong sense of purpose."),
                PersonaRow(label: "Personality strength", content: "You have your own view, take responsibility, and can energize people around you."),
                PersonaRow(label: "Emotional soft spot", content: "You expect a lot of yourself and may hide vulnerability from time to time.")
            ]
        case .snake:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are quiet and reflective, with keen intuition and aesthetic sensitivity."),
                PersonaRow(label: "Personality strength", content: "You can see through complexity and observe carefully before deciding."),
                PersonaRow(label: "Emotional soft spot", content: "You think deeply but say little, which can leave you carrying things alone.")
            ]
        case .horse:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You love action and freedom and prefer a lively pace."),
                PersonaRow(label: "Personality strength", content: "You are warm and direct and bring energy to the room."),
                PersonaRow(label: "Emotional soft spot", content: "Feeling trapped can make you restless; you need timely ways to release energy.")
            ]
        case .goat:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are soft and kind and value emotional connection."),
                PersonaRow(label: "Personality strength", content: "You are empathetic and know how to warm people through small details."),
                PersonaRow(label: "Emotional soft spot", content: "You may suppress your own needs to avoid troubling others.")
            ]
        case .monkey:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are flexible and quick-witted, good at finding new angles."),
                PersonaRow(label: "Personality strength", content: "You are curious and can make dull moments feel interesting."),
                PersonaRow(label: "Emotional soft spot", content: "When your attention scatters, you may blame yourself for not focusing enough.")
            ]
        case .rooster:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are careful and orderly and value quality and commitment."),
                PersonaRow(label: "Personality strength", content: "You have strong follow-through and a good sense of timing, and you close tasks well."),
                PersonaRow(label: "Emotional soft spot", content: "High standards can turn into self-criticism; allow room for imperfection.")
            ]
        case .dog:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are loyal and warm and value trust and fairness."),
                PersonaRow(label: "Personality strength", content: "You are willing to protect the people around you and are a dependable companion."),
                PersonaRow(label: "Emotional soft spot", content: "You can care too much on behalf of others; practice drawing a gentle boundary.")
            ]
        case .pig:
            rows = [
                PersonaRow(label: "Natural foundation", content: "You are generous and relaxed and know how to enjoy small everyday pleasures."),
                PersonaRow(label: "Personality strength", content: "You are accepting and friendly and help others feel safe."),
                PersonaRow(label: "Emotional soft spot", content: "You may swallow discomfort; practice expressing it sooner.")
            ]
        }
        return PersonaTriad(
            category: "Chinese-zodiac personality reference",
            title: "Chinese zodiac: \(zodiac.displayName)",
            glyph: zodiac.glyph,
            summary: "Your natural foundation: \(zodiac.shortTrait)",
            rows: rows,
            accentHex: "D2BFA7"
        )
    }
}