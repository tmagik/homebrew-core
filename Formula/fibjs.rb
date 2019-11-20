class Fibjs < Formula
  desc "JavaScript on Fiber"
  homepage "https://fibjs.org/"
  url "https://github.com/fibjs/fibjs/releases/download/v0.29.0/fullsrc.zip"
  sha256 "4e858fcfaf0e62bd06a7dfb8090c2bfabc9f5b7307d32908b33e0b93cae8052f"
  head "https://github.com/fibjs/fibjs.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "f733b3255e882d70e948c855e32105c639e64daa52778568e8e85bb0aabc31f8" => :mojave
    sha256 "ea138f4c4158377036469a8e783d0baeaf28cf8c960baacfc017e5455d9a27b6" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on :macos => :sierra # fibjs requires >= Xcode 8.3 (or equivalent CLT)

  def install
    # the build script breaks when CI is set by Homebrew
    begin
      env_ci = ENV.delete "CI"
      system "./build", "release", "-j#{ENV.make_jobs}"
    ensure
      ENV["CI"] = env_ci
    end

    bin.install "bin/Darwin_amd64_release/fibjs"
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/fibjs #{path}").strip
    assert_equal "hello", output
  end
end
