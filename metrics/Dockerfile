FROM python:3.6.6-slim-stretch

RUN apt-get update && \
apt-get install -yq --no-install-recommends \
build-essential python-pip python3-dev git curl default-libmysqlclient-dev  && \
pip install --upgrade pip && \
pip install pymysql datadog && \
rm -rf /var/lib/apt/lists/* && \
apt-get clean && \
apt-get purge -y

COPY proxysql.py /proxysql.py

ENTRYPOINT ["python", "/proxysql.py"]
