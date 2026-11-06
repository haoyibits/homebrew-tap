class OpenocdStellar < Formula
  desc "OpenOCD for ST Stellar (SR6) with StellarLINK, plus SR6P6 flash and reset fixes"
  homepage "https://github.com/haoyibits/OpenOCD/tree/openocd-automotive-mcu-r3"
  url "https://github.com/haoyibits/OpenOCD/archive/refs/tags/v0.12.0-stellar.1.tar.gz"
  version "0.12.0-stellar.1"
  sha256 "490e0e514acd9f53c50781c298fb9ded6d84573ed13325b2448923a0fa439510"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/haoyibits/homebrew-tap/releases/download/openocd-stellar-0.12.0-stellar.1"
    sha256 arm64_sequoia: "55dadf1fab18f9bad47af651411dfcaddca619957eb9ccb479b2ad57f6a04c53"
    sha256 arm64_linux:   "9ec106ce45684d24b283c53652f392a0d8340bfd2075a06b91b8aa0ed16ba112"
    sha256 x86_64_linux:  "75ba62844089adf68abbaee427fb95728b0cd00fa4df48aa1253a0525b9f60f9"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "texinfo" => :build
  depends_on "capstone"
  depends_on "hidapi"
  depends_on "libftdi"
  depends_on "libusb"

  # The jimtcl submodule at the commit the fork pins (0.82). The source
  # archive has no submodules, and fetching them through git would also pull
  # libjaylink and git2cl from hosts that are often unreachable.
  resource "jimtcl" do
    url "https://github.com/msteveb/jimtcl/archive/1933e5457b9512d39ebbe11ed32578aada149f49.tar.gz"
    sha256 "09c9bd0164055508119fa4860cb7fc2d76f79c2703972cf93cbe1812ac5ca2bd"
  end

  def install
    ENV["CCACHE"] = "none"
    rm_r "jimtcl" if File.directory?("jimtcl")
    resource("jimtcl").stage(buildpath/"jimtcl")

    system "./bootstrap", "nosubmodule"
    # Installed under libexec so that it does not clash with Homebrew's
    # open-ocd (both would install bin/openocd); exposed as openocd-stellar.
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{libexec}",
                          "--enable-ftdi",
                          "--enable-dummy",
                          "--disable-werror",
                          "--disable-doxygen-html",
                          "--disable-doxygen-pdf"
    system "make", "install"
    bin.install_symlink libexec/"bin/openocd" => "openocd-stellar"
  end

  def caveats
    <<~EOS
      The command is installed as `openocd-stellar` so that it can coexist
      with Homebrew's open-ocd. Its scripts are in:
        #{opt_libexec}/share/openocd/scripts
    EOS
  end

  test do
    # Parse the SR6P6 target with the dummy adapter and stop before `init`
    # touches any hardware.
    output = shell_output("#{bin}/openocd-stellar " \
                          "-f interface/dummy.cfg -c 'transport select jtag' " \
                          "-f target/sr6p6.cfg " \
                          "-c 'echo \"targets: [target names]\"' " \
                          "-c 'echo \"flash: [flash list]\"' " \
                          "-c shutdown 2>&1")
    assert_match "sr6p6.k0c0.core", output
    assert_match(/driver\s+sr6p6\s+base\s+0x28000000/, output)
    assert_match "shutdown command invoked", output
    # The fork's fixes, not ST's original target script.
    assert_match "sr6p6_reset_halts", (libexec/"share/openocd/scripts/target/sr6p6.cfg").read
  end
end
