FROM arm32v7/debian:latest

ENV GitUrlSnapcast https://github.com/badaix/snapcast/releases/download/
ENV Version 0.20.0
ENV USER snapserver
ENV GROUP snapserver
ENV WORKDIR /app

RUN groupadd -r ${GROUP} && useradd --no-log-init -r -g ${GROUP} ${USER}

WORKDIR ${WORKDIR}

#INSTALL SNAPCAST
RUN mkdir -p ${WORKDIR}/conf
RUN apt update && apt install wget git libavahi-client3 libavahi-common3 libflac8 libogg0 libopus0 libvorbis0a libvorbisenc2 gnupg2 -y
RUN wget ${GitUrlSnapcast}v${Version}/snapserver_${Version}-1_armhf.deb 
RUN dpkg -i snapserver_${Version}-1_armhf.deb && rm -rf snapserver_${Version}-1_armhf.deb 
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
RUN apt install -y build-essential libasound2-dev cargo pkg-config
RUN git clone https://github.com/librespot-org/librespot
RUN cd librespot && cargo build --release
RUN mkdir bin ; cp librespot/target/release/librespot  bin/ 
#RUN apt install avahi-utils -y procps

EXPOSE 1705 1704 1780 6680

#ENTRYPOINT 
CMD ["sh","-c","/usr/bin/snapserver -c /app/conf/snapserver.conf"]
