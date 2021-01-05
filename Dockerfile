FROM alpine:3.12

ENV GCLOUD_VERSION=272.0.0
ENV KUBECTL_VERSION=v1.5.2
ENV HELM_VERSION=v2.15.2
ENV GOPATH="/go"
ENV GOBIN=$GOPATH/bin


RUN apk update && apk --no-cache add python3 tar openssl wget ca-certificates go git

RUN mkdir -p /opt && cd /opt && \
	wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
	tar -xvf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
	google-cloud-sdk/install.sh --usage-reporting=true --path-update=true && \
	rm -f google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz

RUN mkdir -p /tmp/gcloud && \
	cd /tmp/gcloud && \
	wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
	cp kubectl /opt/google-cloud-sdk/bin/ && \
	chmod a+x /opt/google-cloud-sdk/bin/kubectl && \

	wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
	tar -xvf helm-${HELM_VERSION}-linux-amd64.tar.gz && \
	cp linux-amd64/helm /opt/google-cloud-sdk/bin/ && \
	chmod a+x /opt/google-cloud-sdk/bin/helm && \

	cd && rm -rf /tmp/gcloud

COPY plugin.go main.go ./

RUN mkdir /go && go get && go install && go build && mv /go/bin/_ /opt/google-cloud-sdk/bin/drone-gcloud-helm

RUN chmod a+x /opt/google-cloud-sdk/bin/drone-gcloud-helm

ENV PATH=$PATH:/opt/google-cloud-sdk/bin

ENTRYPOINT ["/opt/google-cloud-sdk/bin/drone-gcloud-helm"]
