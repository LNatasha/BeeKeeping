import SwiftUI

struct SplashView: View {
    let onDismiss: () -> Void

    @State private var beeFloat = false
    @State private var title1Opacity: Double = 0
    @State private var title1Offset: CGFloat = 18
    @State private var title2Opacity: Double = 0
    @State private var title2Offset: CGFloat = 18
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "F6CC4A"), location: 0.00),
                    .init(color: Color(hex: "E8A020"), location: 0.22),
                    .init(color: Color(hex: "9A5010"), location: 0.58),
                    .init(color: Color(hex: "5A2C04"), location: 1.00),
                ]),
                center: UnitPoint(x: 0.42, y: 0.28),
                startRadius: 10,
                endRadius: 700
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                BeeView()
                    .frame(width: 148, height: 184)
                    .offset(y: beeFloat ? -14 : 0)
                    .rotationEffect(.degrees(beeFloat ? 2 : -2))
                    .animation(
                        .easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                        value: beeFloat
                    )

                Spacer().frame(height: 20)

                Text("Colmeias")
                    .font(.system(size: 40, weight: .heavy))
                    .tracking(-1.5)
                    .foregroundStyle(Color.cream)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
                    .opacity(title1Opacity)
                    .offset(y: title1Offset)

                Text("O teu apiário, sempre organizado")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.cream.opacity(0.68))
                    .padding(.top, 9)
                    .opacity(title2Opacity)
                    .offset(y: title2Offset)

                Spacer()

                VStack(spacing: 10) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .frame(height: 3)
                            Capsule()
                                .fill(Color.cream.opacity(0.65))
                                .frame(width: geo.size.width * progress, height: 3)
                                .animation(.linear(duration: 0.85), value: progress)
                        }
                    }
                    .frame(width: 170, height: 3)

                    Text("Toca para entrar")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.cream.opacity(0.4))
                        .kerning(0.6)
                }
                .padding(.bottom, 64)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
        .onAppear {
            beeFloat = true

            withAnimation(.easeOut(duration: 0.9).delay(0.2)) {
                title1Opacity = 1
                title1Offset = 0
            }
            withAnimation(.easeOut(duration: 0.9).delay(0.45)) {
                title2Opacity = 1
                title2Offset = 0
            }

            progress = 1.0

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onDismiss()
            }
        }
    }
}

// MARK: - Animated Bee

struct BeeView: View {
    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate

            let wingCycle = t.truncatingRemainder(dividingBy: 0.16) / 0.08
            let wingPhase = wingCycle < 1 ? wingCycle : 2 - wingCycle
            let wingsScaleY = CGFloat(1.0 - 0.82 * wingPhase)

            let dropRaw = (t - 0.5).truncatingRemainder(dividingBy: 2.0) / 1.0
            let dropPhase = CGFloat(dropRaw < 1 ? dropRaw : 2 - dropRaw)
            let honeyY = CGFloat(5) * sin(dropPhase * .pi)

