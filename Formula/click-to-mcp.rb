class ClickToMcp < Formula
  desc "Convert any Python Click/Typer CLI into an MCP server automatically"
  homepage "https://github.com/Coding-Dev-Tools/click-to-mcp"
  url "https://github.com/Coding-Dev-Tools/click-to-mcp/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "98cde7c8ca0a9ff709ecb0e35333c125839ee251d18c8442d3d755e3bc798c8c"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/click-to-mcp"
  end

  test do
    system bin/"click-to-mcp", "--help"
  end
end
