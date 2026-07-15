import SwiftUI
import Speech
import AVFoundation

struct FramesView: View {
    let hiveId: Int
    let boxId: String
    @Environment(HiveStore.self) private var store
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var voice = VoiceCommandManager()
    @State private var showPermissionAlert = false

    private var hive: Hive? { store.hives.first { $0.id == hiveId } }
    private var box: HiveBox? { hive?.estrutura.first { $0.id == boxId } }
    private var frames: [HiveFrame] { box?.quadros ?? [] }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Stats bar with percentages
                    HStack(spacing: 14) {
                        let total = frames.count
                        ForEach([FrameType.criacao, .alimentacao, .vazio], id: \.self) { tipo in
                            let count = frames.filter { $0.tipo == tipo }.count
                            let pct = total > 0 ? Int(Double(count) / Double(total) * 100) : 0
                            HStack(spacing: 5) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(tipo.color)
                                    .frame(width: 10, height: 10)
                                Text("\(count) \(tipo.shortLabel.lowercased()) (\(pct)%)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.brownMedium)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.cream)
                    .overlay(
                        Rectangle()
                            .fill(Color.amberDark.opacity(0.2))
                            .frame(height: 0.5),
                        alignment: .bottom
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(box?.label ?? "Caixa") · \(frames.count) Quadros")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.brownDark)
                        Text(voice.isListening
                             ? "A ouvir… diz \"quadro [N] criação/alimentação/vazio\""
                             : "Toca num quadro para alterar · mic para comandos de voz")
                            .font(.system(size: 12))
                            .foregroundStyle(voice.isListening ? Color(hex: "D03020") : Color.brownLight)
                            .animation(.easeInOut(duration: 0.2), value: voice.isListening)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 10)

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: sizeClass == .regular ? 8 : 5),
                        spacing: 8
                    ) {
                        ForEach(frames) { frame in
                            FrameCell(frame: frame, highlighted: voice.lastFrameId == frame.id) {
                                store.cycleFrame(hiveId: hiveId, boxId: boxId, frameId: frame.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                    // Legend
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LEGENDA")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1)
                            .foregroundStyle(Color.brownLight)

                        ForEach([FrameType.criacao, .alimentacao, .vazio], id: \.self) { tipo in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(tipo.color)
                                    .frame(width: 30, height: 30)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(tipo.fullLabel)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.brownDark)
                                    Text(tipo.legendDescription)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.brownLight)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cream)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.amberDark.opacity(0.18), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, voice.isListening ? 120 : 28)
                }
            }
            .background(Color.creamSecondary)

            // Voice transcript banner
            if voice.isListening {
                VoiceBanner(transcript: voice.transcript)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: voice.isListening)
        .navigationTitle(box?.label ?? "Quadros")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleVoice()
                } label: {
                    Image(systemName: voice.isListening ? "mic.fill" : "mic")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(voice.isListening ? Color(hex: "D03020") : Color.amberAccent)
                        .symbolEffect(.pulse, isActive: voice.isListening)
                }
            }
        }
        .alert("Permissão necessária", isPresented: $showPermissionAlert) {
            Button("Abrir Definições") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Para usar comandos de voz ativa o microfone e o reconhecimento de voz nas Definições.")
        }
        .onDisappear { voice.stop() }
    }

    private func toggleVoice() {
        if voice.isListening {
            voice.stopGracefully()
        } else {
            voice.start(onCommand: { frameId, tipo in
                store.setFrame(hiveId: hiveId, boxId: boxId, frameId: frameId, tipo: tipo)
            }, onDenied: {
                showPermissionAlert = true
            })
        }
    }
}

// MARK: - Voice Banner

struct VoiceBanner: View {
    let transcript: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "waveform")
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: "D03020"))
                .symbolEffect(.variableColor.iterative.dimInactiveLayers)

            VStack(alignment: .leading, spacing: 3) {
                Text(transcript.isEmpty ? "A ouvir…" : transcript)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.brownDark)
                    .lineLimit(2)
                Text("Ex: \"quadro três criação\" · \"quadro cinco vazio\"")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.brownLight)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "D03020").opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, y: -3)
    }
}

// MARK: - Frame Cell

