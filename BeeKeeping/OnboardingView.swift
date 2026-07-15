import SwiftUI

private struct TourStep {
    let icon: String
    let title: String
    let body: String
}

private let tourSteps: [TourStep] = [
    TourStep(
        icon: "hand.wave.fill",
        title: "Olá! Bem-vindo!",
        body: "Sou a Beatriz, a tua guia. Vou mostrar-te como usar o Colmeias para gerir o teu apiário com facilidade."
    ),
    TourStep(
        icon: "rectangle.stack.fill",
        title: "As tuas Colmeias",
        body: "Na lista principal vês todas as colmeias. Toca em '+' no canto superior direito para adicionar a primeira."
    ),
    TourStep(
        icon: "square.grid.2x2.fill",
        title: "Quadros do Ninho",
        body: "Em cada colmeia podes registar o estado de cada quadro: criação, alimentação ou vazio. Tens ainda comandos por voz!"
    ),
    TourStep(
        icon: "drop.fill",
        title: "Alimentação Artificial",
        body: "Regista cada alimentação com produto, tipo (sólido/líquido) e dose. Consulta o historial completo a qualquer momento."
    ),
    TourStep(
        icon: "staroflife.fill",
        title: "Desinfecção",
        body: "Regista os tratamentos e define a próxima data de desinfecção. A app avisa-te quando estiver em atraso."
    ),
]

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var step = 0
    @State private var beeFloat = false

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
                HStack {
                    Spacer()
                    Button("Saltar") { onComplete() }
                        .font(.system(size: 15))
                        .foregroundStyle(Color.cream.opacity(0.75))
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer()

                BeeView()
                    .frame(width: 148, height: 184)
                    .offset(y: beeFloat ? -14 : 0)
                    .rotationEffect(.degrees(beeFloat ? 2 : -2))
                    .animation(
                        .easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                        value: beeFloat
                    )

                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.amberAccent.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image(systemName: tourSteps[step].icon)
                            .font(.system(size: 26))
                            .foregroundStyle(Color.amberAccent)
                    }

                    VStack(spacing: 10) {
                        Text(tourSteps[step].title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.brownDark)
                        Text(tourSteps[step].body)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.brownMedium)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .animation(.easeInOut(duration: 0.2), value: step)

                    HStack(spacing: 6) {
                        ForEach(0..<tourSteps.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(i == step ? Color.amberAccent : Color.amberAccent.opacity(0.25))
                                .frame(width: i == step ? 20 : 6, height: 6)
                                .animation(.spring(duration: 0.4), value: step)
                        }
                    }

                    Button {
                        if step < tourSteps.count - 1 {
                            withAnimation { step += 1 }
                        } else {
                            onComplete()
                        }
                    } label: {
                        Text(step < tourSteps.count - 1 ? "Seguinte" : "Começar!")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.cream)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.amberAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.amberAccent.opacity(0.4), radius: 10, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 36)
                .frame(maxWidth: .infinity)
                .background(Color.cream)
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 28, bottomLeading: 0,
                            bottomTrailing: 0, topTrailing: 28
                        )
                    )
                )
                .shadow(color: .black.opacity(0.10), radius: 20, y: -4)
            }
        }
        .onAppear { beeFloat = true }
    }
}
