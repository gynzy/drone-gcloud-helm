FROM alpine:3.10

ENV GCLOUD_VERSION=272.0.0
ENV HELM_VERSION=v2.6.1

RUN apk --update --no-cache add python tar openssl wget ca-certificates

RUN mkdir -p /opt && cd /opt && \
	wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
	tar -xvf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
	google-cloud-sdk/install.sh --usage-reporting=true --path-update=true && \
	rm -f google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
	gcloud components install kubectl

RUN mkdir -p /tmp/gcloud && \
	wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
	tar -xvf helm-${HELM_VERSION}-linux-amd64.tar.gz && \
	cp linux-amd64/helm /opt/google-cloud-sdk/bin/ && \
	chmod a+x /opt/google-cloud-sdk/bin/helm && \

	cd && rm -rf /tmp/gcloud

COPY build/drone-gcloud-helm /opt/google-cloud-sdk/bin/

RUN chmod a+x /opt/google-cloud-sdk/bin/drone-gcloud-helm

ENV PATH=$PATH:/opt/google-cloud-sdk/bin

ENTRYPOINT ["/opt/google-cloud-sdk/bin/drone-gcloud-helm"]
