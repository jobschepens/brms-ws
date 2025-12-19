# BRMS Workshop Docker Image

[![GitHub Actions Build](https://github.com/jobschepens/brms-ws/actions/workflows/docker-build.yml/badge.svg)](https://github.com/jobschepens/brms-ws/actions/workflows/docker-build.yml)
[![Docker Hub Size](https://img.shields.io/docker/image-size/jobschepens/brms-workshop/working)](https://hub.docker.com/r/jobschepens/brms-workshop)
[![Docker Hub Pulls](https://img.shields.io/docker/pulls/jobschepens/brms-workshop)](https://hub.docker.com/r/jobschepens/brms-workshop)

This Docker image provides a complete, self-contained RStudio Server environment for the **BRMS (Bayesian Regression Models using Stan)** workshop. It includes R, RStudio, the `brms` package, `CmdStan`, and all necessary dependencies and system libraries.

The environment is built on top of the official `rocker/verse` image, which provides a robust foundation with the Tidyverse and common development tools pre-installed.

---

### What's Included

*   **R & RStudio:** A recent version of R (`4.5.2`) and RStudio Server.
*   **Bayesian Stack:**
    *   `brms`: The main package for Bayesian regression modeling.
    *   `cmdstanr`: The modern R interface to Stan.
    *   `CmdStan`: The underlying Stan compiler, pre-installed and configured.
    *   Helper packages: `bayesplot`, `tidybayes`, `loo`, `shinystan`, and more.
*   **Tidyverse:** The full suite of Tidyverse packages for data manipulation and visualization.
*   **PDF Generation:** LaTeX is included for knitting R Markdown documents to PDF.

---

### Usage

#### Recommended: Docker Compose

The easiest way to run this image is with the `docker-compose.yml` file from the [GitHub repository](https://github.com/jobschepens/brms-ws). This automatically configures resource limits and volume mounts for you.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/jobschepens/brms-ws.git
    cd brms-ws
    ```

2.  **Pull the latest image:**
    ```bash
    docker compose pull
    ```

3.  **Start the container:**
    ```bash
    docker compose up -d
    ```

#### Manual: `docker run`

You can also run the image manually. Be sure to include the volume mounts and increase the shared memory size (`--shm-size`) for Stan to work efficiently.

```bash
docker run -d \
  --name brms-workshop \
  -p 8787:8787 \
  -e PASSWORD=workshop \
  -v ./materials:/home/rstudio/workshop/materials \
  -v ./results:/home/rstudio/workshop/results \
  --shm-size=2g \
  jobschepens/brms-workshop:working
```

---

### Accessing the Environment

*   **URL:** [http://localhost:8787](http://localhost:8787)
*   **Username:** `rstudio`
*   **Password:** `workshop` (or whatever you set in the `PASSWORD` environment variable)

The `materials` and `results` folders from your local directory will be available on the RStudio file pane inside the `workshop` folder.
