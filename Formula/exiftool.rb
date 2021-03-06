class Exiftool < Formula
  desc "Perl lib for reading and writing EXIF metadata"
  homepage "https://www.sno.phy.queensu.ca/~phil/exiftool/index.html"
  # Ensure release is tagged production before submitting.
  # https://www.sno.phy.queensu.ca/~phil/exiftool/history.html
  url "https://www.sno.phy.queensu.ca/~phil/exiftool/Image-ExifTool-10.55.tar.gz"
  mirror "https://downloads.sourceforge.net/project/exiftool/Image-ExifTool-10.55.tar.gz"
  sha256 "029b81a43f423332c00b76b5402fd8f85dee975fad41a734b494faeda4e41f7d"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "5039ab4f2bc31d2afc9b4cd1fab9ab5d6deec2bf2d1bba0a95f4d54e747dd117" => :high_sierra
    sha256 "5039ab4f2bc31d2afc9b4cd1fab9ab5d6deec2bf2d1bba0a95f4d54e747dd117" => :sierra
    sha256 "5039ab4f2bc31d2afc9b4cd1fab9ab5d6deec2bf2d1bba0a95f4d54e747dd117" => :el_capitan
    sha256 "b14972005b8f74f4dd4f34df05dd94d753ac340b118e4d15c775d192ee44bfc9" => :x86_64_linux
  end

  devel do
    url "https://sno.phy.queensu.ca/~phil/exiftool/Image-ExifTool-10.71.tar.gz"
    mirror "https://downloads.sourceforge.net/project/exiftool/Image-ExifTool-10.71.tar.gz"
    sha256 "5a0122b4b8282fe39456754e88cfb7baed1bef92a742b1e573218cf1dcbbbef4"
  end

  def install
    # replace the hard-coded path to the lib directory
    inreplace "exiftool", "$exeDir/lib", libexec/"lib"

    system "perl", "Makefile.PL"
    system "make", "all"
    libexec.install "lib"
    bin.install "exiftool"
    doc.install Dir["html/*"]
    man1.install "blib/man1/exiftool.1#{OS.mac? ? "" : "p"}"
    man3.install Dir["blib/man3/*"]
  end

  test do
    test_image = test_fixtures("test.jpg")
    assert_match %r{MIME Type\s+: image/jpeg},
                 shell_output("#{bin}/exiftool #{test_image}")
  end
end