            Canvas { ctx, _ in
                // 1. Wings with Y-scale buzzing
                ctx.drawLayer { layer in
                    layer.translateBy(x: 74, y: 70)
                    layer.scaleBy(x: 1.0, y: wingsScaleY)
                    layer.translateBy(x: -74, y: -70)
                    layer.fill(Path(ellipseIn: CGRect(x:  2, y: 53, width: 64, height: 30)),
                               with: .color(.white.opacity(0.84)))
                    layer.fill(Path(ellipseIn: CGRect(x: 82, y: 53, width: 64, height: 30)),
                               with: .color(.white.opacity(0.84)))
                    layer.fill(Path(ellipseIn: CGRect(x: 20, y: 77, width: 44, height: 22)),
                               with: .color(.white.opacity(0.70)))
                    layer.fill(Path(ellipseIn: CGRect(x: 84, y: 77, width: 44, height: 22)),
                               with: .color(.white.opacity(0.70)))
                }

                // 2. Body shadow
                ctx.fill(Path(ellipseIn: CGRect(x: 52, y: 138, width: 44, height: 12)),
                         with: .color(.black.opacity(0.12)))

                // 3. Body
                ctx.fill(Path(ellipseIn: CGRect(x: 48, y: 72, width: 52, height: 80)),
                         with: .color(Color(hex: "F6CC4A")))

                // 4. Stripes
                ctx.fill(Path(ellipseIn: CGRect(x: 52, y:  89, width: 44, height: 18)),
                         with: .color(Color(hex: "2D1600")))
                ctx.fill(Path(ellipseIn: CGRect(x: 50, y: 105, width: 48, height: 18)),
                         with: .color(Color(hex: "2D1600")))
                ctx.fill(Path(ellipseIn: CGRect(x: 53, y: 122, width: 42, height: 16)),
                         with: .color(Color(hex: "2D1600")))

                // 5. Stinger
                ctx.fill(Path(ellipseIn: CGRect(x: 65, y: 144, width: 18, height: 10)),
                         with: .color(Color(hex: "2D1600")))
                ctx.fill(
                    Path { p in
                        p.move(to:    CGPoint(x: 65, y: 151))
                        p.addLine(to: CGPoint(x: 83, y: 151))
                        p.addLine(to: CGPoint(x: 74, y: 165))
                        p.closeSubpath()
                    },
                    with: .color(Color(hex: "2D1600"))
                )

                // 6. Honey drop (animated)
                ctx.fill(
                    Path(ellipseIn: CGRect(x: 69.5, y: 161 + honeyY, width: 9, height: 12)),
                    with: .color(Color(hex: "E8A020"))
                )

                // 7. Head
                ctx.fill(Path(ellipseIn: CGRect(x: 47, y: 37, width: 54, height: 54)),
                         with: .color(Color(hex: "F6CC4A")))

                // 8. Cheeks
                ctx.fill(Path(ellipseIn: CGRect(x: 46, y: 66, width: 20, height: 14)),
                         with: .color(Color(red: 1, green: 0.47, blue: 0.24, opacity: 0.25)))
                ctx.fill(Path(ellipseIn: CGRect(x: 82, y: 66, width: 20, height: 14)),
                         with: .color(Color(red: 1, green: 0.47, blue: 0.24, opacity: 0.25)))

                // 9. Eye whites
                ctx.fill(Path(ellipseIn: CGRect(x: 54, y: 48, width: 18, height: 18)),
                         with: .color(.white))
                ctx.fill(Path(ellipseIn: CGRect(x: 76, y: 48, width: 18, height: 18)),
                         with: .color(.white))

                // 10. Pupils
                ctx.fill(Path(ellipseIn: CGRect(x: 60, y: 53, width: 10, height: 10)),
                         with: .color(Color(hex: "1A1200")))
                ctx.fill(Path(ellipseIn: CGRect(x: 82, y: 53, width: 10, height: 10)),
                         with: .color(Color(hex: "1A1200")))

                // 11. Eye shine
                ctx.fill(Path(ellipseIn: CGRect(x: 64.8, y: 50.8, width: 4.4, height: 4.4)),
                         with: .color(.white))
                ctx.fill(Path(ellipseIn: CGRect(x: 86.8, y: 50.8, width: 4.4, height: 4.4)),
                         with: .color(.white))

                // 12. Smile
                var smile = Path()
                smile.move(to:              CGPoint(x: 63, y: 72))
                smile.addQuadCurve(to:      CGPoint(x: 85, y: 72),
                                   control: CGPoint(x: 74, y: 82))
                ctx.stroke(smile, with: .color(Color(hex: "1A1200")), lineWidth: 2.8)

                // 13. Antennae
                var antL = Path()
                antL.move(to:              CGPoint(x: 65, y: 38))
                antL.addQuadCurve(to:      CGPoint(x: 51, y: 15),
                                  control: CGPoint(x: 57, y: 24))
                ctx.stroke(antL, with: .color(Color(hex: "1A1200")), lineWidth: 2.5)

                var antR = Path()
                antR.move(to:              CGPoint(x: 83, y: 38))
                antR.addQuadCurve(to:      CGPoint(x: 97, y: 15),
                                  control: CGPoint(x: 91, y: 24))
                ctx.stroke(antR, with: .color(Color(hex: "1A1200")), lineWidth: 2.5)

                // 14. Antenna balls
                let bL = Path(ellipseIn: CGRect(x: 44.5, y: 7.5, width: 11, height: 11))
                ctx.fill(bL,   with: .color(Color(hex: "F6CC4A")))
                ctx.stroke(bL, with: .color(Color(hex: "1A1200")), lineWidth: 2)

                let bR = Path(ellipseIn: CGRect(x: 92.5, y: 7.5, width: 11, height: 11))
                ctx.fill(bR,   with: .color(Color(hex: "F6CC4A")))
                ctx.stroke(bR, with: .color(Color(hex: "1A1200")), lineWidth: 2)
            }
        }
        .frame(width: 148, height: 184)
    }
}

#Preview {
    SplashView {}
}
