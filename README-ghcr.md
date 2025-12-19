## Using the GitHub Container Registry Image

This requires you to authenticate to prevent download rate limits. GitHub applies rate limits to anonymous downloads to ensure service stability. Logging in with a Personal Access Token (PAT) tells GitHub who you are, giving you a much higher download limit and ensuring a more reliable connection.

### 1. Create a Personal Access Token (PAT)

A PAT is a secure password alternative that you can create specifically for this purpose.

1.  **Navigate to GitHub Settings:** Go to your GitHub **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**.
2.  **Generate a New Token:**
    *   Click **Generate new token**.
    *   Give it a descriptive **Note** (e.g., `brms-ws-docker-pull`).
    *   Set an **Expiration** date (e.g., 30 days).
    *   Under **Select scopes**, check the box for `read:packages`. This is the only permission needed.
    *   Click **Generate token**.
3.  **Copy the Token:** **Immediately copy the token** and save it somewhere safe. You will not be able to see it again after you leave the page.

### 2. Log in with Docker

Now, use the token you just created to log in from your terminal.

1.  **Store the token in a variable** (this prevents it from being saved in your shell history):
    ```bash
    export CR_PAT=YOUR_TOKEN_HERE
    ```

2.  **Log in securely:** This command pipes your token to the `docker login` command.
    ```bash
    echo $CR_PAT | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
    ```
    If successful, you'll see a `Login Succeeded` message.

### 4. Pull and Run the Image

Now that you're authenticated, you can pull and run the image just like any other.

```bash
# Pull the latest image
docker pull ghcr.io/jobschepens/brms-ws:working

# Run the container
docker run -d \
  -p 8787:8787 \
  -e PASSWORD=workshop \
  -v "$(pwd)/materials:/home/rstudio/workshop/materials" \
  -v "$(pwd)/results:/home/rstudio/workshop/results" \
  ghcr.io/jobschepens/brms-ws:working
```

You can now access RStudio at `http://localhost:8787` (login: `rstudio` / `workshop`).
