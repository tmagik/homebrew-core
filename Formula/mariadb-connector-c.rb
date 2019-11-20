class MariadbConnectorC < Formula
  desc "MariaDB database connector for C applications"
  homepage "https://downloads.mariadb.org/connector-c/"
  url "https://downloads.mariadb.org/f/connector-c-3.1.5/mariadb-connector-c-3.1.5-src.tar.gz"
  sha256 "a9de5fedd1a7805c86e23be49b9ceb79a86b090ad560d51495d7ba5952a9d9d5"

  bottle do
    sha256 "fdf27a6f365f5cbec0bf409b10ddb02056da0eb9483d6958d9d5e4c8c54fe617" => :catalina
    sha256 "680fff9dd70d273a315548cec4de78192b644d8deb59078dedfc4eccdbbaf992" => :mojave
    sha256 "1875f4687849dc2ab68d9e877936e77494e2e029dd6f666237fd04e0b0bb6164" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"

  conflicts_with "mysql", "mariadb", "percona-server",
                 :because => "both install plugins"

  def install
    args = std_cmake_args
    args << "-DWITH_OPENSSL=On"
    args << "-DOPENSSL_INCLUDE_DIR=#{Formula["openssl@1.1"].opt_include}"
    args << "-DCOMPILATION_COMMENT=Homebrew"

    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    system "#{bin}/mariadb_config", "--cflags"
  end
end
