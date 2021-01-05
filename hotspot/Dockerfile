FROM adoptopenjdk/openjdk11:alpine-jre

WORKDIR /
RUN apk upgrade --no-cache

# Add 'runner' user
ARG user=runner
ARG group=runner
ARG uid=9001
ARG gid=7373
ARG home_dir=/home/runner

ENV HOME ${home_dir}

RUN addgroup --system ${group} --gid ${gid} \
	&& adduser --system --uid ${uid} --home "$HOME" --ingroup ${group} --shell /bin/ash ${user} \
	&& chown -R ${user}:${group} ${home_dir}

# Switch context
WORKDIR ${home_dir}
USER ${user}
