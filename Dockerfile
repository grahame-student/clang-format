############################
############################
## Clang Format Container ##
############################
############################

#################################
# Build the clang-format binary #
#################################
FROM alpine:3.14.2

######################
# Build dependencies #
######################
# hadolint ignore=DL3018
RUN apk add --no-cache \
    build-base \
    clang \
    cmake \
    git \
    ninja \
    python3

#############################################################
# Pass `--build-arg LLVM_TAG=master` for latest llvm commit #
#############################################################
ARG LLVM_TAG
ENV LLVM_TAG llvmorg-12.0.1

######################
# Download and setup #
######################
WORKDIR /tmp
RUN git clone \
    --branch ${LLVM_TAG} \
    --depth 1 \
    https://github.com/llvm/llvm-project.git

#########
# Build #
#########
WORKDIR /tmp/llvm-project/llvm/build
RUN cmake -GNinja -DCMAKE_BUILD_TYPE=MinSizeRel -DLLVM_BUILD_STATIC=ON \
    -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ .. \
    && ninja clang-format \
############################
# Copy into final location #
############################
    && mv /tmp/llvm-project/llvm/build/bin/clang-format /usr/bin

######################
# Set the entrypoint #
######################
ENTRYPOINT ["clang-format"]
CMD ["--help"]
