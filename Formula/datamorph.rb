class Datamorph < Formula
  desc "Convert between CSV, JSON, YAML, Parquet, Avro, Protobuf with streaming"
  homepage "https://github.com/Coding-Dev-Tools/datamorph"
  url "https://github.com/Coding-Dev-Tools/datamorph/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "29fd37d02172b3a1994eb15f71d650d82e55ca9bea0459f0cff3a6a1bda6b0b9"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/datamorph"
  end

  test do
    system bin/"datamorph", "--help"
  end
end
