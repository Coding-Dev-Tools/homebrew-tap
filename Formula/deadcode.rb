class Deadcode < Formula
  desc "Detect unused exports, dead routes, and orphaned CSS in TS/React/Next.js"
  homepage "https://github.com/Coding-Dev-Tools/deadcode"
  url "https://github.com/Coding-Dev-Tools/deadcode/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "52cc212289b607760dbac702508e5a583d0d4ff2f5705f9f08e0d949264d068d"
  license "MIT"

  depends_on "python@3.10"

  def install
    system Formula["python@3.10"].opt_libexec/"bin/pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/deadcode"
  end

  test do
    system bin/"deadcode", "--help"
  end
end
