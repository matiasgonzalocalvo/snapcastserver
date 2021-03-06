#Si es arm seteo la dist armhf
FROM --platform=$TARGETPLATFORM debian:latest AS debian-arm
ENV DIST_ARCH=armhf
RUN echo "(|| DIST_ARCH == $DIST_ARCH || "

#si es 64 bits setedo distamd64
FROM --platform=$TARGETPLATFORM debian:latest AS debian-amd64
ENV DIST_ARCH=amd64
RUN echo "(|| DIST_ARCH == $DIST_ARCH ||"

#si es 64 bits setedo distamd64
FROM --platform=$TARGETPLATFORM debian:latest AS debian-librespot
RUN apt update && apt install -y git build-essential libasound2-dev cargo pkg-config
RUN git clone https://github.com/librespot-org/librespot
RUN cd librespot && cargo build --release

FROM --platform=$TARGETPLATFORM debian-$TARGETARCH
ARG Version=0.20.0
ENV GitUrlSnapcast https://github.com/badaix/snapcast/releases/download/
ENV USER snapserver
ENV GROUP snapserver
ENV WORKDIR /app

RUN groupadd -r ${GROUP} && useradd --no-log-init -r -g ${GROUP} ${USER}

WORKDIR ${WORKDIR}

#INSTALL SNAPCAST
RUN mkdir -p ${WORKDIR}/conf
RUN apt update && apt install wget git libavahi-client3 libavahi-common3 libflac8 libogg0 libopus0 libvorbis0a libvorbisenc2 gnupg2 -y
RUN wget ${GitUrlSnapcast}v${Version}/snapserver_${Version}-1_${DIST_ARCH}.deb 
RUN dpkg -i snapserver_${Version}-1_${DIST_ARCH}.deb && rm -rf snapserver_${Version}-1_${DIST_ARCH}.deb 
#Clone snapweb in config snapcast set /app/snapweb/page/
RUN git clone https://github.com/badaix/snapweb.git

#INSTALL MOPIDY
RUN wget -q -O - https://apt.mopidy.com/mopidy.gpg | apt-key add -
RUN wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list 
RUN apt update
RUN apt install mopidy mopidy-mpd mopidy-tunein -y
RUN apt install python3-pip -y  
RUN python3 -m pip install Mopidy-Iris Mopidy-MusicBox-Webclient Mopidy-RadioNet Mopidy-PiDi

#Install librespot for spotify
#RUN apt install -y build-essential libasound2-dev cargo pkg-config
#RUN git clone https://github.com/librespot-org/librespot
#RUN cd librespot && cargo build --release
#RUN mkdir bin ; cp librespot/target/release/librespot  bin/ ; rm -rf librespot
COPY --from=debian-librespot librespot/target/release/librespot bin/

#RUN apt install avahi-utils -y procps

#install gstreamer
RUN apt install gstreamer1.0-omx gstreamer1.0-plugins-bad  gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-rtp gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio  gstreamer1.0-tools gstreamer1.0-libav ffmpeg gstreamer1.0-libav -y

EXPOSE 1705 1704 1780 6680

#ENTRYPOINT 
CMD ["sh","-c","/usr/bin/snapserver -c /app/conf/snapserver.conf"]
