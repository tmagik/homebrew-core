class RipgrepAll < Formula
  desc "Wrapper around ripgrep that adds multiple rich file types"
  homepage "https://github.com/phiresky/ripgrep-all"
  url "https://github.com/phiresky/ripgrep-all/archive/0.9.3.tar.gz"
  sha256 "06259e7c1734a9246c2d113bf5e914f4d418e53c201efc697bfc041a713fbef3"
  head "https://github.com/phiresky/ripgrep-all.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "687b7bf509f088bdb9cd0058e6346d7aa66fdddd35fe9f1095085ffc59040b69" => :catalina
    sha256 "8b0b3bb348853c51a99826d326d3bdd1ff52bab521fd6e37deaaaf0004ff77e5" => :mojave
    sha256 "ef28f16cb59908b17a4e07a39ca3804173204f2ccf333262bab3988866d5c741" => :high_sierra
  end

  depends_on "rust" => :build
  depends_on "ripgrep"

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    (testpath/"file.txt").write("Hello World")
    system "zip", "archive.zip", "file.txt"

    output = shell_output("#{bin}/rga 'Hello World' #{testpath}")
    assert_match "Hello World", output
  end
end
