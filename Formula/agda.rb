require "language/haskell"

class Agda < Formula
  include Language::Haskell::Cabal

  desc "Dependently typed functional programming language"
  homepage "http://wiki.portal.chalmers.se/agda/"
  revision 3

  stable do
    url "https://hackage.haskell.org/package/Agda-2.5.3/Agda-2.5.3.tar.gz"
    sha256 "aa14d4a3582013100f71e64d71c5deff6caa2a286083e20fc16f6dbb0fdf0065"

    resource "stdlib" do
      url "https://github.com/agda/agda-stdlib.git",
          :revision => "c06437e4ebb5365d502fb0a79775e5c591ab8ae5" # v0.15
    end
  end

  bottle do
    sha256 "6506de625f9f04509c0e36b2b5659764c511d96a6c321f3f49d5034f09630ba4" => :high_sierra
    sha256 "6f901334a92e1f22593bb9bf058f981b71359153bb922017364626e7d7f0ce5a" => :sierra
    sha256 "dfb13015d80bee654406a639a907f004c422aa87c102fc6db2cddf48c460615f" => :el_capitan
  end

  head do
    url "https://github.com/agda/agda.git"

    resource "stdlib" do
      url "https://github.com/agda/agda-stdlib.git"
    end
  end

  deprecated_option "without-ghc" => "without-ghc@8.2"
  deprecated_option "without-malonzo" => "without-ghc@8.2"

  option "without-stdlib", "Don't install the Agda standard library"
  option "without-ghc@8.2", "Disable the GHC backend"

  depends_on "ghc@8.2" => :recommended
  if build.with? "ghc@8.2"
    depends_on "cabal-install" => [:build, :test]
  else
    depends_on "cabal-install" => :build
    depends_on "ghc@8.2" => :build
  end

  depends_on "emacs" => :recommended

  def install
    # install Agda core
    install_cabal_package :using => ["alex", "happy", "cpphs"]

    if build.with? "stdlib"
      resource("stdlib").stage lib/"agda"

      # generate the standard library's bytecode
      cd lib/"agda" do
        cabal_sandbox :home => buildpath, :keep_lib => true do
          cabal_install "--only-dependencies"
          cabal_install
          system "GenerateEverything"
        end
      end

      # generate the standard library's documentation and vim highlighting files
      cd lib/"agda" do
        system bin/"agda", "-i", ".", "-i", "src", "--html", "--vim", "README.agda"
      end
    end

    # compile the included Emacs mode
    if build.with? "emacs"
      system bin/"agda-mode", "compile"
      elisp.install_symlink Dir["#{share}/*/Agda-#{version}/emacs-mode/*"]
    end
  end

  def caveats
    s = ""

    if build.with? "stdlib"
      s += <<~EOS
        To use the Agda standard library by default:
          mkdir -p ~/.agda
          echo #{HOMEBREW_PREFIX}/lib/agda/standard-library.agda-lib >>~/.agda/libraries
          echo standard-library >>~/.agda/defaults
      EOS
    end

    s
  end

  test do
    simpletest = testpath/"SimpleTest.agda"
    simpletest.write <<~EOS
      module SimpleTest where

      data ℕ : Set where
        zero : ℕ
        suc  : ℕ → ℕ

      infixl 6 _+_
      _+_ : ℕ → ℕ → ℕ
      zero  + n = n
      suc m + n = suc (m + n)

      infix 4 _≡_
      data _≡_ {A : Set} (x : A) : A → Set where
        refl : x ≡ x

      cong : ∀ {A B : Set} (f : A → B) {x y} → x ≡ y → f x ≡ f y
      cong f refl = refl

      +-assoc : ∀ m n o → (m + n) + o ≡ m + (n + o)
      +-assoc zero    _ _ = refl
      +-assoc (suc m) n o = cong suc (+-assoc m n o)
    EOS

    stdlibtest = testpath/"StdlibTest.agda"
    stdlibtest.write <<~EOS
      module StdlibTest where

      open import Data.Nat
      open import Relation.Binary.PropositionalEquality

      +-assoc : ∀ m n o → (m + n) + o ≡ m + (n + o)
      +-assoc zero    _ _ = refl
      +-assoc (suc m) n o = cong suc (+-assoc m n o)
    EOS

    iotest = testpath/"IOTest.agda"
    iotest.write <<~EOS
      module IOTest where

      open import Agda.Builtin.IO
      open import Agda.Builtin.Unit

      postulate
        return : ∀ {A : Set} → A → IO A

      {-# COMPILED return (\\_ -> return) #-}

      main : _
      main = return tt
    EOS

    stdlibiotest = testpath/"StdlibIOTest.agda"
    stdlibiotest.write <<~EOS
      module StdlibIOTest where

      open import IO

      main : _
      main = run (putStr "Hello, world!")
    EOS

    # typecheck a simple module
    system bin/"agda", simpletest

    # typecheck a module that uses the standard library
    if build.with? "stdlib"
      system bin/"agda", "-i", lib/"agda"/"src", stdlibtest
    end

    # compile a simple module using the JS backend
    system bin/"agda", "--js", simpletest

    # test the GHC backend
    if build.with? "ghc@8.2"
      ENV.prepend_path "PATH", Formula["ghc@8.2"].opt_bin
      cabal_sandbox do
        cabal_install "text", "ieee754"
        dbpath = Dir["#{testpath}/.cabal-sandbox/*-packages.conf.d"].first
        dbopt = "--ghc-flag=-package-db=#{dbpath}"

        # compile and run a simple program
        system bin/"agda", "-c", dbopt, iotest
        assert_equal "", shell_output(testpath/"IOTest")

        # compile and run a program that uses the standard library
        if build.with? "stdlib"
          system bin/"agda", "-c", "-i", lib/"agda"/"src", dbopt, stdlibiotest
          assert_equal "Hello, world!", shell_output(testpath/"StdlibIOTest")
        end
      end
    end
  end
end
