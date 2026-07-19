class Deploydiff < Formula
  desc "Compare deployment manifests across environments and detect configuration drift"
  homepage "https://github.com/Coding-Dev-Tools/deploydiff"
  url "https://github.com/Coding-Dev-Tools/deploydiff/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7925cdae54980e59641c879d39b40a8390f875b5ada05821ddcd8bf28a262478"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/deploydiff"
  end

  test do
    system bin/"deploydiff", "--help"
  end
end
