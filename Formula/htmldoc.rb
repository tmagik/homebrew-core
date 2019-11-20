class Htmldoc < Formula
  desc "Convert HTML to PDF or PostScript"
  homepage "https://www.msweet.org/htmldoc/"
  url "https://github.com/michaelrsweet/htmldoc/archive/v1.9.7.tar.gz"
  sha256 "bbd7befc5aaf7f999b96010e887679e4107413df7803b3d50a6240e0d9abf402"
  head "https://github.com/michaelrsweet/htmldoc.git"

  bottle do
    sha256 "d497f1e790c2f12e03ea57ab1f4a88664e4d020b9cccf824037c4c206c5b955e" => :catalina
    sha256 "0498d4b2eaefc26ea47807f46bdbe447aaf31b6eea93b61431cc3c8f0cd4925d" => :mojave
    sha256 "3398497f149442b48e946f051d2ccf3b75a27bbac5578ee1cf725312869a6828" => :high_sierra
  end

  depends_on "jpeg"
  depends_on "libpng"

  def install
    system "./configure", "--disable-debug",
                          "--disable-ssl",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/htmldoc", "--version"
  end
end
