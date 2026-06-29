class SaasChurnPredictor < Formula
  desc "SaaS churn prediction with sklearn pipelines for subscription businesses"
  homepage "https://github.com/Coding-Dev-Tools/SaAS-Churn-Predictor"
  url "https://github.com/Coding-Dev-Tools/SaaS-Churn-Predictor/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  depends_on "python@3.10"

  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/churn-predictor"
  end

  test do
    system bin/"churn-predictor", "--help"
  end
end
