class Minbif < Formula
  desc "IRC-to-other-IM-networks gateway using Pidgin library"
  homepage "https://symlink.me/projects/minbif/wiki/"
  url "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/minbif/minbif_1.0.5+git20150505.orig.tar.gz"
  mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/m/minbif/minbif_1.0.5+git20150505.orig.tar.gz"
  version "1.0.5-20150505"
  sha256 "4e264fce518a0281de9fc3d44450677c5fa91097a0597ef7a0d2a688ee66d40b"
  revision 2

  bottle do
    cellar :any
    sha256 "350bac71d2c91bb9026924d8e2ce09a34e364961045560ede2c59c059b999d9b" => :high_sierra
    sha256 "110ae4736afaadcacb084d5aaad29f340297758c58958b57cc54fca700cf9c9b" => :sierra
    sha256 "b88890787abd2c0f692a7c371e363ac2c0bed49f361b597ce1557f102ec94b67" => :el_capitan
  end

  option "with-pam", "Build with PAM support, patching for OSX PAM headers"

  deprecated_option "pam" => "with-pam"

  depends_on "pkg-config" => :build
  depends_on "cmake" => :build
  depends_on "glib"
  depends_on "gettext"
  depends_on "pidgin"
  depends_on "gnutls"
  depends_on "imlib2" => :optional
  depends_on "libcaca" => :optional

  # Problem:  Apple doesn't have <security/pam_misc.h> so don't ask for it.
  # Reported: https://symlink.me/issues/917
  patch :DATA if build.with? "pam"

  def install
    inreplace "minbif.conf" do |s|
      s.gsub! "users = /var", "users = #{var}"
      s.gsub! "motd = /etc", "motd = #{etc}"
    end

    args = %W[
      PREFIX=#{prefix}
      ENABLE_MINBIF=ON
      ENABLE_PLUGIN=ON
      ENABLE_VIDEO=OFF
      ENABLE_TLS=ON
    ]
    args << "ENABLE_IMLIB=" + (build.with?("imlib2") ? "ON" : "OFF")
    args << "ENABLE_CACA=" + (build.with?("libcaca") ? "ON" : "OFF")
    args << "ENABLE_PAM=" + (build.with?("pam") ? "ON" : "OFF")

    system "make", *args
    system "make", "install"

    (var/"lib/minbif/users").mkpath
  end

  def caveats; <<~EOS
    Minbif must be passed its config as first argument:
        minbif #{etc}/minbif/minbif.conf

    Learn more about minbif: https://symlink.me/projects/minbif/wiki/Quick_start
    EOS
  end

  test do
    system "#{bin}/minbif", "--version"
  end
end

__END__
--- a/src/im/auth_pam.h	2012-05-14 02:44:27.000000000 -0700
+++ b/src/im/auth_pam.h	2012-10-12 10:16:47.000000000 -0700
@@ -21,7 +21,10 @@

 #include "auth.h"
 #include <security/pam_appl.h>
+
+#ifndef __APPLE__
 #include <security/pam_misc.h>
+#endif

 struct _pam_conv_func_data {
	bool update;
