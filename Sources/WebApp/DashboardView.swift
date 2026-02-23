import ElementaryUI
import Foundation

@View
struct DashboardView {
    @Binding var isLoggedIn: Bool

    @State private var activeUserCount: Int?
    @State private var subscriptionStats: SubscriptionStatsResponse?
    @State private var transactionStats: TransactionStatsResponse?
    @State private var isLoading = true
    
    @State private var isPast30DaysExpanded = true
    @State private var isSubscriptionsExpanded = true

    var body: some View {
        div {
            header
            mainContent
        }
        .onAppear {
            Task {
                await fetchStats()
            }
        }
    }

    private func fetchStats() async {
        let usersRequest = FetchRequest(method: .get)
        let subsRequest = FetchRequest(method: .get)
        let txRequest = FetchRequest(method: .get)

        async let usersResponse = usersRequest.send(to: "\(backendURL)/demo/active-users")
        async let subsResponse = subsRequest.send(to: "\(backendURL)/demo/subscription-stats")
        async let txResponse = txRequest.send(to: "\(backendURL)/demo/transaction-stats")

        if let response = try? await usersResponse, response.status == 200 {
            activeUserCount = (try? response.decode(ActiveUsersResponse.self))?.activeUserCount
        }

        if let response = try? await subsResponse, response.status == 200 {
            subscriptionStats = try? response.decode(SubscriptionStatsResponse.self)
        }

        if let response = try? await txResponse, response.status == 200 {
            transactionStats = try? response.decode(TransactionStatsResponse.self)
        }

        isLoading = false
    }

    var header: some View {
        div {
            span { "ElementaryUI demo" }
                .styles(
                    .fontSize(.rem(1.25)), 
                    .color(.text)
                )

            button { "Sign out" }
                .styles(
                    .fontSize(.rem(0.8125)),
                    .color(.textMuted),
                    .custom(key: "background", value: "none"),
                    .border(.none),
                    .cursor(.pointer),
                    .padding(.rem(0.25), .rem(0.5))
                )
                .onClick { _ in
                    AuthStorage.clearLoginState()
                    isLoggedIn = false
                }
        }
        .styles(
            .custom(key: "border-bottom", value: "1px solid var(--color-border)"),
            .padding(.rem(0.75), .rem(1.0)),
            .display(.flex),
            .alignItems(.center),
            .justifyContent(.spaceBetween),
            .maxWidth(.px(1000)),
            .margin(.px(0), .auto),
            .width(.percent(100))
        )
    }

    var mainContent: some View {
        div {
            img(.src("https://elementary-swift.github.io/assets/elementary-logo.svg"), .alt("ElementaryUI"))
                .styles(
                    .width(.clamp(min: .px(80), ideal: .vw(15), max: .px(120))),
                    .height(.auto),
                    .margin(.px(0), .auto, .clamp(min: .rem(1.0), ideal: .vw(3), max: .rem(1.5))),
                    .display(.block)
                )

            h1 { "Demo dashboard" }
                .styles(
                    .fontDisplay,
                    .fontWeight(.regular),
                    .fontSize(.clamp(min: .rem(1.75), ideal: .vw(4), max: .rem(2.5))),
                    .letterSpacing(.em(-0.02)),
                    .color(.text)
                )

            past30DaysSection
            subscriptionsSection
        }
        .styles(
            .maxWidth(.px(1000)),
            .margin(.px(0), .auto),
            .padding(.clamp(min: .rem(1.5), ideal: .vw(5), max: .rem(3.0)), .rem(1.0)),
            .textAlign(.center)
        )
    }
    
