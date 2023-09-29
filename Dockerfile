# Use the specified Rust version
FROM rust:1.70

# Copy the Cargo.toml file
COPY Cargo.toml /rust-jupyter/

# Install necessary system dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3-pip \
    libzmq3-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/* # Clean up to reduce image size

# Install Python packages
RUN rm -rf /tmp/* && pip3 install --no-cache-dir jupyter jupyterlab


# Add clippy for linting
RUN rustup component add clippy

# Set up the Rust workspace
WORKDIR /rust-jupyter

# Create a dummy Rust project to check if everything is in order
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs
    

# Run clippy with pedantic lints
RUN cargo clippy --release -- -D warnings -W clippy::pedantic

# Install and set up the Rust Jupyter kernel
RUN cargo install evcxr_jupyter && \
    evcxr_jupyter --install

# Expose the Jupyter port
EXPOSE 8888

# Set the ENTRYPOINT to run Jupyter Lab by default
ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser"]