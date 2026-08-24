class Apighost < Formula
  desc "Mock API server from an OpenAPI spec with VCR cassette record and replay"
  homepage "https://github.com/Coding-Dev-Tools/apighost"
  url "https://github.com/Coding-Dev-Tools/apighost/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "953d5995c710528fcf552fdaab6a04df22c950828cc6f72a936ac080c274021d"
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/apighost"
  end

  test do
    system bin/"apighost", "--help"
  end
end
