class Datamorph < Formula
  desc "CLI tool for batch converting between data formats (CSV, JSON, YAML, Parquet, Avro, Protobuf) with streaming for large files"
  homepage "https://github.com/Coding-Dev-Tools/datamorph"
  url "https://github.com/Coding-Dev-Tools/datamorph/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "4b0894723ee8d424b9643fb555423c18c1ac99e2dc2b29bb7fe186f6de1509bd"
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
