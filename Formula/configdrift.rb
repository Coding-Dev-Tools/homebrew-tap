class Configdrift < Formula
  desc "Track and detect configuration drift across environments over time"
  homepage "https://github.com/Coding-Dev-Tools/configdrift"
  url "https://github.com/Coding-Dev-Tools/configdrift/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "fef60b059345d4d94214f3b9e8aa9738ddca088e1352c940bcf4ac9db04dfcba"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/configdrift"
  end

  test do
    system bin/"configdrift", "--help"
  end
end
