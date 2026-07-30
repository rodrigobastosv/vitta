// Dismissing the share sheet is not a failure. The OS reports "the user backed
// out" the same way it reports "there was nothing to share with", and treating
// both as errors would toast a deliberate action - the PurchaseOutcome.cancelled
// call, applied to sharing.
enum ShareOutcome { shared, dismissed, failed }