struct FrameCell: View {
    let frame: HiveFrame
    var highlighted: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(frame.id)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(frame.tipo.textColor)
                Text(frame.tipo.shortLabel)
                    .font(.system(size: 8, weight: .semibold))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(frame.tipo.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(frame.tipo.color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(highlighted ? Color(hex: "D03020") : Color.black.opacity(0.06),
                            lineWidth: highlighted ? 2.5 : 2)
            )
            .scaleEffect(highlighted ? 1.05 : 1.0)
            .animation(.spring(duration: 0.25), value: highlighted)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Voice Command Manager

@Observable
class VoiceCommandManager {
    var isListening = false
    var transcript = ""
    var lastFrameId: Int? = nil

    private var recognizer: SFSpeechRecognizer?
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var tapInstalled = false
    private var commandApplied = false
    private var stopTimer: DispatchWorkItem?
    private var onCommand: ((Int, FrameType) -> Void)?
    private var onDenied: (() -> Void)?

    init() {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "pt-PT"))
            ?? SFSpeechRecognizer(locale: Locale(identifier: "pt-BR"))
            ?? SFSpeechRecognizer(locale: Locale(identifier: "pt"))
    }

    func start(onCommand: @escaping (Int, FrameType) -> Void, onDenied: @escaping () -> Void) {
        self.onCommand = onCommand
        self.onDenied = onDenied

        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            guard speechStatus == .authorized else {
                DispatchQueue.main.async { onDenied() }
                return
            }
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.beginListening() }
                    else { onDenied() }
                }
            }
        }
    }

    // Graceful stop: signal end of audio so the recognizer issues a final result,
    // then force-stop after 2 seconds if no final callback arrives.
    func stopGracefully() {
        guard isListening else { return }
        recognitionRequest?.endAudio()
        let timer = DispatchWorkItem { [weak self] in self?.stop() }
        stopTimer = timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: timer)
    }

    func stop() {
        stopTimer?.cancel()
        stopTimer = nil
        audioEngine.stop()
        if tapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isListening = false
        transcript = ""
        commandApplied = false
    }

    private func beginListening() {
        guard let recognizer, recognizer.isAvailable, !audioEngine.isRunning else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            }
            recognitionRequest = request

            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                DispatchQueue.main.async {
                    if let result {
                        let text = result.bestTranscription.formattedString.lowercased()
                        self.transcript = text
                        self.extractAndApply(from: text)
                    }
                    if error != nil || result?.isFinal == true {
                        self.stop()
                    }
                }
            }

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }
            tapInstalled = true
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true

            // Auto-stop after 12 seconds to prevent endless listening
            let timer = DispatchWorkItem { [weak self] in self?.stopGracefully() }
            stopTimer = timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 12, execute: timer)
        } catch {
            stop()
        }
    }

    // Scan the full transcript each callback — more reliable than tracking position
    private func extractAndApply(from text: String) {
        guard !commandApplied, let (frameId, tipo) = parseCommand(from: text) else { return }
        commandApplied = true
        lastFrameId = frameId
        onCommand?(frameId, tipo)
        stop()  // Auto-stop after successful command
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.lastFrameId = nil
        }
    }

    private func parseCommand(from text: String) -> (Int, FrameType)? {
        let nums: [String: Int] = [
            "um": 1, "uma": 1, "dois": 2, "duas": 2,
            "três": 3, "tres": 3, "quatro": 4, "cinco": 5,
            "seis": 6, "sete": 7, "oito": 8, "nove": 9, "dez": 10,
            "1": 1, "2": 2, "3": 3, "4": 4, "5": 5,
            "6": 6, "7": 7, "8": 8, "9": 9, "10": 10
        ]
        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        for i in 0..<words.count where words[i] == "quadro" {
            guard i + 1 < words.count, let num = nums[words[i + 1]] else { continue }
            for j in (i + 2)..<min(i + 5, words.count) {
                let w = words[j]
                if w.hasPrefix("cria")    { return (num, .criacao) }
                if w.hasPrefix("aliment") { return (num, .alimentacao) }
                if w.hasPrefix("vazi")    { return (num, .vazio) }
            }
        }
        return nil
    }
}

#Preview {
    let store = HiveStore()
    store.hives = [Hive.sample]
    return NavigationStack {
        FramesView(hiveId: 1, boxId: "ninho-1")
    }
    .environment(store)
}