    var past30DaysSection: some View {
        div {
            div {
                h2 { "Past 30 days" }
                    .styles(
                        .fontSize(.rem(1.125)),
                        .fontWeight(.semiBold),
                        .color(.text),
                        .margin(.top(.rem(2.0)))
                    )
                
                img(.src("/chevron-down.png"), .alt("Collapsible arrow"))
                    .styles(
                        .height(.px(24)),
                        .width(.px(24)),
                        .color(.textMuted),
                        .display(.inlineBlock)
                    )
                    .rotationEffect(isPast30DaysExpanded ? .degrees(0) : .degrees(-90))
            }
            .styles(
                .display(.flex),
                .alignItems(.center),
                .justifyContent(.spaceBetween),
                .cursor(.pointer)
            )
            .onClick { _ in
                withAnimation {
                    isPast30DaysExpanded.toggle()
                }
            }
            
            if isPast30DaysExpanded {
                div(.class("stats-grid")) {
                    StatCard(
                        label: "Active Users",
                        value: activeUserCount.map(String.init) ?? "—",
                        trend: ""
                    )
                    StatCard(
                        label: "Transactions",
                        value: transactionStats.map { Formatters.formatNumber($0.transactionCount) } ?? "—",
                        trend: ""
                    )
                    StatCard(
                        label: "Total Processed",
                        value: transactionStats.map { Formatters.formatUSD($0.totalProcessedUSD) } ?? "—",
                        trend: "USD"
                    )
                }
                .transition(.fade)
            }
        }
        .animateContainerLayout()
    }
    
    var subscriptionsSection: some View {
        div {
            div {
                h2 { "Current Subscriptions" }
                    .styles(
                        .fontSize(.rem(1.125)),
                        .fontWeight(.semiBold),
                        .color(.text),
                        .margin(.top(.rem(2.5)))
                    )
                
                img(.src("/chevron-down.png"), .alt("Collapsible arrow"))
                    .styles(
                        .height(.px(24)),
                        .width(.px(24)),
                        .color(.textMuted),
                        .display(.inlineBlock)
                    )
                    .rotationEffect(isSubscriptionsExpanded ? .degrees(0) : .degrees(-90))
            }
            .styles(
                .display(.flex),
                .alignItems(.center),
                .justifyContent(.spaceBetween),
                .cursor(.pointer)
            )
            .onClick { _ in
                withAnimation {
                    isSubscriptionsExpanded.toggle()
                }
            }
            
            if isSubscriptionsExpanded {
                div(.class("stats-grid")) {
                    StatCard(
                        label: "Monthly Subscribers",
                        value: subscriptionStats.map { String($0.monthly.total) } ?? "—",
                        trend: subscriptionStats.map { "\($0.monthly.optedOutOfRenewal) opted out" } ?? ""
                    )
                    StatCard(
                        label: "Annual Subscribers",
                        value: subscriptionStats.map { String($0.annual.total) } ?? "—",
                        trend: subscriptionStats.map { "\($0.annual.optedOutOfRenewal) opted out" } ?? ""
                    )
                    StatCard(
                        label: "Trials",
                        value: subscriptionStats.map { String($0.trial.total) } ?? "—",
                        trend: subscriptionStats.map { "\($0.trial.optedOutOfRenewal) opted out" } ?? ""
                    )
                }
                .transition(.fade)
            }
        }
        .animateContainerLayout()
    }
}

@View
struct StatCard {
    var label: String
    var value: String
    var trend: String

    var body: some View {
        div(.class("stat-card")) {
            p { label }
                .styles(
                    .fontSize(.rem(0.75)),
                    .fontWeight(.semiBold),
                    .textTransform(.uppercase),
                    .letterSpacing(.em(0.05)),
                    .color(.textMuted),
                    .margin(.bottom(.rem(0.5)))
                )

            p { value }
                .styles(
                    .fontDisplay,
                    .fontSize(.clamp(min: .rem(1.5), ideal: .vw(4), max: .rem(2.0))),
                    .fontWeight(.regular),
                    .color(.text),
                    .lineHeight(1.1),
                    .margin(.bottom(.rem(0.5)))
                )

            p { trend }
                .styles(.fontSize(.rem(0.8125)), .color(.accent))
        }
        .styles(
            .backgroundColor(.bgSecondary),
            .borderRadius(.px(12)),
            .padding(.rem(1.25), .rem(1.0)),
            .textAlign(.left)
        )
    }
}
