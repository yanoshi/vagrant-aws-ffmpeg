# load .env
Dotenv.load

Vagrant.configure(2) do |config|
  config.vm.box     = 'dummy'
  config.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "ffmpeg_vm" do |config|
    config.vm.provider :aws do |provider, override|
      provider.region        = ENV['EC2_REGION']
      provider.instance_type = ENV['EC2_INSTANCE_TYPE']
      provider.ami           = ENV['EC2_AMI']
      override.ssh.username  = ENV['EC2_USERNAME']
      # provider.security_groups = "sg-xxxxxxx"

      provider.access_key_id        = ENV['EC2_ACCESS_KEY_ID']
      provider.secret_access_key    = ENV['EC2_SECRET_ACCESS_KEY']
      provider.keypair_name         = ENV['EC2_KEYPAIR']
      override.ssh.private_key_path = ENV['SSH_KEY_PATH']

      override.nfs.functional = false
      override.vm.synced_folder "./sync_folder", "/sync_folder", type: "rsync"

      #if ARGV[0] == "up" || ARGV[0] == "provision" then
      if ARGV[0] == "up" then
        override.vm.provision :shell do |shell|
          shell.inline = <<-SHELL
            export FREE_FLAG=TRUE

            yum -y install \
                centos-release-scl \
                epel-release \
            && yum-config-manager --enable rhel-server-rhscl-7-rpms \
            && yum -y install \
                autoconf \
                automake \
                bzip2 \
                cmake \
                freetype-devel \
                gcc \
                gcc-c++ \
                git \
                libtool \
                make \
                mercurial \
                pkgconfig \
                zlib-devel \
                unzip \
                wget \
                libcurl \
                openssl
            # install nasm
            wget -P /tmp/ https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 \
            && cd /tmp/ \
            && mkdir ffmpeg_sources \
            && mkdir ffmpeg_build \
            && cd /tmp/ffmpeg_sources \
            && tar xvf /tmp/nasm-2.13.03.tar.bz2 \
            && cd nasm-2.13.03 \
            && ./autogen.sh \
            && CC="/usr/bin/gcc" ./configure --prefix="/tmp/ffmpeg_build" --bindir="/usr/bin" \
            && make -j32 \
            && make install
            # install yasm
            wget -P /tmp/ http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz \
            && cd /tmp/ffmpeg_sources \
            && tar xvf /tmp/yasm-1.3.0.tar.gz \
            && cd yasm-1.3.0 \
            && ./configure --prefix="/tmp/ffmpeg_build" --bindir="/usr/bin" \
            && make -j32 \
            && make install
            # # install gcc6
            # yum install -y devtoolset-6-gcc devtoolset-6-gcc-c++ \
            # && scl enable devtoolset-6 bash
            # install l-smash
            cd /tmp/ffmpeg_sources \
            && git clone https://github.com/l-smash/l-smash.git \
            && cd l-smash \
            && PKG_CONFIG_PATH=/tmp/ffmpeg_build/lib/pkgconfig \
                ./configure --prefix="/tmp/ffmpeg_build" --bindir="/usr/bin" \
            && PKG_CONFIG_PATH=/tmp/ffmpeg_build/lib/pkgconfig \
                make -j32 \
            && PKG_CONFIG_PATH=/tmp/ffmpeg_build/lib/pkgconfig \
                make install
            # install gpac
            cd /tmp/ffmpeg_sources \
            && git clone https://github.com/gpac/gpac.git \
            && cd gpac \
            && ./configure --prefix="/tmp/ffmpeg_build" --bindir="/usr/bin" --static-mp4box --use-zlib=no \
            && make -j32 lib \
            && make install lib \
            && make -j32 \
            && make install
            # install libx264
            cd /tmp/ffmpeg_sources \
            && git clone https://code.videolan.org/videolan/x264.git -b stable \
            && cd x264 \
            && PKG_CONFIG_PATH=/tmp/ffmpeg_build/lib/pkgconfig \
                ./configure --prefix="/tmp/ffmpeg_build" --bindir="/usr/bin" --enable-static --disable-opencl \
            && wget http://media.xiph.org/video/derf/y4m/bus_cif.y4m --no-check-certificate \
            && make fprofiled VIDS="bus_cif.y4m" -j32 \
            && make install
            # install libvpx
            cd /tmp/ffmpeg_sources \
            && git clone https://chromium.googlesource.com/webm/libvpx.git \
            && cd libvpx \
            && git checkout 8ae686757b708cd8df1d10c71586aff5355cfe1e \
            && ./configure --prefix="/tmp/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm \
            && make -j32 \
            && make install
            # install fdk_aac
            if [ $FREE_FLAG ]; then
            cd /tmp/ffmpeg_sources \
            && git clone https://github.com/mstorsjo/fdk-aac.git -b v2.0.0 \
            && cd fdk-aac \
            && autoreconf -fiv \
            && ./configure --prefix="/tmp/ffmpeg_build" --disable-shared \
            && make -j32 \
            && make install
            fi
            # install cmake3.9
            cd /tmp/ \
            && wget https://cmake.org/files/v3.9/cmake-3.9.1.tar.gz \
            && tar xvfz cmake-3.9.1.tar.gz \
            && cd cmake-3.9.1 \
            && ./bootstrap \
            && make -j32 \
            && make install
            # install libaom
            cd /tmp/ffmpeg_sources \
            && git clone https://aomedia.googlesource.com/aom \
            && mkdir aom_build \
            && cd aom_build \
            && PKG_CONFIG_PATH="/tmp/ffmpeg_build/lib/pkgconfig:$PKG_CONFIG_PATH" \
                /usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/tmp/ffmpeg_build" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom \
            && make -j32 \
            && make install
            # install libx265
            cd /tmp/ffmpeg_sources \
            && hg clone https://bitbucket.org/multicoreware/x265 \
            && cd x265/build/linux \
            && /usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/tmp/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source \
            && make -j32 \
            && make install
            # install libmp3lame
            cd /tmp/ffmpeg_sources \
            && wget -P /tmp/ https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz \
            && tar xzvf /tmp/lame-3.100.tar.gz \
            && cd lame-3.100 \
            && ./configure --prefix="/tmp/ffmpeg_build" --bindir="/usr/local/bin" --disable-shared --enable-nasm \
            && make -j32 \
            && make install
            # install libopus
            cd /tmp/ffmpeg_sources \
            && wget -P /tmp/ https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz \
            && tar xzvf /tmp/opus-1.3.1.tar.gz \
            && cd opus-1.3.1 \
            && ./configure --prefix="/tmp/ffmpeg_build" --disable-shared \
            && make -j32 \
            && make install
            # install libvmaf
            cd /tmp/ffmpeg_sources \
            && wget -P /tmp/ https://github.com/Netflix/vmaf/archive/v1.3.15.zip \
            && unzip /tmp/v1.3.15.zip \
            && cd vmaf-1.3.15/ptools \
            && make -j32 \
            && cd ../wrapper \
            && make -j32 \
            && cd .. \
            && make install
            # install ffmpeg
            wget -P /tmp/ https://www.ffmpeg.org/releases/ffmpeg-4.1.tar.bz2 \
            && cd /tmp/ffmpeg_sources \
            && tar -jxvf /tmp/ffmpeg-4.1.tar.bz2 \
            && cd ffmpeg-4.1 \
            && PATH="/tmp/bin:$PATH" PKG_CONFIG_PATH="/tmp/ffmpeg_build/lib/pkgconfig:/tmp/ffmpeg_build/lib64/pkgconfig:/usr/lib64/pkgconfig:/usr/share/pkgconfig:/usr/local/lib/pkgconfig" \
                ./configure \
                  --prefix="/tmp/ffmpeg_build" \
                  --pkg-config-flags="--static" \
                  --extra-cflags="-I/tmp/ffmpeg_build/include -march=native" \
                  --optflags=-O3 \
                  --enable-static \
                  --disable-shared \
                  --disable-debug \
                  --extra-ldflags="-L/tmp/ffmpeg_build/lib" \
                  --extra-libs=-lpthread \
                  --extra-libs=-lm \
                  --bindir="/usr/bin" \
                  --enable-gpl \
                  $([ $FREE_FLAG ] && echo "--disable-nonfree" || echo "--enable-nonfree") \
                  --enable-version3 \
                  --enable-libvmaf \
                  $([ $FREE_FLAG ] && echo "--disable-libfdk_aac" || echo "--enable-libfdk_aac") \
                  --enable-libmp3lame \
                  --enable-libopus \
                  --disable-libfreetype \
                  --enable-libx264 \
                  --enable-libx265 \
                  --enable-libvpx \
                  --enable-libaom > /sync_folder/ffmpeg_configure.txt \
            && make -j32 \
            && make install
          SHELL
          shell.privileged = true
        end
      end
    end
  end
end


