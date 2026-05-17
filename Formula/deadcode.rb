class Deadcode < Formula
  desc "CLI tool to detect unused exports, dead routes, orphaned CSS and unreferenced components in TS/React/Next.js projects"
  homepage "https://github.com/Coding-Dev-Tools/deadcode"
  url "https://github.com/Coding-Dev-Tools/deadcode/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "23dfe7166a01e8b802906f216e48b4d3c55be0fb291687057abd4ff8cd31c1ac"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/deadcode"
  end

  test do
    system bin/"deadcode", "--help"
  end
end
