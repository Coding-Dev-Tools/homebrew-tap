class Apiauth < Formula
  desc "CLI tool for API key and JWT lifecycle management with encrypted local store"
  homepage "https://github.com/Coding-Dev-Tools/apiauth"
  url "https://github.com/Coding-Dev-Tools/apiauth/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "9d9ee19a5bca31fc2b25b00eae94fa69dacea759b3ded8b03dc7ee850c6845f6"
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
