class Json2sqlCli < Formula
  desc "Convert JSON files to SQL CREATE TABLE and INSERT statements automatically"
  homepage "https://github.com/Coding-Dev-Tools/json2sql"
  url "https://github.com/Coding-Dev-Tools/json2sql/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "c3e2137c9bd5f2dd10319ba0d0cfb90a5d3452cafcb781d3d29a1c50c6aa3894"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/json2sql"
  end

  test do
    system bin/"json2sql", "--help"
  end
end
