/// Why a load is running, which is what decides whether the global loading
/// overlay is raised for it. A load method serves several triggers — the first
/// read, a pull, a pop, paging to another day — and only the trigger knows
/// whether anything on screen already stands in for the wait.
///
/// [replace] is every load method's default: assume nothing covers the wait, and
/// let the callers that know better ([quiet]) opt out. A load that goes silent by
/// accident reads as a screen that ignored the tap.
enum LoadTrigger {
  /// Something on screen already answers for the wait: the first-load skeleton,
  /// the pull-to-refresh spinner, or the content itself during a background
  /// revalidation. Raising the overlay on top of one of those is the double
  /// indicator issue #266 reports.
  quiet,

  /// Nothing on screen stands in for the wait — the content is being replaced
  /// (another day, month or range), or a failed load is being retried.
  replace;

  bool get showsOverlay => switch (this) {
    .quiet => false,
    .replace => true,
  };
}
