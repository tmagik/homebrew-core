class Byobu < Formula
  desc "Text-based window manager and terminal multiplexer"
  homepage "http://byobu.co/"
  url "https://launchpad.net/byobu/trunk/5.125/+download/byobu_5.125.orig.tar.gz"
  sha256 "5022c82705a5d57f1d4e8dcb1819fd04628af2d4b4618b7d44fa27ebfcdda9db"

  bottle do
    cellar :any_skip_relocation
    sha256 "1f369b8fd147fec07fcee9ea20e1186b4656745f69d236850c7e181caddf3335" => :high_sierra
    sha256 "1f369b8fd147fec07fcee9ea20e1186b4656745f69d236850c7e181caddf3335" => :sierra
    sha256 "1f369b8fd147fec07fcee9ea20e1186b4656745f69d236850c7e181caddf3335" => :el_capitan
  end

  head do
    url "https://github.com/dustinkirkland/byobu.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  depends_on "coreutils"
  depends_on "gnu-sed" # fails with BSD sed
  depends_on "tmux"
  depends_on "newt"

  conflicts_with "ctail", :because => "both install `ctail` binaries"

  def install
    if build.head?
      cp "./debian/changelog", "./ChangeLog"
      system "autoreconf", "-fvi"
    end
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<~EOS
    Add the following to your shell configuration file:
      export BYOBU_PREFIX=#{HOMEBREW_PREFIX}
    EOS
  end

  test do
    system bin/"byobu-status"
  end
end
