FROM openshift/base-centos7

EXPOSE 8080

ENV TOMCAT_VERSION=8.5.34 \
    MAVEN_VERSION=3.5.4 \
    STI_SCRIPTS_PATH=/opt/s2i/

LABEL io.k8s.description="Platform for building and running JEE applications on Tomcat" \
      io.k8s.display-name="Tomcat Builder" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,tomcat" \
      io.openshift.s2i.destination="/opt/s2i/destination"

COPY apache-maven-3.5.4-bin.tar /
COPY apache-tomcat-8.5.34.tar /

# Install Maven, Tomcat 8.5.24
RUN INSTALL_PKGS="tar java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    tar -xvf /apache-maven-3.5.4-bin.tar    -C /usr/local && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /tomcat && \
    tar -xvf /apache-tomcat-8.5.34.tar --strip-components=1 -C /tomcat && \ 
    rm -rf /tomcat/webapps/* && \
    mkdir -p /opt/s2i/destination

# Add s2i customizations
#ADD ./contrib/settings.xml $HOME/.m2/

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chmod -R a+rw /tomcat && \
    chmod a+rwx /tomcat/* && \
    chmod +x /tomcat/bin/*.sh && \
#    chmod -R a+rw $HOME && \
    chmod -R +x $STI_SCRIPTS_PATH && \
    chmod -R g+rw /opt/s2i/destination

USER 1001

CMD $STI_SCRIPTS_PATH/usage
