class Scamper < Formula
  desc "Advanced traceroute and network measurement utility"
  homepage "https://www.caida.org/tools/measurement/scamper/"
  url "https://www.caida.org/tools/measurement/scamper/code/scamper-cvs-20191102.tar.gz"
  sha256 "a5f1856546a30d8362377a1489de8c566c31c3b93744909cf6bea5b7cbd92645"

  bottle do
    cellar :any
    sha256 "1a0f5c1946b62fb7fd92ee13f8313c8cc1aab2b167ed379a58480e6f6a033df5" => :catalina
    sha256 "c42efb0765d212d5df33142b3923c0e04d49e0f58891f15530796838c6ff9e17" => :mojave
    sha256 "8887037431a396ab36e404588554c8729e96b9da785e4216817832f2c805242d" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "openssl@1.1"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
