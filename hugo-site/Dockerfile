#####################################################################
# Build Stage
#####################################################################
FROM hugomods/hugo:exts as builder

# Set base URL
ARG HUGO_BASEURL=http://54.166.155.11/apps/
ENV HUGO_BASEURL=${HUGO_BASEURL}

# Copy source files
COPY . /src

# Build the site
RUN hugo --minify

#####################################################################
# Final Stage
#####################################################################
FROM hugomods/hugo:nginx

# Copy generated static files
COPY --from=builder /src/public /site