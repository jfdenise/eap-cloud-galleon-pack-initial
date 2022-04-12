#!/bin/bash
# Script to build an S2I image containing the built cloud FP and EAP 8 FP
# 1) Build the cloud FPs
# 2) Call this script
# 3) the image jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:${cloudVersion} will be built.
SCRIPT_DIR=$(dirname $0)
pushd ..
cloudVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
tmpPath=/tmp/custom-cloud-image
mkdir -p $tmpPath
unzip ~/Downloads/jboss-eap-8.0.0.Beta-redhat-20220408-image-builder-maven-repository.zip -d $tmpPath
mkdir -p $tmpPath/docker/
mv $tmpPath/jboss-eap-8.0.0.Beta-image-builder-maven-repository/maven-repository $tmpPath/docker/
mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/cloud/eap-cloud-galleon-pack/$cloudVersion
cp eap-cloud-galleon-pack/target/eap-cloud-galleon-pack-$cloudVersion.zip $tmpPath/docker/maven-repository/org/jboss/eap/cloud/eap-cloud-galleon-pack/$cloudVersion
docker_file=$tmpPath/docker/Dockerfile
cat <<EOF > $docker_file
  FROM jboss-eap-8-tech-preview/eap-8-openjdk11-openshift-rhel8:latest
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root maven-repository /tmp/artifacts/m2
EOF
docker build -t jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:${cloudVersion} $tmpPath/docker

cat <<EOF > $docker_file
  FROM jboss-eap-8-tech-preview/eap-8-openjdk17-openshift-rhel8:latest
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root maven-repository /tmp/artifacts/m2
EOF
docker build -t jboss-eap-8-tech-preview/custom-eap8-openjdk17-builder:${cloudVersion} $tmpPath/docker

rm -rf $tmpPath