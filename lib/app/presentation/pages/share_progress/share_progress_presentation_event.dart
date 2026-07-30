sealed class ShareProgressPresentationEvent {}

class ShareProgressShowLoading implements ShareProgressPresentationEvent {}

class ShareProgressHideLoading implements ShareProgressPresentationEvent {}

// Carries no message: nothing here produces a VTError, and the only failures are
// a boundary that could not be read and a share sheet that refused - neither has
// a sentence the user can act on beyond "try again", which the page states.
class ShareProgressFailed implements ShareProgressPresentationEvent {}
