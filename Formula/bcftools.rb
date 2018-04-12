class Bcftools < Formula
  desc "Tools for BCF/VCF files and variant calling from samtools"
  homepage "https://www.htslib.org/"
  url "https://github.com/samtools/bcftools/releases/download/1.8/bcftools-1.8.tar.bz2"
  sha256 "4acbfd691f137742e0be63d09f516434f0faf617a5c60f466140e0677915fced"

  bottle do
    sha256 "a351142dcda713f6fe24dcb5d685eff732b70c93be4db5bd972c4558f0805a5f" => :high_sierra
    sha256 "6ee6f7174793a748c252796b83e7d356c5328ca9570aab3242528abe7132dd8b" => :sierra
    sha256 "b7cc2a872c25a84b3a8f1fdb8243239c5a9914009fbfaf06ab677554de56194c" => :el_capitan
  end

  depends_on "gsl"
  depends_on "htslib"
  depends_on "xz"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-htslib=#{Formula["htslib"].opt_prefix}",
                          "--enable-libgsl"
    system "make", "install"
    pkgshare.install "test/query.vcf"
  end

  test do
    output = shell_output("#{bin}/bcftools stats #{pkgshare}/query.vcf")
    assert_match "number of SNPs:\t3", output
    assert_match "fixploidy", shell_output("#{bin}/bcftools plugin -l")
  end
end
