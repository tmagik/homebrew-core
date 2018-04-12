class Testssl < Formula
  desc "Tool which checks for the support of TLS/SSL ciphers and flaws"
  homepage "https://testssl.sh/"
  url "https://github.com/drwetter/testssl.sh/archive/v2.9.5-4.tar.gz"
  version "2.9.5-4"
  sha256 "5163f76d40acfe404d65145c498cbe8fb716bb49119e8d0773e063203cff9c03"
  head "https://github.com/drwetter/testssl.sh.git"

  bottle :unneeded

  depends_on "openssl"

  def install
    bin.install "testssl.sh"
    man1.install "doc/testssl.1"
    prefix.install "etc"
    env = {
      :PATH => "#{Formula["openssl"].opt_bin}:$PATH",
      :TESTSSL_INSTALL_DIR => prefix,
    }
    bin.env_script_all_files(libexec/"bin", env)
  end

  test do
    system "#{bin}/testssl.sh", "--local", "--warnings", "off"
  end
end
