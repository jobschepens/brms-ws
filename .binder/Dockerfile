FROM ghcr.io/jobschepens/brms-ws/brms-workshop:working

# Switch to root for setup
USER root

# Binder requirement 1: Install Jupyter notebook and JupyterLab
RUN apt-get update && apt-get install -y python3-pip && \
    python3 -m pip install --no-cache-dir notebook jupyterlab jupyterhub && \
    rm -rf /var/lib/apt/lists/*

# Binder requirement 3: Set user with uid 1000 (already exists in base image as rstudio)
ARG NB_USER=rstudio
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

# Copy R configuration is already in place (rstudio user has everything)
# No need to copy from rstudio to jovyan since we're using rstudio user

# Ensure R libraries are accessible to all users
RUN chmod -R a+rX /usr/local/lib/R/site-library 2>/dev/null || true

# Binder requirement 4: Copy repo contents to $HOME and set ownership
COPY --chown=${NB_UID}:users . ${HOME}
RUN chown -R ${NB_UID}:users ${HOME}

# Switch to notebook user
USER ${NB_USER}
WORKDIR ${HOME}

# Binder requirement 5: Accept command-line arguments (default CMD allows this)
