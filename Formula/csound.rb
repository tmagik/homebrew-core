class Csound < Formula
  desc "Sound and music computing system"
  homepage "https://csound.com"
  url "https://github.com/csound/csound/archive/6.13.0.tar.gz"
  sha256 "183beeb3b720bfeab6cc8af12fbec0bf9fef2727684ac79289fd12d0dfee728b"
  revision 3
  head "https://github.com/csound/csound.git", :branch => "develop"

  bottle do
    rebuild 1
    sha256 "be17285fc4fa7d1fcf75ff43a2c998299ba6470c2075be81ff68764304b13a08" => :catalina
    sha256 "b6c050245d5983ea1671b3b9e1e2a36a37cff06f4fcccb6dd975ce512751470e" => :mojave
    sha256 "1459367a87cd664a30be991be416a57cdc01348411e936438b1b43eed8d6bb82" => :high_sierra
  end

  depends_on "asio" => :build
  depends_on "cmake" => :build
  depends_on "eigen" => :build
  depends_on "faust"
  depends_on "fltk"
  depends_on "fluid-synth"
  depends_on "hdf5"
  depends_on "jack"
  depends_on "liblo"
  depends_on "libpng"
  depends_on "libsamplerate"
  depends_on "libsndfile"
  depends_on "numpy"
  depends_on "portaudio"
  depends_on "portmidi"
  depends_on "stk"
  depends_on "wiiuse"

  conflicts_with "libextractor", :because => "both install `extract` binaries"
  conflicts_with "pkcrack", :because => "both install `extract` binaries"

  resource "ableton-link" do
    url "https://github.com/Ableton/link/archive/Link-3.0.2.tar.gz"
    sha256 "2716e916a9dd9445b2a4de1f2325da818b7f097ec7004d453c83b10205167100"
  end

  resource "getfem" do
    url "https://download.savannah.gnu.org/releases/getfem/stable/getfem-5.3.tar.gz"
    sha256 "9d10a1379fca69b769c610c0ee93f97d3dcb236d25af9ae4cadd38adf2361749"
  end

  def install
    resource("ableton-link").stage { cp_r "include/ableton", buildpath }
    resource("getfem").stage { cp_r "src/gmm", buildpath }

    args = std_cmake_args + %W[
      -DABLETON_LINK_HOME=#{buildpath}/ableton
      -DBUILD_ABLETON_LINK_OPCODES=ON
      -DBUILD_JAVA_INTERFACE=OFF
      -DBUILD_LINEAR_ALGEBRA_OPCODES=ON
      -DBUILD_LUA_INTERFACE=OFF
      -DBUILD_PYTHON_INTERFACE=OFF
      -DBUILD_WEBSOCKET_OPCODE=OFF
      -DCMAKE_INSTALL_RPATH=#{frameworks}
      -DCS_FRAMEWORK_DEST=#{frameworks}
      -DGMM_INCLUDE_DIR=#{buildpath}/gmm
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

    include.install_symlink frameworks/"CsoundLib64.framework/Headers" => "csound"

    libexec.install buildpath/"interfaces/ctcsound.py"

    python_version = Language::Python.major_minor_version "python3"
    (lib/"python#{python_version}/site-packages/homebrew-csound.pth").write <<~EOS
      import site; site.addsitedir('#{libexec}')
    EOS
  end

  def caveats; <<~EOS
    To use the Python bindings, you may need to add to #{shell_profile}:
      export DYLD_FRAMEWORK_PATH="$DYLD_FRAMEWORK_PATH:#{opt_frameworks}"
  EOS
  end

  test do
    (testpath/"test.orc").write <<~EOS
      0dbfs = 1
      gi_peer link_create
      gi_programHandle faustcompile "process = _;", "--vectorize --loop-variant 1"
      FLrun
      gi_fluidEngineNumber fluidEngine
      gi_image imagecreate 1, 1
      gi_realVector la_i_vr_create 1
      pyinit
      pyruni "print('hello, world')"
      instr 1
          a_, a_, a_ chuap 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          a_signal STKPlucked 440, 1
          hdf5write "test.h5", a_signal
          out a_signal
      endin
    EOS

    (testpath/"test.sco").write <<~EOS
      i 1 0 1
      e
    EOS

    ENV["OPCODE6DIR64"] = frameworks/"CsoundLib64.framework/Resources/Opcodes64"
    ENV["RAWWAVE_PATH"] = Formula["stk"].pkgshare/"rawwaves"

    require "open3"
    stdout, stderr, status = Open3.capture3("#{bin}/csound test.orc test.sco")

    assert status.success?
    assert_equal "hello, world\n", stdout
    assert_match /^rtaudio:/, stderr
    assert_match /^rtmidi:/, stderr

    assert_predicate testpath/"test.aif", :exist?
    assert_predicate testpath/"test.h5", :exist?

    (testpath/"jacko.orc").write "JackoInfo"
    system bin/"csound", "--orc", "--syntax-check-only", "jacko.orc"

    (testpath/"wii.orc").write <<~EOS
      instr 1
          i_success wiiconnect 1, 1
      endin
    EOS
    system bin/"csound", "wii.orc", "test.sco"

    ENV["DYLD_FRAMEWORK_PATH"] = frameworks
    system "python3", "-c", "import ctcsound"
  end
end
