class ApiContractGuardian < Formula
  desc "Monitor OpenAPI schema diffs, detect breaking changes, generate migration guides"
  homepage "https://github.com/Coding-Dev-Tools/api-contract-guardian"
  url "https://github.com/Coding-Dev-Tools/api-contract-guardian/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "df78aab4bf1158411a059b3554c0791a1fcd06f6fc0e380725cdfcdbe131e01c"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/api-contract-guardian"
  end

  test do
    system bin/"api-contract-guardian", "--help"
  end
end
