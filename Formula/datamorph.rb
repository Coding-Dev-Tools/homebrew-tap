class Datamorph < Formula
  desc "CLI tool for batch converting between data formats (CSV, JSON, YAML, Parquet, Avro, Protobuf) with streaming for large files"
  homepage "https://github.com/Coding-Dev-Tools/datamorph"
  url "https://github.com/Coding-Dev-Tools/datamorph/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "ae3ce3938c0be458a427c0e3c224ab231d512ea3a3fb8b62d20dea958831fc97"
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
