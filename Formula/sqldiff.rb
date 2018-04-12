class Sqldiff < Formula
  desc "Displays the differences between SQLite databases"
  homepage "https://www.sqlite.org/sqldiff.html"
  url "https://sqlite.org/2018/sqlite-src-3230000.zip"
  version "3.23.0"
  sha256 "22422e1d34ecc21af5d374c328c540a3a6e32d7d6cf3c57be8b51b523b98d633"

  bottle do
    cellar :any_skip_relocation
    sha256 "cc43e028e2e57e4229e8cfe16e83b4de3261e912932edae2fe7279a9dfc2d024" => :high_sierra
    sha256 "7262de28794ec195efdd7ed56852e6821e0ed99639412ef54c448b78f5a00498" => :sierra
    sha256 "d959477848e6fdbb465f9c4d3c9ce66579440a501cf4a0a91bab5bb9a27a228b" => :el_capitan
  end

  def install
    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make", "sqldiff"
    bin.install "sqldiff"
  end

  test do
    dbpath = testpath/"test.sqlite"
    sqlpath = testpath/"test.sql"
    sqlpath.write "create table test (name text);"
    system "/usr/bin/sqlite3 #{dbpath} < #{sqlpath}"
    assert_equal "test: 0 changes, 0 inserts, 0 deletes, 0 unchanged",
                 shell_output("#{bin}/sqldiff --summary #{dbpath} #{dbpath}").strip
  end
end
