class Janet < Formula
  desc "Dynamic language and bytecode vm"
  homepage "https://janet-lang.org"
  url "https://github.com/janet-lang/janet/archive/v1.5.1.tar.gz"
  sha256 "abfe69c4b3af355ad37ff315fea529ac88778df357b44522f07b4df9ee4c8a60"
  head "https://github.com/janet-lang/janet.git"

  bottle do
    cellar :any
    sha256 "ef2b4b393af53a8b1ec2b48bc3934f4464fc77cad2ac60af50195f24f723af18" => :catalina
    sha256 "1e2652c44c280cd15fcd09222fb8b64b2cee66d7d441b06f4df920709fc904c9" => :mojave
    sha256 "e41086c2f6772e4d9441df4f6a3292c516e59c7ac2ffa7e76d8e511b548433dd" => :high_sierra
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build

  def install
    system "meson", "setup", "build", "--buildtype=release", "--prefix=#{prefix}"
    cd "build" do
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    assert_equal "12", shell_output("#{bin}/janet -e '(print (+ 5 7))'").strip
  end
end
