class Nss < Formula
  desc "Libraries for security-enabled client and server applications"
  homepage "https://developer.mozilla.org/docs/NSS"
  url "https://ftp.mozilla.org/pub/security/nss/releases/NSS_3_36_RTM/src/nss-3.36.tar.gz"
  sha256 "a33cc7b8299b5ce3acf03f617c7896932ae26927ff9fb7c71c1b69a200c30095"

  bottle do
    cellar :any
    sha256 "d58bcd0519f726c67156d0feca4723d56978ede7b17d4f5818c0303532b6b388" => :high_sierra
    sha256 "468ba11a7923a8c820278014e27f4389a4a8f8ad269c796c029121aafcee3228" => :sierra
    sha256 "788a148d2cc39ead1a3804b38394b9ec209adf8a584ef51030281edc7529614a" => :el_capitan
  end

  keg_only <<~EOS
    Firefox can pick this up instead of the built-in library, resulting in
    random crashes without meaningful explanation.

    Please see https://bugzilla.mozilla.org/show_bug.cgi?id=1142646 for details
  EOS

  depends_on "nspr"

  def install
    ENV.deparallelize
    cd "nss"

    args = %W[
      BUILD_OPT=1
      NSS_USE_SYSTEM_SQLITE=1
      NSPR_INCLUDE_DIR=#{Formula["nspr"].opt_include}/nspr
      NSPR_LIB_DIR=#{Formula["nspr"].opt_lib}
    ]
    args << "USE_64=1" if MacOS.prefer_64_bit?

    # Remove the broken (for anyone but Firefox) install_name
    inreplace "coreconf/Darwin.mk", "-install_name @executable_path", "-install_name #{lib}"
    inreplace "lib/freebl/config.mk", "@executable_path", lib

    system "make", "all", *args

    # We need to use cp here because all files get cross-linked into the dist
    # hierarchy, and Homebrew's Pathname.install moves the symlink into the keg
    # rather than copying the referenced file.
    cd "../dist"
    bin.mkpath
    Dir.glob("Darwin*/bin/*") do |file|
      cp file, bin unless file.include? ".dylib"
    end

    include_target = include + "nss"
    include_target.mkpath
    Dir.glob("public/{dbm,nss}/*") { |file| cp file, include_target }

    lib.mkpath
    libexec.mkpath
    Dir.glob("Darwin*/lib/*") do |file|
      if file.include? ".chk"
        cp file, libexec
      else
        cp file, lib
      end
    end
    # resolves conflict with openssl, see #28258
    rm lib/"libssl.a"

    (bin/"nss-config").write config_file
    (lib/"pkgconfig/nss.pc").write pc_file
  end

  test do
    # See: https://developer.mozilla.org/docs/Mozilla/Projects/NSS/tools/NSS_Tools_certutil
    (testpath/"passwd").write("It's a secret to everyone.")
    system "#{bin}/certutil", "-N", "-d", pwd, "-f", "passwd"
    system "#{bin}/certutil", "-L", "-d", pwd
  end

  # A very minimal nss-config for configuring firefox etc. with this nss,
  # see https://bugzil.la/530672 for the progress of upstream inclusion.
  def config_file; <<~EOS
    #!/bin/sh
    for opt; do :; done
    case "$opt" in
      --version) opt="--modversion";;
      --cflags|--libs) ;;
      *) exit 1;;
    esac
    pkg-config "$opt" nss
    EOS
  end

  def pc_file; <<~EOS
    prefix=#{prefix}
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib
    includedir=${prefix}/include/nss

    Name: NSS
    Description: Mozilla Network Security Services
    Version: #{version}
    Requires: nspr >= 4.12
    Libs: -L${libdir} -lnss3 -lnssutil3 -lsmime3 -lssl3
    Cflags: -I${includedir}
    EOS
  end
end
