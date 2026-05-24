import StoreKit
import SwiftUI

struct InfoView: View {
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            List {
                appInfoSection
                privacySection
                legalSection
                thirdPartyLicensesSection
                rateAppSection
            }
            .navigationTitle("info_navigation_title")
        }
    }

    private var appInfoSection: some View {
        Section {
            LabeledContent(String(localized: "info_app_name_label"), value: InfoMetadata.displayName)
            LabeledContent(String(localized: "info_version_label"), value: InfoMetadata.version)
            LabeledContent(String(localized: "info_build_label"), value: InfoMetadata.build)
        } header: {
            Text("info_section_app")
        }
    }

    private var privacySection: some View {
        Section {
            InfoDescriptionRow(
                titleKey: "info_privacy_storage_title",
                bodyKey: "info_privacy_storage_body"
            )
            InfoDescriptionRow(
                titleKey: "info_privacy_analytics_title",
                bodyKey: "info_privacy_analytics_body"
            )
            InfoDescriptionRow(
                titleKey: "info_privacy_notifications_title",
                bodyKey: "info_privacy_notifications_body"
            )
        } header: {
            Text("info_section_privacy")
        }
    }

    private var legalSection: some View {
        Section {
            InfoLinkRow(
                titleKey: "info_privacy_policy_title",
                url: AppInfoLinks.privacyPolicyURL
            )
            InfoLinkRow(
                titleKey: "info_terms_of_use_title",
                url: AppInfoLinks.termsOfUseURL
            )
        } header: {
            Text("info_section_legal")
        } footer: {
            Text("info_legal_footer")
        }
    }

    private var thirdPartyLicensesSection: some View {
        Section {
            ForEach(ThirdPartyLibrary.allCases) { library in
                Link(destination: library.repositoryURL) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(library.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(library.version)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(library.repositoryURL.absoluteString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        } header: {
            Text("info_section_third_party")
        } footer: {
            Text("info_third_party_footer")
        }
    }

    private var rateAppSection: some View {
        Section {
            if let rateURL = AppInfoLinks.appStoreReviewURL {
                Link(destination: rateURL) {
                    Label("info_rate_app_title", systemImage: "star.bubble")
                }
            } else {
                Button {
                    requestReview()
                } label: {
                    Label("info_rate_app_title", systemImage: "star.bubble")
                }
            }
        } header: {
            Text("info_section_rate")
        } footer: {
            Text("info_rate_footer")
        }
    }
}

private struct InfoDescriptionRow: View {
    let titleKey: LocalizedStringKey
    let bodyKey: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleKey)
                .font(.headline)
            Text(bodyKey)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private struct InfoLinkRow: View {
    let titleKey: LocalizedStringKey
    let url: URL?

    var body: some View {
        if let url {
            Link(destination: url) {
                HStack {
                    Text(titleKey)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            LabeledContent {
                Text("info_link_unavailable")
                    .foregroundStyle(.secondary)
            } label: {
                Text(titleKey)
            }
        }
    }
}

private enum InfoMetadata {
    static let displayName =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "TaskLedger"

    static let version =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        ?? "-"

    static let build =
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        ?? "-"
}

private enum AppInfoLinks {
    private static let siteBaseURL = URL(string: "https://riamf.github.io/TaskLedger/")!

    static let privacyPolicyURL = siteBaseURL.appending(path: "privacy-policy.html")
    static let termsOfUseURL = siteBaseURL.appending(path: "terms-of-service.html")
    static let appStoreReviewURL: URL? = URL(string: "https://apps.apple.com/app/id6757359797?action=write-review")
}

private enum ThirdPartyLibrary: String, CaseIterable, Identifiable {
    case firebase
    case firebaseCrashlytics
    case googleAppMeasurement
    case googleDataTransport
    case googleUtilities
    case grpcBinary
    case interopForGoogleSDKs
    case promises
    case nanopb
    case leveldb
    case abseil
    case appCheck
    case gtmSessionFetcher

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .firebase: return "FirebaseAnalytics"
        case .firebaseCrashlytics: return "FirebaseCrashlytics"
        case .googleAppMeasurement: return "GoogleAppMeasurement"
        case .googleDataTransport: return "GoogleDataTransport"
        case .googleUtilities: return "GoogleUtilities"
        case .grpcBinary: return "gRPC Binary"
        case .interopForGoogleSDKs: return "Interop iOS for Google SDKs"
        case .promises: return "Promises"
        case .nanopb: return "nanopb"
        case .leveldb: return "leveldb"
        case .abseil: return "abseil-cpp-binary"
        case .appCheck: return "App Check"
        case .gtmSessionFetcher: return "GTM Session Fetcher"
        }
    }

    var version: String {
        switch self {
        case .firebase, .firebaseCrashlytics, .googleAppMeasurement:
            return "12.12.1"
        case .googleDataTransport:
            return "10.1.0"
        case .googleUtilities:
            return "8.1.0"
        case .grpcBinary:
            return "1.69.1"
        case .interopForGoogleSDKs:
            return "101.0.0"
        case .promises:
            return "2.4.0"
        case .nanopb:
            return "2.30910.0"
        case .leveldb:
            return "1.22.5"
        case .abseil:
            return "1.2024072200.0"
        case .appCheck:
            return "11.2.0"
        case .gtmSessionFetcher:
            return "4.5.0"
        }
    }

    var repositoryURL: URL {
        switch self {
        case .firebase, .firebaseCrashlytics:
            return URL(string: "https://github.com/firebase/firebase-ios-sdk")!
        case .googleAppMeasurement:
            return URL(string: "https://github.com/google/GoogleAppMeasurement")!
        case .googleDataTransport:
            return URL(string: "https://github.com/google/GoogleDataTransport")!
        case .googleUtilities:
            return URL(string: "https://github.com/google/GoogleUtilities")!
        case .grpcBinary:
            return URL(string: "https://github.com/google/grpc-binary")!
        case .interopForGoogleSDKs:
            return URL(string: "https://github.com/google/interop-ios-for-google-sdks")!
        case .promises:
            return URL(string: "https://github.com/google/promises")!
        case .nanopb:
            return URL(string: "https://github.com/firebase/nanopb")!
        case .leveldb:
            return URL(string: "https://github.com/firebase/leveldb")!
        case .abseil:
            return URL(string: "https://github.com/google/abseil-cpp-binary")!
        case .appCheck:
            return URL(string: "https://github.com/google/app-check")!
        case .gtmSessionFetcher:
            return URL(string: "https://github.com/google/gtm-session-fetcher")!
        }
    }
}

#Preview {
    InfoView()
}
