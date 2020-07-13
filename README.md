# snapcastserver

# Build arm raspbian raspberry 4
docker build --build-arg ARCH=arm32v7 --build-arg DIST_ARCH=armhf -t matiasgonzalocalvo/snapcastserver:arm32v7 .
