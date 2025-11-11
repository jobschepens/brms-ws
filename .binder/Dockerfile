FROM ghcr.io/jobschepens/brms-ws/brms-workshop:working

# Switch to root for setup
USER root

# Binder requirement 1: Install Jupyter notebook and JupyterLab
RUN apt-get update && apt-get install -y python3-pip && \
    python3 -m pip install --no-cache-dir notebook jupyterlab jupyterhub && \
    rm -rf /var/lib/apt/lists/*

# Binder requirement 3: Create user with uid 1000
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Copy R configuration and cmdstan from rstudio to jovyan user
RUN mkdir -p ${HOME} && \
    if [ -d /home/rstudio/.Rprofile ]; then cp /home/rstudio/.Rprofile ${HOME}/; fi && \
    if [ -d /home/rstudio/.cmdstanr ]; then cp -r /home/rstudio/.cmdstanr ${HOME}/; fi && \
    if [ -d /home/rstudio/workshop ]; then cp -r /home/rstudio/workshop/* ${HOME}/; fi

# Ensure R libraries are accessible to all users
RUN chmod -R a+rX /usr/local/lib/R/site-library 2>/dev/null || true

# Binder requirement 4: Copy repo contents to $HOME and set ownership
COPY --chown=${NB_UID}:users . ${HOME}
RUN chown -R ${NB_UID}:users ${HOME}

# Switch to notebook user
USER ${NB_USER}
WORKDIR ${HOME}

# Binder requirement 5: Accept command-line arguments (default CMD allows this)
