/// What a screen can ask to be told about when it changes elsewhere — one case
/// per area of the app rather than one per table, so nothing above `data/` has
/// to know that a workout is three tables or that a day's macros come from a
/// join. A topic says only that the area is stale; the subscriber re-reads it.
enum SyncTopic { diet, water, reminders, sleep, bodyWeight, workout }
