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

#########################################
# Label the instance and set maintainer #
#########################################
LABEL com.github.actions.name="clang-format container" \
    com.github.actions.description="Lint your code base with clang-format" \
    com.github.actions.icon="code" \
    com.github.actions.color="red" \
    maintainer="Admiralawkbar <dank.memes@github.com>" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$BUILD_REVISION \
    org.opencontainers.image.version=$BUILD_VERSION \
    org.opencontainers.image.authors="Admiralawkbar <dank.memes@github.com>" \
    org.opencontainers.image.url="https://github.com/awkbar-devops/clang-format" \
    org.opencontainers.image.source="https://github.com/ukaspersonal/clang-format" \
    org.opencontainers.image.documentation="https://github.com/ukaspersonal/clang-formatr" \
    org.opencontainers.image.vendor="AdmiralAwkbar" \
    org.opencontainers.image.description="Lint your code base with clang-format"

######################
# Set the entrypoint #
######################
ENTRYPOINT ["clang-format"]
CMD ["--help"]
