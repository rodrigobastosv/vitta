// What a premium subscription unlocks. Every case is a feature whose cost scales
// with use (an Anthropic call per invocation), which is the whole reason the
// paywall exists - see docs/premium-setup.md. Adding one is a case here plus its
// premiumFeatureLabel/premiumFeatureIcon entry in the presentation layer.
enum PremiumFeature { mealScan, nutritionLabelScan }
