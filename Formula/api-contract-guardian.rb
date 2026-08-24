class ApiContractGuardian < Formula
  desc "Monitor OpenAPI schema diffs, detect breaking changes, generate migration guides"
  homepage "https://github.com/Coding-Dev-Tools/api-contract-guardian"
  url "https://github.com/Coding-Dev-Tools/api-contract-guardian/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "edd9eaa56f97181e052ef3932aad29f1ef79aaf45b5afe0df089982f779177ba"
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/api-contract-guardian"
  end

  test do
    system bin/"api-contract-guardian", "--help"
  end
end
