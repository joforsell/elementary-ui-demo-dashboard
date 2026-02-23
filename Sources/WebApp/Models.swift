import Foundation

struct ActiveUsersResponse: Decodable {
    var activeUserCount: Int
}

struct SubscriptionTier: Decodable {
    var total: Int
    var optedOutOfRenewal: Int
}

struct SubscriptionStatsResponse: Decodable {
    var monthly: SubscriptionTier
    var annual: SubscriptionTier
    var trial: SubscriptionTier
}

struct TransactionStatsResponse: Decodable {
    var transactionCount: Int
    var totalProcessedUSD: Double
}
