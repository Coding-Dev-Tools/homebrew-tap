class Apighost < Formula
  desc "CLI tool that reads an OpenAPI spec and spawns a realistic mock API server with VCR cassette recording and replay"
  homepage "https://github.com/Coding-Dev-Tools/apighost"
  url "https://github.com/Coding-Dev-Tools/apighost/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "38d17765bebcbf8d66fb1557f06004e57fd63de89b6141c2a5693e0d8f56aa48"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/apighost"
  end

  test do
    system bin/"apighost", "--help"
  end
end
