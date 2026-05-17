class Schemaforge < Formula
  desc "Bidirectional ORM schema converter — convert between SQL DDL, Prisma, Drizzle, TypeORM, and Django models with zero-loss roundtripping"
  homepage "https://github.com/Coding-Dev-Tools/schemaforge"
  url "https://github.com/Coding-Dev-Tools/schemaforge/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "fb83df245654c33e28f075bce99536f039f399efeb74995c069545ec0a85e799"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/schemaforge"
  end

  test do
    system bin/"schemaforge", "--help"
  end
end
