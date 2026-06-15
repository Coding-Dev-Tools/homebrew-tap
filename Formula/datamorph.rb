class Datamorph < Formula
  desc "CLI tool for batch converting between data formats (CSV, JSON, YAML, Parquet, Avro, Protobuf) with streaming for large files"
  homepage "https://github.com/Coding-Dev-Tools/datamorph"
  url "https://github.com/Coding-Dev-Tools/datamorph/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: update after pushing tag v0.1.1
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
