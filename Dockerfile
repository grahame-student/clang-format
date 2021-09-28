############################
############################
## Clang Format Container ##
############################
############################

#################
# Pull in image #
#################
FROM alpine:latest as clang-format

######################
# Build dependencies #
######################
RUN apk update \
    && apk add --no-cache \
    git \
    build-base \
    ninja \
    cmake \
    python3

#############################################################
# Pass `--build-arg LLVM_TAG=master` for latest llvm commit #
#############################################################
ARG LLVM_TAG
ENV LLVM_TAG ${LLVM_TAG:-llvmorg-12.0.1}

######################
# Download and setup #
######################
WORKDIR /build
RUN git clone --branch ${LLVM_TAG} --depth 1 https://github.com/llvm/llvm-project.git
WORKDIR /build/llvm-project
RUN mv clang llvm/tools \
    && mv libcxx llvm/projects

##############
# Build tool #
##############
WORKDIR llvm/build
RUN cmake -GNinja -DLLVM_BUILD_STATIC=ON -DLLVM_ENABLE_LIBCXX=ON .. \
    && ninja clang-format

################################################################################
# Install to clean environment #################################################
################################################################################
FROM alpine:latest as final

#########################################
# Label the instance and set maintainer #
#########################################
LABEL io.whalebrew.name 'clang-format'
LABEL io.whalebrew.config.working_dir '/workdir'

#######################
# Set the working dir #
#######################
WORKDIR /workdir

##############################
# Copy from build into final #
##############################
COPY --from=clang-format /build/llvm-project/llvm/build/bin/clang-format /usr/bin

######################
# Set the entrypoint #
######################
ENTRYPOINT ["clang-format"]
CMD ["--help"]
