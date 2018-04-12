class DnscryptWrapper < Formula
  desc "Server-side proxy that adds dnscrypt support to name resolvers"
  homepage "https://cofyc.github.io/dnscrypt-wrapper/"
  url "https://github.com/cofyc/dnscrypt-wrapper/archive/v0.4.1.tar.gz"
  sha256 "da5624098bebf59085eb2211a3fab168e9a2a266e901c6a8dc3abaaca4e1b278"
  head "https://github.com/Cofyc/dnscrypt-wrapper.git"

  bottle do
    cellar :any
    sha256 "ea9ee8d3e27d21906fd1319ae23dcc42fd35d8b8833c558392db5b302870a24b" => :high_sierra
    sha256 "50da00dbfaa78a699d47f8c9f80818d6ae23149af86ba1e99e493b3748b50b0e" => :sierra
    sha256 "fd337e04cffac7af7eaf24b9a191bacd012a3b458d247d6a266274d0968702d3" => :el_capitan
  end

  depends_on "autoconf" => :build
  depends_on "libsodium"
  depends_on "libevent"

  def install
    system "make", "configure"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{sbin}/dnscrypt-wrapper", "--gen-provider-keypair",
           "--provider-name=2.dnscrypt-cert.example.com",
           "--ext-address=192.168.1.1"
    system "#{sbin}/dnscrypt-wrapper", "--gen-crypt-keypair"
  end
end
