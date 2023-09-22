# Use the specified Rust version
FROM rust:1.67

COPY Cargo.toml ./

RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    libzmq3-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/* # Clean up to reduce image size



# Add clippy for linting
RUN rustup component add clippy

# Set up the Rust workspace
WORKDIR /rust-jupyter

# Run clippy with pedantic lints
RUN cargo clippy --release -- -D warnings -W clippy::pedantic

# Install Jupyter and Jupyter Lab
RUN pip3 install jupyter jupyterlab

# Install and set up the Rust Jupyter kernel
RUN cargo install evcxr_jupyter && \
    evcxr_jupyter --install

# Expose the Jupyter port
EXPOSE 8888

# Set the ENTRYPOINT to run Jupyter Lab by default
ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser"]