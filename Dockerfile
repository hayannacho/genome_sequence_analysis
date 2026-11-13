FROM ubuntu:24.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3 ncbi-blast+ seqtk && rm -rf /var/lib/apt/lists/*
WORKDIR /project
CMD ["python3", "-m", "unittest", "discover", "-s", "tests", "-v"]
