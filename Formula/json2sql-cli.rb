class Json2sqlCli < Formula
  desc "Convert JSON files to SQL CREATE TABLE and INSERT statements automatically"
  homepage "https://github.com/Coding-Dev-Tools/json2sql"
  url "https://github.com/Coding-Dev-Tools/json2sql/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "28fa15bbdbed2662fcea1ee3788e54c6a1f0701fd893461e2564c996b557ec6d"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/json2sql"
  end

  test do
    system bin/"json2sql", "--help"
  end
end
