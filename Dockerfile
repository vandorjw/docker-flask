FROM python:3.6

ENV PYTHONUNBUFFERED 1
ENV PIPENV_VENV_IN_PROJECT=True

RUN useradd -c 'pyuser' --home-dir /app -s /bin/bash pyuser
RUN echo 'pyuser:pyuser' | chpasswd

RUN pip install pipenv

COPY Pipfile /app/Pipfile
COPY Pipfile.lock /app/Pipfile.lock
RUN cd /app && pipenv install

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
RUN chown pyuser:pyuser /entrypoint.sh

RUN mkdir -p /app/src

USER pyuser

WORKDIR /app/src

EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
