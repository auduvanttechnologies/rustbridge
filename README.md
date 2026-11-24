# RustBridge

**Write familiar. Compile native.** RustBridge translates Java into safe, idiomatic Rust, then compiles it, runs it, and repairs it until it prints exactly what your Java program prints.

Website: https://rustbridge.auduvanttechnologies.com

> Free beta. Single-file Java programs today; multi-file projects and Spring Boot are next.

## Install

You need **Java 21+** and **Rust** (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`).

macOS and Linux:

```bash
curl -fsSL https://rustbridge.auduvanttechnologies.com/install.sh | sh
```

Or download `rustbridge.jar` from the [latest release](https://github.com/auduvanttechnologies/rustbridge/releases/latest) and run it with `java -jar rustbridge.jar` (this works on Windows too).

## Use

```bash
rustbridge selftest                 # checks java, cargo and the repair loop (no account needed)
rustbridge login                    # sign in with GitHub
rustbridge translate MyProgram.java # writes rust-out/MyProgram/ with a Cargo project and a report
rustbridge whoami                   # plan and translations left this month
```

RustBridge runs your Java program first to capture its output, then checks that the Rust prints the same thing. Use `--no-run` to only require that the Rust compiles.

## Plans

| | Free | Pro ($15/month per seat) | Your own Anthropic key |
|---|---|---|---|
| Translations | 3 per month | unlimited | unlimited |
| File size | up to 300 lines | no limit | no limit |
| Sign-in | GitHub | GitHub | not needed |

Pro is available at launch in January 2027. To use your own key:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
rustbridge translate MyProgram.java --provider anthropic
```

## Privacy

- RustBridge does not store your code. Only counts are kept (tokens, repairs, pass or fail).
- Compiling and running happen on your machine.
- Your own Anthropic key is used for one request at a time and never saved.
- After each translation, an anonymous report (pass or fail and counts, never code) helps measure quality. Turn it off with `RUSTBRIDGE_NO_REPORT=1`.

## Feedback

Found a program RustBridge gets wrong? [Open an issue](https://github.com/auduvanttechnologies/rustbridge/issues/new). Include the Java file only if you're happy for it to become a test case.

© 2026 Auduvant Technologies. This repository holds the website and releases; the RustBridge source is private.
