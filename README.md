# RepoPilot Homebrew tap

Install [RepoPilot](https://github.com/CharlieJamesGwapo/RepoPilot), a free, open-source developer shell workspace, with one command:

```sh
brew install charliejamesgwapo/tap/repopilot
```

This public third-party tap selects the published Apple Silicon or Intel macOS binary and verifies its pinned SHA-256 checksum. No Rust toolchain is required. Bash, Zsh and Fish completion definitions and the documentation are installed with the executable. RepoPilot uses your existing terminal and real shell; installed tools such as Claude, Codex and Git keep their own interfaces and authentication. Models and vendor tools are not bundled.

```sh
repopilot --version
repopilot
repopilot guide "undo last commit"
repopilot doctor .
repopilot skills list
repopilot skills export ui-review --path ./my-project --target claude
```

The branded prompt applies to interactive Zsh/Bash sessions. Other shells keep their native prompt. Run `repopilot shell --plain-prompt` to keep your own prompt. `repopilot chat` opens separate local-only model chat using saved user configuration.

## Update or uninstall

```sh
brew update
brew upgrade charliejamesgwapo/tap/repopilot
brew uninstall repopilot
```

If an earlier manually installed copy takes precedence, inspect `type -a repopilot`. Run `"$(brew --prefix)/bin/repopilot" --version` to check Homebrew's executable directly. Installation does not delete existing binaries, edit shell profiles, or change AI configuration.

## Maintenance and verification

The formula pins release v0.2.0. For a new release, update its version, both release URLs, and SHA-256 values after verifying the published downloads. Keep this file and the [application installation guide](https://github.com/CharlieJamesGwapo/RepoPilot/blob/main/docs/installation.md) current.

CI installs the published formula, audits it, tests project JSON output, offline guides, ten built-in skills, all three project skill export layouts and a real shell, and checks completions on Apple Silicon and Intel macOS. No `homebrew/core` availability, signing, notarization or unsupported macOS compatibility is claimed. Binary licensing: MIT.

Version 0.2.0 includes five Superpowers-based development workflow adaptations and five original UI/UX skills. Exports include licenses and notices, never overwrite existing skill directories, and launch no agent.
