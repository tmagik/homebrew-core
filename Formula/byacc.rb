class Byacc < Formula
  desc "(Arguably) the best yacc variant"
  homepage "https://invisible-island.net/byacc/"
  url "https://invisible-mirror.net/archives/byacc/byacc-20191103.tgz"
  sha256 "d291fb34816f45079067366b7f7300ffbf9f7e3f1aaf6d509b84442d065d11b9"

  bottle do
    cellar :any_skip_relocation
    sha256 "816b9eca03031cdf0f8e43416e3c4d5979ac880de70eabc53fb1dd6e1ac7752a" => :catalina
    sha256 "15101b84c05e4bde2bfadd38f38f1dba5ac6723b26f609e61d9744c3599da0a6" => :mojave
    sha256 "f46bbe00c8f4afc56ea7548763f8e244632eab35d154bb3233e13418c81c92e0" => :high_sierra
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--program-prefix=b", "--prefix=#{prefix}", "--man=#{man}"
    system "make", "install"
  end

  test do
    system bin/"byacc", "-V"
  end
end
