class Repopilot < Formula
  desc "Developer shell workspace with local diagnostics and offline workflow guides"
  homepage "https://github.com/CharlieJamesGwapo/RepoPilot"
  license "MIT"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/CharlieJamesGwapo/RepoPilot/releases/download/v0.2.0/repopilot-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "a3d4c7b00048b6b753ddcac43d823045f1715704e1bb99da9dc15109712de917"
    end

    on_intel do
      url "https://github.com/CharlieJamesGwapo/RepoPilot/releases/download/v0.2.0/repopilot-v0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "49a86a09d1bf5b58bd931e0d9013c17d3107a8076d1e62ca2311f8af7eda4f14"
    end
  end

  def install
    bin.install "repopilot"
    doc.install "docs", "THIRD_PARTY_NOTICES.md"
    doc.install "licenses"
    generate_completions_from_executable(bin/"repopilot", "completions")
  end

  def caveats
    <<~EOS
      Run repopilot to open your shell, or repopilot --help to explore.
      Local AI chat: repopilot chat (requires a separately configured local model).
      Existing installs earlier on PATH may take precedence; check type -a repopilot.
    EOS
  end

  test do
    assert_match "repopilot 0.2.0", shell_output("#{bin}/repopilot --version")
    report = JSON.parse(shell_output("#{bin}/repopilot scan #{testpath} --json"))
    assert_equal 1, report["schema_version"]
    guide = JSON.parse(shell_output("#{bin}/repopilot guide undo --json"))
    assert_equal "undo", guide["id"]
    skills = JSON.parse(shell_output("#{bin}/repopilot skills list --json"))
    assert_equal 10, skills.length
    %w[portable codex claude].each do |target|
      args = "#{bin}/repopilot skills export debugging --path #{testpath} --target #{target} --json"
      planned = JSON.parse(shell_output("#{args} --dry-run"))
      assert_equal "planned", planned["status"]
      refute_path_exists Pathname(planned["destination"])
      exported = JSON.parse(shell_output(args))
      destination = Pathname(exported["destination"])
      assert_match "name: repopilot-debugging", (destination/"SKILL.md").read
      assert_match "Jesse Vincent", (destination/"LICENSE.txt").read
      assert_match "Superpowers", (destination/"NOTICE.md").read
      assert_match "already exists", shell_output("#{args} 2>&1", 1)
    end
    ENV["SHELL"] = "/bin/sh"
    assert_match "REPOPILOT_BREW_SHELL_OK",
      pipe_output("#{bin}/repopilot shell --plain-prompt", "printf 'REPOPILOT_BREW_SHELL_OK\\n'\nexit 0\n", 0)
  end
end
