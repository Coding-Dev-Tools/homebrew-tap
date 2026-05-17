class Deploydiff < Formula
  desc "Compare deployment manifests across environments and detect configuration drift"
  homepage "https://github.com/Coding-Dev-Tools/deploydiff"
  url "https://github.com/Coding-Dev-Tools/deploydiff/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "295910ac1743d8bc314af34d0b1f859d90620eaac1388229080e11b6839e7c4c"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/deploydiff"
  end

  test do
    system bin/"deploydiff", "--help"
  end
end
