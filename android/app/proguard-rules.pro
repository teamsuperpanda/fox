# Flutter's Gradle plugin injects the engine keep rules. Hive TypeAdapters are
# registered explicitly (no reflection), so no extra keep rules are needed for
# the data layer. Add plugin-specific rules here if a release build crashes
# after shrinking.
