# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t app1771241683 .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name app1771241683 app1771241683

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_LOG_TO_STDOUT="true" \
    RAILS_SERVE_STATIC_FILES="true" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so" \
    MALLOC_CONF="background_thread:true,narenas:2,dirty_decay_ms:1000,muzzy_decay_ms:1000" \
    WEB_CONCURRENCY="1" \
    RAILS_MAX_THREADS="2"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libpq-dev libyaml-dev pkg-config unzip && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUN_INSTALL=/usr/local/bun
ENV PATH=/usr/local/bun/bin:$PATH
ARG BUN_VERSION=1.3.9
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

# Keep Bundler aligned with Gemfile.lock to avoid auto-installing a different version on each build.
ARG BUNDLER_VERSION=4.0.6
RUN gem install bundler -v "${BUNDLER_VERSION}" --no-document

# Install application gems
COPY Gemfile Gemfile.lock ./

# Railway requires a literal cache id prefix (s/<service-id>/...) for cache mounts.
RUN --mount=type=cache,id=s/0f3b7bdf-3267-4efc-a8ce-57492829ef18/usr/local/bundle/cache,target=/usr/local/bundle/cache \
    bundle _${BUNDLER_VERSION}_ install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

# Install node modules
COPY package.json bun.lock* ./
RUN --mount=type=cache,id=s/0f3b7bdf-3267-4efc-a8ce-57492829ef18/root/bun/install/cache,target=/root/.bun/install/cache \
    bun install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


RUN rm -rf node_modules


# Final stage for app image
FROM base

ARG BUILD_COMMIT_SHA=unknown
ARG BUILD_CREATED_AT=unknown
ARG BUILD_SOURCE_URL=unknown
LABEL org.opencontainers.image.revision="${BUILD_COMMIT_SHA}" \
      org.opencontainers.image.created="${BUILD_CREATED_AT}" \
      org.opencontainers.image.source="${BUILD_SOURCE_URL}"

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built artifacts: gems, application
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

# Entrypoint runs optional boot-time DB prepare when enabled.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1/up || exit 1
CMD ["./bin/thrust", "./bin/rails", "server"]
