class Htop < Formula
  desc "Improved top (interactive process viewer)"
  homepage "https://hisham.hm/htop/"
  url "https://hisham.hm/htop/releases/2.2.0/htop-2.2.0.tar.gz"
  sha256 "d9d6826f10ce3887950d709b53ee1d8c1849a70fa38e91d5896ad8cbc6ba3c57"

  bottle do
    sha256 "67d87dbcf3999869beff0dd10916a01aa44cc063873c1b80a1636ad2fc14c894" => :high_sierra
    sha256 "be217a990dab3c3ebc946cb249ba092ffcba8b6fbd3757323fd7d3c9d129ec54" => :sierra
    sha256 "c53584a82a9d6de21ac49a99f4747580b2a614313f3707318b5ccbd77c7813f8" => :el_capitan
  end

  head do
    url "https://github.com/hishamhm/htop.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-ncurses", "Build using homebrew ncurses (enables mouse scroll)"

  depends_on "pkg-config" => :build
  depends_on "ncurses" => :optional

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<~EOS
    htop requires root privileges to correctly display all running processes,
    so you will need to run `sudo htop`.
    You should be certain that you trust any software you grant root privileges.
    EOS
  end

  test do
    pipe_output("#{bin}/htop", "q", 0)
  end
end
