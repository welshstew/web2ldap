FROM python:2.7

USER root

RUN yum -y update --enablerepo=updates-testing python-ldap-2.4.17-1.fc21 && \
    yum install -y python-dev libldap2-dev libsasl2-dev libssl-dev python-ldap-2.4.17-1.fc21 python-ipaddr python-pyasn1 tar wget python-pyasn1-modules.noarch

# ENV PYTHONPATH "/usr/local/lib/python2.7/site-packages"

COPY requirements.txt /root

RUN useradd web2ldap

RUN /opt/rh/python27/root/usr/bin/pip install -r /root/requirements.txt && \
    wget https://www.web2ldap.de/download/web2ldap-1.2.61.tar.gz && \
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

RUN /opt/web2ldap/web2ldap_postinstall.sh

CMD sbin/web2ldap.py && tail -F var/log/web2ldap_error_log