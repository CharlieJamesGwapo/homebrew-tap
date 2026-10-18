class Repopilot < Formula
  desc "Developer shell workspace with local diagnostics and offline workflow guides"
  homepage "https://github.com/CharlieJamesGwapo/RepoPilot"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/CharlieJamesGwapo/RepoPilot/releases/download/v0.1.0/repopilot-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "dc9534b59c62f45c08a3990840e775ebdf2d3ecf4225fb37dcf0f770a1e9754f"
    end

    on_intel do
      url "https://github.com/CharlieJamesGwapo/RepoPilot/releases/download/v0.1.0/repopilot-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "64f4defaacb97794f7cf85d55a88735039c7038febb7dc7407add0b2aacc568a"
    end
  end

  depends_on :macos

  def install
    bin.install "repopilot"
    doc.install "docs"
    generate_completions_from_executable(bin/"repopilot", "completions", shells: [:bash, :zsh, :fish])
  end

  def caveats
    <<~EOS
      Run repopilot to open your shell, or repopilot --help to explore.
      Local AI chat: repopilot chat (requires a separately configured local model).
      Existing installs earlier on PATH may take precedence; check type -a repopilot.
    EOS
  end

  test do
    assert_match "repopilot 0.1.0", shell_output("#{bin}/repopilot --version")
    report = JSON.parse(shell_output("#{bin}/repopilot scan #{testpath} --json"))
    assert_equal 1, report["schema_version"]
    guide = JSON.parse(shell_output("#{bin}/repopilot guide undo --json"))
    assert_equal "undo", guide["id"]
    ENV["SHELL"] = "/bin/sh"
    assert_match "REPOPILOT_BREW_SHELL_OK",
      pipe_output("#{bin}/repopilot shell --plain-prompt", "printf 'REPOPILOT_BREW_SHELL_OK\\n'\nexit 0\n", 0)
  end
end
