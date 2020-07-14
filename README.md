# Snapcast Server
docker image para [snapcast server](https://github.com/badaix/snapcast).

Pense este docker para que incluye el snap cast server + mopidy + librespot ("spotify")

# Agregados

* snapweb
* Mopidy
* Mopidy-Iris
* Mopidy-MusicBox-Webclient
* Mopidy-RadioNet
* Mopidy-PiDi
* mopidy-mpd
* mopidy-tunein
* librespot (spotify)
* gstreamer1.0-omx
* gstreamer1.0-plugins-bad
* gstreamer1.0-plugins-base
* gstreamer1.0-plugins-good
* gstreamer1.0-plugins-rtp
* gstreamer1.0-plugins-ugly
* gstreamer1.0-pulseaudio
* gstreamer1.0-tools
* gstreamer1.0-libav
* ffmpeg
* gstreamer1.0-libav 

## Compilar Docker 
Se testeo la compilacion en amd64 y armv7. 

docker buildx build --progress=plain --platform=linux/amd64,linux/arm/v7 -t matiasgonzalocalvo/snapcastserver:latest --push .

## Run Snapclient
Este docker se probo en ubuntu 20.04 y en una raspberry:

* `-v volumen/conf:/app/conf` volumen donde va a estar la configuracion de snapcast server yo tambien dejo la configuracion de mopidy
* `--net host` para que funcione correctamente 
* `-p puerto` puertos que utilizan el snapcast 1704 - 1705 - 1780 y el puertos de mopidy 6680 6600 se puede reemplazar por -net host

``` /bin/bash
docker run -t -d --restart always --name snapcast-server  -p 1705:1705 -p 1704:1704 -p 1780:1780 -p 6680:6680 -p 6600:6600 -v /cloud/snapcast-server/conf/:/app/conf/ matiasgonzalocalvo/snapcastserver:latest
```

#tips 

Yo levanto el mopidy con el snapcast dejo en la carpeta /conf la config que uso. 
si se desea levantar aparte hay que reescribir el cmd ej:

docker run -t -d --restart always --name snapcast-server  -p 1705:1705 -p 1704:1704 -p 1780:1780 -p 6680:6680 -p 6600:6600 -v /cloud/snapcast-server/conf/:/app/conf/ matiasgonzalocalvo/snapcastserver:latest bash -c '/etc/init.d/mopidy start  && snapcastserver'

el snapweb esta en la carpeta /app/snapweb/page  si se desea modificar se puede montar un volumen con los archivos staticos que se quiera

## Snapcast Updates
Para cambiar la version del Snap Cast Server hay que pasar en el buil el argumento de la version. dejo abajo el ejemplo 

docker buildx build --build-arg Version=0.20.0 --progress=plain --platform=linux/amd64,linux/arm/v7 -t matiasgonzalocalvo/snapcastserver:latest --push .
