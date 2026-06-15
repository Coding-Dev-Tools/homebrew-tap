class Apighost < Formula
  desc "CLI tool that reads an OpenAPI spec and spawns a realistic mock API server with VCR cassette recording and replay"
  homepage "https://github.com/Coding-Dev-Tools/apighost"
  url "https://github.com/Coding-Dev-Tools/apighost/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: push tag v0.2.0 (only v0.1.0 exists), then update sha256
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
