# Use the specified Elixir, Erlang, and Debian images for the builder and runner stages
ARG ELIXIR_VERSION=1.16.2
ARG OTP_VERSION=26.2.1
ARG DEBIAN_VERSION=bullseye-20240130-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# Install build dependencies and Node.js
RUN apt-get update -y && \
  apt-get install -y build-essential git curl && \
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Prepare build directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# Set build environment
ENV MIX_ENV="prod"

# Install Elixir dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files before compiling dependencies
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy application source code and assets
COPY priv priv
COPY lib lib
COPY assets assets

# Install Node.js dependencies
RUN cd assets && npm install --production

# Compile assets
RUN mix assets.build
RUN mix assets.deploy

# Compile the Elixir application
RUN mix compile

# Copy runtime configuration and release configuration
COPY config/runtime.exs config/
COPY rel rel

# Build the release
RUN mix release

# Start a new stage for the final image
FROM ${RUNNER_IMAGE}

# Install runtime dependencies
RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set working directory and permissions
WORKDIR "/app"
RUN chown nobody /app

# Set environment variable for production
ENV MIX_ENV="prod"

# Copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/i_see_sea ./
COPY --from=builder --chown=nobody:root /app/priv ./priv
# Set the user to nobody
USER nobody

# Start the server
CMD ["/app/bin/server"]
