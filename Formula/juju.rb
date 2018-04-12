class Juju < Formula
  desc "DevOps management tool"
  homepage "https://jujucharms.com/"
  url "https://launchpad.net/juju/2.3/2.3.5/+download/juju-core_2.3.5.tar.gz"
  sha256 "2cda0d4487359497dc29c7eab3cd4241499c8b4ac152c22a09c14b4aab766496"

  bottle do
    cellar :any_skip_relocation
    sha256 "abc01bb1fb4bfb7bf9bd7f40d2f2e7136a21eff58f56cf30550173dc8bdd8461" => :high_sierra
    sha256 "5a615e1a619155253f191da2559771329339c11ed7ccff75789ab27ecdb68223" => :sierra
    sha256 "92509f749c7494fce6480253f881255e46b4d302a9f5045d1f2b3a4e9e649593" => :el_capitan
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    system "go", "build", "github.com/juju/juju/cmd/juju"
    system "go", "build", "github.com/juju/juju/cmd/plugins/juju-metadata"
    bin.install "juju", "juju-metadata"
    bash_completion.install "src/github.com/juju/juju/etc/bash_completion.d/juju"
  end

  test do
    system "#{bin}/juju", "version"
  end
end
