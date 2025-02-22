# Use the latest Python image as the base
FROM python:latest

# Install required system packages and Oracle JDK 21
USER root
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    wget \
    bash \
    && wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb \
    && dpkg -i jdk-21_linux-x64_bin.deb \
    && rm jdk-21_linux-x64_bin.deb \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
RUN pip install --no-cache-dir --upgrade pip

# Create a non-root user and switch to it
RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH"

# Set working directory for Minecraft
WORKDIR /minecraft

# Copy required files into the container (ensure these exist in your build context)
COPY --chown=user ./requirements.txt requirements.txt
COPY --chown=user ./server.py server.py
COPY --chown=user ./plugins.sh plugins.sh
COPY --chown=user ./server.properties server.properties
COPY --chown=user ./start.sh start.sh
COPY --chown=user ./eula.txt eula.txt
RUN chmod +x plugins.sh start.sh

# Install Python dependencies (for your downloader scripts)
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Expose the necessary ports: 7860 for the dummy HTTP server
EXPOSE 7860
 
# Run the HTTP server and playit-agent silently, but keep the Minecraft server output visible
RUN wget https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 && \
    chmod +x playit-linux-amd64
CMD bash -c "python -m http.server 7860 & ./playit-linux-amd64 --platform_docker --secret 09bdbd4343e4f96b6ea63e98ad32881957aae1ae817655df34d435da25835f6a & exec bash start.sh"