class Repopilot < Formula
  desc "Developer shell workspace with local diagnostics and offline workflow guides"
  homepage "https://github.com/CharlieJamesGwapo/RepoPilot"
  license "MIT"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/CharlieJamesGwapo/RepoPilot/releases/download/v0.3.0/repopilot-v0.3.0-aarch64-apple-darwin.tar.gz"
      sha256 "b5d567dc14d7b7787eac615e228a756cd399d761c72d724347606f835ea71eb8"
    end

    on_intel do
      url "https://github.com/CharlieJamesGwapo/RepoPilot/releases/download/v0.3.0/repopilot-v0.3.0-x86_64-apple-darwin.tar.gz"
      sha256 "80894685c32b6485fa9daae4a9c4f46f4c9ed0a081ae81f01567924662ab5355"
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
    assert_match "repopilot 0.3.0", shell_output("#{bin}/repopilot --version")
    report = JSON.parse(shell_output("#{bin}/repopilot scan #{testpath} --json"))
    assert_equal 1, report["schema_version"]
    guide = JSON.parse(shell_output("#{bin}/repopilot guide undo --json"))
    assert_equal "undo", guide["id"]
    skills = JSON.parse(shell_output("#{bin}/repopilot skills list --json"))
    assert_equal 10, skills.length
    project = testpath/"project"
    project.mkpath
    %w[portable codex claude].each do |target|
      args = "#{bin}/repopilot skills export debugging --path #{project} --target #{target} --json"
      planned = JSON.parse(shell_output("#{args} --dry-run"))
      assert_equal "planned", planned["status"]
      refute_path_exists Pathname(planned["destination"])
      exported = JSON.parse(shell_output(args))
      destination = Pathname(exported["destination"])
      assert_match "name: repopilot-debugging", (destination/"SKILL.md").read
      assert_match "Jesse Vincent", (destination/"LICENSE.txt").read
      assert_match "Superpowers", (destination/"NOTICE.md").read
      assert_match "already exists", shell_output("#{args} 2>&1", 2)
    end
    models = JSON.parse(shell_output("#{bin}/repopilot models list --json"))
    assert_equal %w[balanced light workstation], models.map { |model| model["id"] }.sort
    config = project/"local-model.toml"
    setup = "#{bin}/repopilot models setup light --output #{config} --json"
    created = JSON.parse(shell_output(setup))
    assert_equal "created", created["status"]
    assert_equal false, created["network_accessed"]
    original = config.read
    shell_output("#{setup} 2>&1", 2)
    assert_equal original, config.read
    visible = JSON.parse(shell_output("#{bin}/repopilot --config #{config} config --json"))
    assert_equal "qwen2.5-coder:1.5b", visible["providers"]["local-coder"]["model"]
    assert_equal "http://127.0.0.1:11434/v1", visible["providers"]["local-coder"]["endpoint"]
    chat = pipe_output("#{bin}/repopilot --config #{config} chat --local --max-output-tokens 16",
                       "/budget\n/usage\n/exit\n", 0)
    assert_match '"max_output_tokens": 16', chat
    assert_match '"successful_requests": 0', chat
    assert_match "max-output-tokens",
      shell_output("#{bin}/repopilot --config #{config} ask hello --local --max-output-tokens 0 2>&1", 2)
    ENV["SHELL"] = "/bin/sh"
    assert_match "REPOPILOT_BREW_SHELL_OK",
      pipe_output("#{bin}/repopilot shell --plain-prompt", "printf 'REPOPILOT_BREW_SHELL_OK\\n'\nexit 0\n", 0)
  end
end
