class Znc < Formula
  desc "Advanced IRC bouncer"
  homepage "https://wiki.znc.in/ZNC"
  url "https://znc.in/releases/archive/znc-1.6.6.tar.gz"
  sha256 "7fb841bc71dc1749b1dc081e9eaf22ceb56ebb03c6b1d8804a4f9eb8bbd59525"

  bottle do
    sha256 "cccf19254d52f863a4601feff82e27be9609aa908f735481bdb04e6db5154fa3" => :high_sierra
    sha256 "ad84c8a556a11af8f22cdfe48c6698a102a3e3db7204b6783a032925e429295a" => :sierra
    sha256 "ea1dcaa03bc34f801d0ee5c2c7d357c26a04fde92c02bed347c00f40f5f96c9b" => :el_capitan
  end

  head do
    url "https://github.com/znc/znc.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-debug", "Compile ZNC with debug support"
  option "with-icu4c", "Build with icu4c for charset support"
  option "with-python3", "Build with mod_python support, allowing Python ZNC modules"

  deprecated_option "enable-debug" => "with-debug"
  deprecated_option "with-python3" => "with-python"

  depends_on "pkg-config" => :build
  depends_on "openssl"
  depends_on "icu4c" => :optional
  depends_on "python" => :optional

  needs :cxx11

  def install
    ENV.cxx11
    # These need to be set in CXXFLAGS, because ZNC will embed them in its
    # znc-buildmod script; ZNC's configure script won't add the appropriate
    # flags itself if they're set in superenv and not in the environment.
    ENV.append "CXXFLAGS", "-std=c++11"
    ENV.append "CXXFLAGS", "-stdlib=libc++" if ENV.compiler == :clang

    args = ["--prefix=#{prefix}"]
    args << "--enable-debug" if build.with? "debug"
    args << "--enable-python" if build.with? "python"

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  plist_options :manual => "znc --foreground"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/znc</string>
          <string>--foreground</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/log/znc.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/znc.log</string>
        <key>RunAtLoad</key>
        <true/>
        <key>StartInterval</key>
        <integer>300</integer>
      </dict>
    </plist>
    EOS
  end

  test do
    mkdir ".znc"
    system bin/"znc", "--makepem"
    assert_predicate testpath/".znc/znc.pem", :exist?
  end
end
