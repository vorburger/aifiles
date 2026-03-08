# Java Coding Conventions

## Java Version

- Assume projects target at least Java 17. There is no need to worry about backwards compability with older Java releases
- Determine a project's Java language level, based on build tool settings, or existing usages.
- Use Java 25 syntax and API language features, when a project is already using Java 25.

## Syntax

- Use [pattern-matching `instanceof`](https://errorprone.info/bugpattern/PatternMatchingInstanceof) when possible
- **NEVER** use fully qualified class names; ALWAYS add any required missing imports instead;
  e.g. generate code using `new HashMap<>();` instead of `new java.util.HashMap<>();` etc.

## Testing

- If the project uses modern JUnit v5 (Jupiter) API, then do not prefix JUnit @Test methods with `test`, just use a descriptive name without the prefix.
  Do use `test` prefixes on projects with older JUnit versions which still required this.
- Use Google Truth instead of JUnit's own (or any other) assertions, where possible.
  For testing that exceptions are thrown, use `org.junit.jupiter.api.Assertions.assertThrows` because Google Truth doesn't have an equivalent.

## Structure

- Name unused variables `_` instead of `unused`
- Use `var` for local variable declarations where the type is obvious from the right-hand side
- Every new package must contain a package-info.java file with a package description and @NullMarked.

## Logging

- Use SLF4j API for logging
- Never use `System.err.println()` or `e.printStackTrace()`. Use a SLF4j logger instead, add it if it's missing.
- Logger should never be constructor injected, but always simply be a static final field.

## Guava

- Use Guava's Immutable Collections instead of Java Collections Framework where appropriate
- Use Guava utilities instead of JDK equivalents where appropriate
- Use Guava's `Strings.isNullOrEmpty()` instead of `string == null || string.isBlank()`

## Jackson

- Because we always compile with -parameters, we typically do not need to add any @JsonCreator or @JsonProperty
  annotations - except on both interfaces and for enum values, where they ARE required. (If a project's build
  tool configuration is missing whatever that tool's way to use `-parameters` is, then enable it.)

## Other

- Uses ErrorProne for static analysis; follow it recommendations
- Uses JSpecify annotations for nullability (`@Nullable`, `@NonNull`).
  Always replace any existing `javax.annotation` with it.
