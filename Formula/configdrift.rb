class Configdrift < Formula
  desc "Track and detect configuration drift across environments over time"
  homepage "https://github.com/Coding-Dev-Tools/configdrift"
  url "https://github.com/Coding-Dev-Tools/configdrift/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "045633fc5e7dc4e5f13b2922c25843531e5f176a13971f01a9f48dde5108ca7d"
  license "MIT"
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/configdrift"
  end

  test do
    system bin/"configdrift", "--help"
  end
end
