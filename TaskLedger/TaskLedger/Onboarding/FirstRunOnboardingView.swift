import SwiftUI
import UIKit

struct FirstRunOnboardingView: View {
    private struct Page: Identifiable {
        let id: Int

        var imageName: String {
            OnboardingImageResolver.imageName(for: id)
        }
    }

    private let pages = (0...3).map(Page.init(id:))

    let onFinish: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPage = 0

    private var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 12)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        onboardingImage(named: page.imageName, in: geometry.size)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))

                Spacer(minLength: 12)

                Button {
                    handlePrimaryAction()
                } label: {
                    Text(isLastPage ? "onboarding_get_started_button_title" : "onboarding_next_button_title")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .glassPillButtonChrome(cornerRadius: 26, horizontalPadding: 0, verticalPadding: 0)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .light ? Color.white : Color.black)
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func onboardingImage(named imageName: String, in size: CGSize) -> some View {
        let cardShape = RoundedRectangle(cornerRadius: 32, style: .continuous)

        Image(imageName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(maxHeight: size.height * 0.8)
            .clipped()
            .mask(cardShape)
            .overlay {
                cardShape.strokeBorder(
                    Color.white.opacity(colorScheme == .light ? 0.55 : 0.18),
                    lineWidth: 1.5
                )
            }
            .shadow(
                color: .black.opacity(colorScheme == .light ? 0.12 : 0.28),
                radius: 18,
                x: 0,
                y: 10
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(maxWidth: size.width)
            .accessibilityHidden(true)
    }

    private func handlePrimaryAction() {
        guard !isLastPage else {
            onFinish()
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            currentPage += 1
        }
    }
}

enum OnboardingImageResolver {
    static func imageName(
        for pageIndex: Int,
        preferredLocalizations: [String] = Bundle.main.preferredLocalizations,
        imageExists: (String) -> Bool = { UIImage(named: $0) != nil }
    ) -> String {
        let baseName = "onboarding_\(pageIndex)"
        let primaryLanguage = preferredLocalizations.compactMap(languageCode(from:)).first
        let candidates: [String]

        switch primaryLanguage {
        case "pl":
            candidates = ["\(baseName)_pl", "\(baseName)_en", baseName]
        default:
            candidates = ["\(baseName)_en", baseName]
        }

        return candidates.first(where: imageExists) ?? baseName
    }

    static func languageCode(from localization: String) -> String? {
        let normalized = localization.lowercased()

        if normalized.hasPrefix("pl") {
            return "pl"
        }

        if normalized.hasPrefix("en") {
            return "en"
        }

        return nil
    }
}

#Preview {
    FirstRunOnboardingView(onFinish: {})
}
