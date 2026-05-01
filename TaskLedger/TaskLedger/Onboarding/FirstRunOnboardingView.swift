import SwiftUI

struct FirstRunOnboardingView: View {
    private struct Page: Identifiable {
        let id: Int
        let imageName: String
    }

    private let pages: [Page] = [
        Page(id: 0, imageName: "onboarding_0"),
        Page(id: 1, imageName: "onboarding_1"),
        Page(id: 2, imageName: "onboarding_2"),
        Page(id: 3, imageName: "onboarding_3")
    ]

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
        Image(imageName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(maxWidth: size.width)
            .frame(maxHeight: size.height * 0.8)
            .padding(.horizontal, 12)
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

#Preview {
    FirstRunOnboardingView(onFinish: {})
}
