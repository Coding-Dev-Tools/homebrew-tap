class Apiauth < Formula
  desc "CLI tool for API key and JWT lifecycle management with encrypted local store"
  homepage "https://github.com/Coding-Dev-Tools/apiauth"
  url "https://github.com/Coding-Dev-Tools/apiauth/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: update after computing sha256 of tag v0.2.0
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/apiauth"
  end

  test do
    system bin/"apiauth", "--help"
  end
end
