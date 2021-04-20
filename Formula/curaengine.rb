class Curaengine < Formula
  desc "C++ 3D printing GCode generator"
  homepage "https://github.com/Ultimaker/CuraEngine"
  url "https://github.com/Ultimaker/CuraEngine/archive/4.9.0.tar.gz"
  sha256 "202edbdd3c376765009dc9b8883ab0480d9c501c7ce7c9cfc2c383969ea908c2"
  license "AGPL-3.0-or-later"
  version_scheme 1
  head "https://github.com/Ultimaker/CuraEngine.git"

  # Releases like xx.xx or xx.xx.x are older than releases like x.x.x, so we
  # work around this less-than-ideal situation by restricting the major version
  # to one digit. This won't pick up versions where the major version is 10+
  # but thankfully that hasn't been true yet. This should be handled in a better
  # way in the future, to avoid the possibility of missing good versions.
  livecheck do
    url :stable
    regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "b15d57215d219b206a17d7f381ca367df0653758f7c1cba901b09612265971bc"
    sha256 cellar: :any_skip_relocation, big_sur:       "ea4ddbed801958a3b9298b30a27fe638906bb7c04e78d5e0d7035872c0d1c680"
    sha256 cellar: :any_skip_relocation, catalina:      "6d732ea2dfbe75f23ada46f804a627b425bb5b091aca784f5139f63746a7ba56"
    sha256 cellar: :any_skip_relocation, mojave:        "7c98a1ae8a3d08afe1fdf6eb7baa1ed273dc7b04edc8c01bb4a91d1147ac6810"
  end

  depends_on "cmake" => :build

  # The version tag in these resources (e.g., `/1.2.3/`) should be changed as
  # part of updating this formula to a new version.
  resource "fdmextruder_defaults" do
    url "https://raw.githubusercontent.com/Ultimaker/Cura/4.9.0/resources/definitions/fdmextruder.def.json"
    sha256 "d9b38fdf02d1dcdc6ee7401118ca9468236adb860786361e453f1eeb54c95b1f"
  end

  resource "fdmprinter_defaults" do
    url "https://raw.githubusercontent.com/Ultimaker/Cura/4.9.0/resources/definitions/fdmprinter.def.json"
    sha256 "bc4ed29f1c4191ccf6fa76b0a2857aca7ab6ed2a5f526364f52910f330dfa6a6"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args,
                            "-DCMAKE_INSTALL_PREFIX=#{libexec}",
                            "-DENABLE_ARCUS=OFF"
      system "make", "install"
    end
    bin.install "build/CuraEngine"
  end

  test do
    testpath.install resource("fdmextruder_defaults")
    testpath.install resource("fdmprinter_defaults")
    (testpath/"t.stl").write <<~EOS
      solid t
        facet normal 0 -1 0
         outer loop
          vertex 0.83404 0 0.694596
          vertex 0.36904 0 1.5
          vertex 1.78814e-006 0 0.75
         endloop
        endfacet
      endsolid Star
    EOS

    system "#{bin}/CuraEngine", "slice", "-j", "fdmprinter.def.json", "-l", "#{testpath}/t.stl"
  end
end
