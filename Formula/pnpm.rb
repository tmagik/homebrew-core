class Pnpm < Formula
  require "language/node"

  desc "📦🚀 Fast, disk space efficient package manager"
  homepage "https://pnpm.js.org"
  url "https://registry.npmjs.org/pnpm/-/pnpm-4.3.0.tgz"
  sha256 "f89ae7701113347434d6f764201c648b38a4cf3514f69751a8fdf38faae6c2c1"

  bottle do
    cellar :any_skip_relocation
    sha256 "c4ae108b38376b4d515adb57294be620f43b0a4216420db216ef5ff1c8e89de2" => :catalina
    sha256 "47dfae6a93827590c9efbcc39c76880922f9cb7b3fdf90067c33ad169c92cd16" => :mojave
    sha256 "6c12622ce0052c58eac097f509f31a5bd40c1d1f6a23650b976fa4d043b8e3c8" => :high_sierra
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/pnpm", "init", "-y"
    assert_predicate testpath/"package.json", :exist?, "package.json must exist"
  end
end
