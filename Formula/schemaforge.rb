class Schemaforge < Formula
  desc "Bidirectional ORM schema converter for SQL DDL, Prisma, Drizzle, and TypeORM"
  homepage "https://github.com/Coding-Dev-Tools/schemaforge"
  url "https://github.com/Coding-Dev-Tools/schemaforge/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "b7f523d16a04c9ff4b010a8a9765c117c008b9281d3a3bd675e079623538a092"
  license "MIT"

  depends_on "python@3.10"

  def install
    system Formula["python@3.10"].opt_libexec/"bin/pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/schemaforge"
  end

  test do
    system bin/"schemaforge", "--help"
  end
end
