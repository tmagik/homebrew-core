require "language/haskell"

class Hlint < Formula
  include Language::Haskell::Cabal

  desc "Haskell source code suggestions"
  homepage "https://github.com/ndmitchell/hlint"
  url "https://hackage.haskell.org/package/hlint-2.1.1/hlint-2.1.1.tar.gz"
  sha256 "a4e547f26d1631630b7a95ccb5318448aabce0fa6185c5cb8b85a212da56ae56"
  head "https://github.com/ndmitchell/hlint.git"

  bottle do
    sha256 "72b29d663016b5284bbff95bb6a4a126e1c8c33fc341ffe5d4820067eade6137" => :high_sierra
    sha256 "b6cf27fd1273aa16265f6fff7ac61ba1c5af81af4306fb95e413117c72a03794" => :sierra
    sha256 "44372f8a2c5e5553d17cbc2d217eda358148b84df885074cbaa4cde69ff3cfa2" => :el_capitan
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build

  def install
    install_cabal_package :using => "happy"
    man1.install "data/hlint.1"
  end

  test do
    (testpath/"test.hs").write <<~EOS
      main = do putStrLn "Hello World"
    EOS
    assert_match "Redundant do", shell_output("#{bin}/hlint test.hs", 1)
  end
end
