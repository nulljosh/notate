import Foundation
import StoreKit

/// Local, server-free entitlement for Voxprint Pro.
///
/// One non-consumable unlock (`com.nulljosh.echo.unlock`). Ownership is read straight
/// from StoreKit's `Transaction.currentEntitlements`, so there is no account, no
/// receipt server, and nothing leaves the device. Fits the whole pitch: own it once.
@MainActor
final class StoreManager: ObservableObject {
    static let productID = "com.nulljosh.echo.unlock"

    /// Free file transcriptions before the unlock is required. Live mic stays free forever.
    static let freeFileLimit = 3
    private static let usedCountKey = "echo.fileTranscriptionsUsed"

    // Paid Apps Agreement signed 2026-09-09 — real entitlement check restored below.
    @Published private(set) var isPro = false
    @Published private(set) var product: Product?
    @Published private(set) var purchasing = false
    @Published private(set) var restoring = false
    @Published private(set) var loadingProduct = false
    @Published private(set) var message: String?
    @Published var showPaywall = false

    private var updatesTask: Task<Void, Never>?

    init() {
        if CommandLine.arguments.contains("UITEST_PAYWALL") {
            showPaywall = true
        }
        updatesTask = listenForTransactions()
        Task {
            await refreshEntitlement()
            await loadProduct()
        }
    }

    deinit { updatesTask?.cancel() }

    // MARK: - Free tier gating

    var freeFilesUsed: Int { UserDefaults.standard.integer(forKey: Self.usedCountKey) }
    var freeFilesRemaining: Int { max(0, Self.freeFileLimit - freeFilesUsed) }

    /// File transcription is allowed if Pro, or while free transcriptions remain.
    func canTranscribeFile() -> Bool { isPro || freeFilesUsed < Self.freeFileLimit }

    /// Call after a successful free file transcription so the counter advances.
    func recordFileTranscription() {
        guard !isPro else { return }
        UserDefaults.standard.set(freeFilesUsed + 1, forKey: Self.usedCountKey)
        objectWillChange.send()
    }

    /// The most accurate model is a Pro feature; auto/tiny/base are free.
    func isModelLocked(_ model: String) -> Bool {
        !isPro && model == "openai_whisper-small"
    }

    // MARK: - Purchase flow

    func loadProduct() async {
        guard !loadingProduct else { return }
        loadingProduct = true
        message = nil
        defer { loadingProduct = false }
        // ponytail: sandbox/App Review StoreKit fetches occasionally fail transiently;
        // retry a few times with backoff instead of leaving the button dead forever.
        for attempt in 0..<3 {
            if let fetched = try? await Product.products(for: [Self.productID]).first {
                product = fetched
                return
            }
            if attempt < 2 { try? await Task.sleep(for: .seconds(1 << attempt)) }
        }
        message = "The App Store could not load the price. Check your connection and try again."
    }

    func purchase() async {
        guard let product, !purchasing, !restoring else { return }
        purchasing = true
        message = nil
        defer { purchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(.verified(let transaction)):
                await transaction.finish()
                await refreshEntitlement()
                if isPro { showPaywall = false }
                else { message = "Your purchase is still being confirmed. Tap Restore Purchase to check again." }
            case .success(.unverified):
                message = "The App Store could not verify this purchase. Tap Restore Purchase to try again."
            case .pending:
                message = "Your purchase is awaiting approval. Pro will unlock when it is approved."
            case .userCancelled:
                break
            @unknown default:
                message = "The purchase could not be completed. Please try again."
            }
        } catch {
            message = "The purchase could not be completed. Please try again."
        }
    }

    func restore() async {
        guard !restoring, !purchasing else { return }
        restoring = true
        message = nil
        defer { restoring = false }
        do {
            try await AppStore.sync()
            await refreshEntitlement()
            if isPro { showPaywall = false }
            else { message = "No Voxprint Pro purchase was found for this Apple Account." }
        } catch {
            message = "Purchases could not be restored. Check your connection and try again."
        }
    }

    // MARK: - Entitlement

    private func refreshEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                isPro = true
                return
            }
        }
        isPro = false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshEntitlement()
                }
            }
        }
    }
}
