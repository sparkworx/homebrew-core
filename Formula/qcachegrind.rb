class Qcachegrind < Formula
  desc "Visualize data generated by Cachegrind and Calltree"
  homepage "https://kcachegrind.github.io/"
  url "https://download.kde.org/stable/release-service/22.08.3/src/kcachegrind-22.08.3.tar.xz"
  sha256 "160b9b2f28e1e6986026c0fc3dc34df26d56d88e3355704a0226e60786218ac7"
  license "GPL-2.0-or-later"

  # We don't match versions like 19.07.80 or 19.07.90 where the patch number
  # is 80+ (beta) or 90+ (RC), as these aren't stable releases.
  livecheck do
    url "https://download.kde.org/stable/release-service/"
    regex(%r{href=.*?v?(\d+\.\d+\.(?:(?![89]\d)\d+)(?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "9b9f7af3860e52b3554512bc3b5c52042f1c4befb1afe0544936f4729481b796"
    sha256 cellar: :any,                 arm64_big_sur:  "a2b003c866eeae651aae80ceaf4e4bd10aebcff306ba1d7931ecc19200fc3379"
    sha256 cellar: :any,                 monterey:       "17104378e9bbca4e16e5b173c357b03a6cfc5af2f326725e635738938aae50f8"
    sha256 cellar: :any,                 big_sur:        "c36abf53e2391a432700157469663b5d2cbd59ca14b7a958ef93893560086083"
    sha256 cellar: :any,                 catalina:       "33b2d59db95d6d7b73b29183de7a84baf653d6d4bb6999773be5586c0e1c892b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "106f5b28855b49f3adbed782f369695f49d31561a578a29fbf21d287691aead3"
  end

  depends_on "graphviz"
  depends_on "qt@5"

  fails_with gcc: "5"

  def install
    args = ["-config", "release", "-spec"]
    os = OS.mac? ? "macx" : OS.kernel_name.downcase
    compiler = ENV.compiler.to_s.start_with?("gcc") ? "g++" : ENV.compiler
    arch = Hardware::CPU.intel? ? "" : "-#{Hardware::CPU.arch}"
    args << "#{os}-#{compiler}#{arch}"

    system Formula["qt@5"].opt_bin/"qmake", *args
    system "make"

    if OS.mac?
      prefix.install "qcachegrind/qcachegrind.app"
      bin.install_symlink prefix/"qcachegrind.app/Contents/MacOS/qcachegrind"
    else
      bin.install "qcachegrind/qcachegrind"
    end
  end
end
