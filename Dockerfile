FROM rocker/shiny:4.3.2

# System dependencies
RUN apt-get update && apt-get install -y \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libglpk-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    pandoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install renv and restore packages
RUN R -e "install.packages('renv')"

# Copy Shiny app and renv files
COPY app /srv/shiny-server/
COPY renv.lock /srv/shiny-server/renv.lock
COPY renv /srv/shiny-server/renv

WORKDIR /srv/shiny-server
RUN R -e "renv::restore(confirm = FALSE)"

# Permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Port and entry
ENV SHINY_PORT=3838
ENV SHINY_HOST=0.0.0.0
EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
