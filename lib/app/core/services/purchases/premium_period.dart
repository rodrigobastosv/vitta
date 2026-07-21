// The billing period, in the app's own terms so nothing above core/services/
// imports purchases_flutter — the boundary PremiumOffer already draws for the
// price.
//
// It exists because the period used to be hardcoded into the subscribe label
// ("Subscribe for {price}/month"), which is a claim about a product the store
// owns: point the RevenueCat offering at an annual package and the button
// silently misstates what the user is buying. App Review requires the period be
// stated, so stating a wrong one is worse than the string being awkward.
enum PremiumPeriod { weekly, monthly, twoMonth, threeMonth, sixMonth, annual, lifetime }
