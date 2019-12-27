FROM swift:5.1.3

RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev \
  && rm -r /var/lib/apt/lists/*

WORKDIR /app

CMD ["swift", "run", "Run", "serve", "-b", "0.0.0.0"]
