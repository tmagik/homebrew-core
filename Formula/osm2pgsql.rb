class Osm2pgsql < Formula
  desc "OpenStreetMap data to PostgreSQL converter"
  homepage "https://wiki.openstreetmap.org/wiki/Osm2pgsql"
  url "https://github.com/openstreetmap/osm2pgsql/archive/0.94.0.tar.gz"
  sha256 "9e67e400deca48185313921431884171fb087dfe9e0d21e31857b8b06f20d317"
  revision 3
  head "https://github.com/openstreetmap/osm2pgsql.git"

  bottle do
    sha256 "dababba7dd44aa9f5b8a1923d630b315a6cb402f6418f862e15947f867ddd4e0" => :high_sierra
    sha256 "e7fc703fb3e82faa4bc7e83b1d12212682b73a36e88798521c87838ea16158f2" => :sierra
    sha256 "d53e0a4b7a734f5ed2b74038371ab621f51ad60c4ced6d96a49e027be0acf569" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "postgresql"
  depends_on "boost"
  depends_on "geos"
  depends_on "proj"
  depends_on "lua" => :recommended

  def install
    args = std_cmake_args

    if build.with? "lua"
      # This is essentially a CMake disrespects superenv problem
      # rather than an upstream issue to handle.
      lua_version = Formula["lua"].version.to_s.match(/\d\.\d/)
      inreplace "cmake/FindLua.cmake", "LUA_VERSIONS5 5.3 5.2 5.1 5.0",
                                       "LUA_VERSIONS5 #{lua_version}"
    else
      args << "-DWITH_LUA=OFF"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/osm2pgsql -h 2>&1")
  end
end
