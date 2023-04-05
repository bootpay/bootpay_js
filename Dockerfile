FROM ruby:2.7.8

RUN echo "$(sed -e 's/deb.debian.org/ftp.kr.debian.org/g' /etc/apt/sources.list)" > /etc/apt/sources.list
# Install dependencies
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y build-essential libpq-dev nginx-extras imagemagick libmagickwand-dev libssl-dev libreadline-dev nodejs libffi-dev yarn vim
RUN apt-get clean && rm -rf /var/cache/apt/archives && rm -rf /var/lib/apt/lists

# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /var/www
# RUN mkdir -p $RAILS_ROOT

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

COPY package.json package.json
RUN yarn install

RUN rm -f /etc/nginx/sites-enabled/default
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

EXPOSE 3001
CMD ./node_modules/.bin/webpack-dev-server --host 0.0.0.0