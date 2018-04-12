class SqliteAnalyzer < Formula
  desc "Analyze how space is allocated inside an SQLite file"
  homepage "https://www.sqlite.org/"
  url "https://sqlite.org/2018/sqlite-src-3230000.zip"
  version "3.23.0"
  sha256 "22422e1d34ecc21af5d374c328c540a3a6e32d7d6cf3c57be8b51b523b98d633"

  bottle do
    cellar :any_skip_relocation
    sha256 "a011ea94fd7addbdded55b4fdbdd37a6162d07b1f1cea25cc8c73e00cc1c059a" => :high_sierra
    sha256 "ddbae05a3f83932abaad40e0b6e86dffd7553d5b2a40e0df232acf5d2e9793f1" => :sierra
    sha256 "f48cb03411cae76b72c18c9983fccb84a0eca73ce2512256c97eb112cb64fdfd" => :el_capitan
  end

  def install
    system "./configure", "--disable-debug", "--with-tcl=/System/Library/Frameworks/Tcl.framework/", "--prefix=#{prefix}"
    system "make", "sqlite3_analyzer"
    bin.install "sqlite3_analyzer"
  end

  test do
    dbpath = testpath/"school.sqlite"
    sqlpath = testpath/"school.sql"
    sqlpath.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
    EOS
    system "/usr/bin/sqlite3 #{dbpath} < #{sqlpath}"
    system bin/"sqlite3_analyzer", dbpath
  end
end
