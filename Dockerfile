FROM ubuntu:22.04 as base

ENV DEBIAN_FRONTEND=noninteractive

FROM base as build

RUN apt-get update && \
    apt-get install -y \
        git clang cmake make gcc g++ libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev p7zip
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

COPY . /src
WORKDIR /src/bin

RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/opt/tc
RUN make -j 4 -k && make install

FROM base as publish

RUN apt-get update && \
    apt-get install -y mysql-client libmysqlclient21 libboost-filesystem1.74.0 libreadline8 libboost-system1.74.0 libboost-program-options1.74.0 libboost-iostreams1.74.0 libboost-regex1.74.0 libboost-locale1.74.0 libboost-chrono1.74.0 libboost-atomic1.74.0

WORKDIR /opt/tc

# Copy to /usr/local/bin/ so that we run executables directly
COPY --from=build /opt/tc/bin /usr/local/bin/
# Copy to the same as the build env so we do not need to configure it in worldserver.conf
COPY --from=build /opt/tc/etc /opt/tc/etc/
COPY --from=build /src/sql /src/sql/
