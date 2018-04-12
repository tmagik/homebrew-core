class Planck < Formula
  desc "Stand-alone ClojureScript REPL"
  homepage "http://planck-repl.org/"
  url "https://github.com/mfikes/planck/archive/2.12.6.tar.gz"
  sha256 "44174df56c79dac1f755606a30c35145303512cbab49bb389b2cd639e86132bd"
  revision 1
  head "https://github.com/mfikes/planck.git"

  bottle do
    cellar :any
    sha256 "567277d275232b81c49cd3cd9af3ca49c367a1f4d8c6df0db717da7c9239e094" => :high_sierra
    sha256 "ba7f398b53b9a5677c1bb2ee0bd30343eec1d010cbe9ad69070fb01567efe6f8" => :sierra
    sha256 "2f4c4267baab304d8ae11e46b0dcd23f0f5acd55f11ed2b1f14df8a72a49dbee" => :el_capitan
  end

  depends_on "clojure" => :build
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on :xcode => :build
  depends_on "libzip"
  depends_on "icu4c"
  depends_on :macos => :mavericks

  def install
    system "./script/build-sandbox"
    bin.install "planck-c/build/planck"
  end

  test do
    assert_equal "0", shell_output("#{bin}/planck -e '(- 1 1)'").chomp
  end
end
