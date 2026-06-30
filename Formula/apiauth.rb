class Apiauth < Formula
  desc "CLI tool for API key and JWT lifecycle management with encrypted local store"
  homepage "https://github.com/Coding-Dev-Tools/apiauth"
  url "https://github.com/Coding-Dev-Tools/apiauth/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "88ab13398ff83060a6cbd96fa6f19614ec6ee24e8d9884a02ab4bbf13ad48e8e"
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

