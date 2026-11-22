import SwiftUI

struct Card3DFlip<Front: View, Back: View>: View {
    let isFlipped: Bool
    private let front: Front
    private let back: Back

    init(isFlipped: Bool, @ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self.isFlipped = isFlipped
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            if isFlipped {
                back
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                front
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.55
        )
        .animation(.spring(response: 0.82, dampingFraction: 0.78), value: isFlipped)
        .shadow(color: AppTheme.lavenderDeep.opacity(0.22), radius: 22, x: 0, y: 14)
    }
}

struct TarotCardBack: View {
    let skin: MellowSkin
    let glyph: String
    let isShuffling: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hexString: skin.primaryHex), Color(hexString: skin.secondaryHex), Color(hexString: skin.primaryHex).opacity(0.78)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.48), lineWidth: 1)
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(Color.white.opacity(0.38), lineWidth: 0.8)
                .padding(8)
            Circle()
                .fill(RadialGradient(colors: [Color.white.opacity(0.34), .clear], center: .center, startRadius: 2, endRadius: 80))
                .padding(18)
            Image(systemName: skin.symbol)
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(Color.white.opacity(0.92))
                .rotationEffect(.degrees(isShuffling ? 8 : 0))
            Text(glyph)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.white.opacity(0.58))
                .offset(y: 62)
        }
        .aspectRatio(0.62, contentMode: .fit)
        .compositingGroup()
    }
}

struct TarotCardFront: View {
    let card: TarotCard
    var skin: MellowSkin? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hexString: card.primaryHex), Color(hexString: card.secondaryHex)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.62), lineWidth: 1)
            if let skin {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(hexString: skin.primaryHex).opacity(0.82), lineWidth: 2)
                    .padding(4)
            }
            VStack(spacing: 14) {
                Text(card.theme.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(2.4)
                    .foregroundStyle(AppTheme.softInk.opacity(0.72))
                Spacer(minLength: 0)
                Text(card.glyph)
                    .font(.system(size: 54, weight: .ultraLight))
                    .foregroundStyle(AppTheme.ink.opacity(0.78))
                    .shadow(color: .white.opacity(0.7), radius: 10)
                Text(card.name)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                Spacer(minLength: 0)
                HStack(spacing: 5) {
                    ForEach(card.keywords.prefix(3), id: \.self) { keyword in
                        Text(keyword)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.45), in: Capsule())
                    }
                }
                .foregroundStyle(AppTheme.softInk)
            }
            .padding(22)
        }
        .overlay(alignment: .topTrailing) {
            if let skin {
                HStack(spacing: 4) {
                    Image(systemName: skin.symbol)
                    Text(skin.name)
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(AppTheme.softInk.opacity(0.82))
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.48), in: Capsule())
                .padding(12)
            }
        }
        .aspectRatio(0.62, contentMode: .fit)
        .compositingGroup()
    }
}