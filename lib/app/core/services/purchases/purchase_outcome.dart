// Cancelling is not a failure. The store sheet reports a user backing out as an
// error, and treating it as one would show a toast for a deliberate action - so
// it is a distinct outcome rather than a thrown error.
enum PurchaseOutcome { purchased, cancelled }
