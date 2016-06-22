FROM python:2.7

USER root

RUN yum -y update && \
    yum install -y python-dev libldap2-dev libsasl2-dev libssl-dev python-ldap tar wget

ENV PYTHONPATH "/usr/local/lib/python2.7/site-packages"

COPY requirements.txt /root

RUN pip install -r /root/requirements.txt

RUN useradd web2ldap

RUN wget https://www.web2ldap.de/download/web2ldap-1.2.61.tar.gz && \
    tar -zxvf web2ldap-1.2.61.tar.gz && \
    mv web2ldap-1.2.61 /opt/web2ldap && \
    rm -f web2ldap-1.2.61.tar.gz

WORKDIR /opt/web2ldap

COPY misc.py /etc/web2ldap/web2ldapcnf/

RUN chmod 777 /etc/web2ldap/web2ldapcnf/misc.py 

RUN sed -i s/127.0.0.1:1760/0.0.0.0:1760/g etc/web2ldap/web2ldapcnf/standalone.py && \
    sed -i s/"\['127.0.0.0\/255.0.0.0','::1','fe00::0'\]"/"\['0.0.0.0\/0.0.0.0','::0'\]"/g etc/web2ldap/web2ldapcnf/standalone.py

USER web2ldap

EXPOSE 1760

CMD sbin/web2ldap.py && tail -F var/log/web2ldap_error_log