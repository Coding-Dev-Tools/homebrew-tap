class ClickToMcp < Formula
  desc "Convert any Python Click/Typer CLI into an MCP server automatically"
  homepage "https://github.com/Coding-Dev-Tools/click-to-mcp"
  url "https://github.com/Coding-Dev-Tools/click-to-mcp/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "14dfa3fc743cfd40451d91b87bbc0a5c354dca352e9454c409efb44f5a693c28"
  license "Apache-2.0"
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/click-to-mcp"
  end

  test do
    system bin/"click-to-mcp", "--help"
  end
end
