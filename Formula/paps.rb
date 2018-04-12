class Paps < Formula
  desc "Pango to PostScript converter"
  homepage "https://paps.sourceforge.io/"
  url "https://downloads.sourceforge.net/paps/paps-0.6.8.tar.gz"
  sha256 "db214c4ea7ecde2f7986b869f6249864d3ff364e6f210c15aa2824bcbd850a20"
  revision 1

  bottle do
    cellar :any
    sha256 "180eee4688d9289f750afb0b4f763612874c7a42f2bea7ffb228a2e51f4681b9" => :high_sierra
    sha256 "8fe4408fc505e10a6fabd2d78e7fcefb33cccff53f8f404732771e3249509fb5" => :sierra
    sha256 "2a1f0244a125e9028a1d4b99fb45eec5793bc96834696fdbef823fd801c91643" => :el_capitan
  end

  depends_on "pkg-config" => :build
  depends_on "pango"
  depends_on "freetype"
  depends_on "fontconfig"
  depends_on "glib"
  depends_on "gettext"

  # Find freetype headers
  patch :DATA

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    # https://paps.sourceforge.io/small-hello.utf8
    utf8 = <<~EOS
      paps by Dov Grobgeld (דב גרובגלד)
      Printing through Παν語 (Pango)

      Arabic السلام عليكم
      Bengali (বাঙ্লা)  ষাগতোম
      Greek (Ελληνικά)  Γειά σας
      Hebrew שָׁלוֹם
      Japanese  (日本語) こんにちは, ｺﾝﾆﾁﾊ
      Chinese  (中文,普通话,汉语) 你好
      Vietnamese  (Tiếng Việt)  Xin Chào
    EOS
    safe_system "echo '#{utf8}' |  #{bin}/paps > paps.ps"
  end
end

__END__
diff --git a/src/libpaps.c b/src/libpaps.c
index 6081d0d..d502b68 100644
--- a/src/libpaps.c
+++ b/src/libpaps.c
@@ -25,8 +25,10 @@
 
 #include <pango/pango.h>
 #include <pango/pangoft2.h>
-#include <freetype/ftglyph.h>
-#include <freetype/ftoutln.h>
+#include <ft2build.h>
+#include FT_FREETYPE_H
+#include FT_GLYPH_H
+#include FT_OUTLINE_H
 #include <errno.h>
 #include <stdlib.h>
 #include <stdio.h>
