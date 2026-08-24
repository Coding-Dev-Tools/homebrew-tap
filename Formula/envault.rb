class Envault < Formula
  desc "Env variable syncing, diffing, and secret rotation with store integrations"
  homepage "https://github.com/Coding-Dev-Tools/envault"
  url "https://github.com/Coding-Dev-Tools/envault/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "db97b76ae9a63e3fdeb0745f94cf5297aadb6c18be2feb24b1bc2aa4d3af48c9"
  license "MIT"
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/envault"
  end

  test do
    system bin/"envault", "--help"
  end
end
