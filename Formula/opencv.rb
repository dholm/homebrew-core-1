class Opencv < Formula
  desc "Open source computer vision library"
  homepage "https://opencv.org/"
  url "https://github.com/opencv/opencv/archive/3.4.0.tar.gz"
  sha256 "678cc3d2d1b3464b512b084a8cca1fad7de207c7abdf2caa1fed636c13e916da"

  bottle do
    sha256 "406457b42a06b3919fe2f927a1a9f667cbab751603f0b94b5044ff0618066994" => :high_sierra
    sha256 "1bed0e6ccedeb6838c56005e08edbd0b19ba9d2b4093099b4ce0bfd7af4eaa0c" => :sierra
    sha256 "553ecd5a4d3d7cb4ae4620b9640c0d42574b9a0132154a5a313b4ac084292b48" => :el_capitan
    sha256 "2b693a5c8d5b9df40e85ad97a0e0e37365e22ba450ea4145e3c344edf7847db1" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "eigen"
  depends_on "ffmpeg"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openexr"
  depends_on :python
  depends_on "python3"
  depends_on "numpy"
  depends_on "tbb"
  depends_on "openblas" unless OS.mac?

  needs :cxx11

  resource "contrib" do
    url "https://github.com/opencv/opencv_contrib/archive/3.4.0.tar.gz"
    sha256 "699ab3eee7922fbd3e8f98c68e6d16a1d453b20ef364e76172e56466dc9c16cd"
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    ENV.cxx11
    dylib = OS.mac? ? "dylib" : "so"

    resource("contrib").stage buildpath/"opencv_contrib"

    # Reset PYTHONPATH, workaround for https://github.com/Homebrew/homebrew-science/pull/4885
    ENV.delete("PYTHONPATH")

    py_prefix = `python-config --prefix`.chomp
    py_lib = "#{py_prefix}/lib"

    py3_config = `python3-config --configdir`.chomp
    py3_include = `python3 -c "import distutils.sysconfig as s; print(s.get_python_inc())"`.chomp
    py3_version = Language::Python.major_minor_version "python3"

    args = std_cmake_args + %W[
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DBUILD_JASPER=OFF
      -DBUILD_JPEG=ON
      -DBUILD_OPENEXR=OFF
      -DBUILD_PERF_TESTS=OFF
      -DBUILD_PNG=OFF
      -DBUILD_TESTS=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_ZLIB=OFF
      -DBUILD_opencv_java=OFF
      -DOPENCV_ENABLE_NONFREE=ON
      -DOPENCV_EXTRA_MODULES_PATH=#{buildpath}/opencv_contrib/modules
      -DWITH_1394=OFF
      -DWITH_CUDA=OFF
      -DWITH_EIGEN=ON
      -DWITH_FFMPEG=ON
      -DWITH_GPHOTO2=OFF
      -DWITH_GSTREAMER=OFF
      -DWITH_JASPER=OFF
      -DWITH_OPENEXR=ON
      -DWITH_OPENGL=OFF
      -DWITH_QT=OFF
      -DWITH_TBB=ON
      -DWITH_VTK=OFF
      -DBUILD_opencv_python2=ON
      -DBUILD_opencv_python3=ON
      -DPYTHON2_EXECUTABLE=#{which "python"}
      -DPYTHON2_LIBRARY=#{py_lib}/libpython2.7.#{dylib}
      -DPYTHON2_INCLUDE_DIR=#{py_prefix}/include/python2.7
      -DPYTHON3_EXECUTABLE=#{which "python3"}
      -DPYTHON3_LIBRARY=#{py3_config}/libpython#{py3_version}.#{dylib}
      -DPYTHON3_INCLUDE_DIR=#{py3_include}
    ]

    if build.bottle?
      args += %w[-DENABLE_SSE41=OFF -DENABLE_SSE42=OFF -DENABLE_AVX=OFF
                 -DENABLE_AVX2=OFF]
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <opencv/cv.h>
      #include <iostream>
      int main() {
        std::cout << CV_VERSION << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-o", "test"
    assert_equal `./test`.strip, version.to_s

    ["python", "python3"].each do |python|
      output = shell_output("#{python} -c 'import cv2; print(cv2.__version__)'")
      assert_equal version.to_s, output.chomp
    end
  end
end
