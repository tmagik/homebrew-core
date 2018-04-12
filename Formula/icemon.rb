class Icemon < Formula
  desc "Icecream GUI Monitor"
  homepage "https://github.com/icecc/icemon"
  url "https://github.com/icecc/icemon/archive/v3.1.0.tar.gz"
  sha256 "8500501d3f4968d52a1f4663491e26d861e006f843609351ec1172c983ad4464"

  bottle do
    cellar :any
    sha256 "091c0de73c69ae36a5bff744e7cf81b2321630f3499d67de139cea5782e3b0a0" => :high_sierra
    sha256 "8f4bb166755f10d04f3a20e5792ed108c86286e4451a7e87b79864835732e78d" => :sierra
    sha256 "7422122b9818ac86761695845bb7e4a63abfd483d9959b26570f9624569442c3" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "icecream"
  depends_on "lzo"
  depends_on "qt"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "#{bin}/icemon", "--version"
  end
end
