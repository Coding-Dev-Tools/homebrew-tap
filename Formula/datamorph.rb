class Datamorph < Formula
  desc "CLI tool for batch converting between data formats (CSV, JSON, YAML, Parquet, Avro, Protobuf) with streaming for large files"
  homepage "https://github.com/Coding-Dev-Tools/datamorph"
  url "https://github.com/Coding-Dev-Tools/datamorph/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "09228586066e9082d834c56fffa501c1507788659a0a87b56029c6be12c65a9d"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/datamorph"
  end

  test do
    system bin/"datamorph", "--help"
  end
end
