import SwiftUI

struct PaywallView: View {
    @ObservedObject var store: StoreManager
    @Environment(\.dismiss) private var dismiss

    private let perks: [(String, String)] = [
        ("doc.fill", "Transcribe audio files without limits"),
        ("waveform", "Small model, the most accurate transcription"),
        ("lock.shield", "Stays on device. No account, no cloud, no tracking"),
        ("infinity", "One payment. No subscription, ever")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)

            Image(systemName: "waveform")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.primary)
                .padding(.bottom, 16)

            Text("Voxprint Pro")
                .font(.system(size: 28, weight: .bold))
            Text("Own it once. Not a subscription.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(perks, id: \.1) { icon, label in
                    HStack(spacing: 14) {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 24)
                        Text(label)
                            .font(.system(size: 15))
                            .foregroundStyle(.primary)
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 32)

            Spacer(minLength: 0)

            Button(action: { Task { await store.purchase() } }) {
                Group {
                    if store.purchasing {
                        ProgressView().tint(Self.invertedLabel)
                    } else {
                        Text(buyTitle).font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.primary)
                .foregroundStyle(Self.invertedLabel)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(store.purchasing || store.restoring || store.product == nil)
            .padding(.horizontal, 24)

            if let message = store.message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
            }

            if store.product == nil {
                Button(store.loadingProduct ? "Loading price…" : "Retry loading price") {
                    Task { await store.loadProduct() }
                }
                .disabled(store.loadingProduct)
                .padding(.top, 12)
            }

            Button(store.restoring ? "Restoring…" : "Restore Purchase") { Task { await store.restore() } }
                .disabled(store.purchasing || store.restoring)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.top, 14)

            Button("Not now") { dismiss() }
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
                .padding(.top, 10)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: 420)
        .onChange(of: store.isPro) { _, isPro in if isPro { dismiss() } }
        .task { if store.product == nil { await store.loadProduct() } }
    }

    private var buyTitle: String {
        if let price = store.product?.displayPrice { return "Unlock for \(price)" }
        return "Unlock Voxprint Pro"
    }

    /// System background color (inverse of `Color.primary`) so the button label
    /// stays legible on both platforms. `UIColor.systemBackground` is iOS-only.
    #if os(macOS)
    private static let invertedLabel = Color(nsColor: .textBackgroundColor)
    #else
    private static let invertedLabel = Color(uiColor: .systemBackground)
    #endif
}
