FROM my6889/coscmd:v0.1
RUN apt update -y \
&& apt install curl mydumper -y \
&& apt upgrade -y \
&& rm -rf /var/lib/apt/lists/* \
&& pip3 install awscli --upgrade \
&& curl -L http://gosspublic.alicdn.com/ossutil/1.7.7/ossutil64 -o /usr/local/bin/ossutil64 \
&& chmod +x /usr/local/bin/ossutil64 \
&& mkdir /mysqldump \
&& chmod -R 777 /mysqldump

COPY dump.sh /
RUN chmod +x dump.sh
ENTRYPOINT ["/dump.sh"]