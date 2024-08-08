# Devcontainer

↩ [Go Back](README.md)

## Table of contents

- [Devcontainer](#devcontainer)
  - [Table of contents](#table-of-contents)
  - [devcontainer.json](#devcontainerjson)
  - [Dockerfile](#dockerfile)
    - [AWS-SAM Setup](#aws-sam-setup)
    - [AWS-CDK Setup](#aws-cdk-setup)
    - [Terrafrom setup](#terrafrom-setup)
    - [Kubectl Setup](#kubectl-setup)
    - [graphviz setup](#graphviz-setup)

## devcontainer.json

```json
{
  // "image": "mcr.microsoft.com/vscode/devcontainers/base:ubuntu",
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".."
  },
  "postCreateCommand": "echo 'alias tf=terraform' > /home/vscode/.bash_aliases",
  "customizations": {
    "vscode": {
      "settings": {
        "[markdown]": {
          "editor.defaultFormatter": "DavidAnson.vscode-markdownlint"
        },
        "[html]": {
          "editor.defaultFormatter": "esbenp.prettier-vscode",
          "editor.suggest.insertMode": "replace",
          "djlint.enableLinting": true
        },
        "[javascript]": {
          "editor.defaultFormatter": "esbenp.prettier-vscode",
          "editor.maxTokenizationLineLength": 2500
        }
      },
      "extensions": [
        "samuelcolvin.jinjahtml",
        "monosans.djlint",
        "esbenp.prettier-vscode",
        "FallenMax.mithril-emmet",
        "GitHub.copilot",
        "hashicorp.terraform",
        "yzhang.markdown-all-in-one",
        "DavidAnson.vscode-markdownlint"
      ]
    }
  },
  "features": {
    "ghcr.io/devcontainers/features/python:1": {},
    "ghcr.io/devcontainers/features/aws-cli:1": {},
    "ghcr.io/devcontainers/features/terraform:1": {},
    "ghcr.io/devcontainers/features/node:1": {}
  }
}
```

Reference Links:

- [https://code.visualstudio.com/docs/devcontainers/create-dev-container](https://code.visualstudio.com/docs/devcontainers/create-dev-container)
- [https://containers.dev/implementors/json_reference/](https://containers.dev/implementors/json_reference/)

## Dockerfile

```dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# no output
ENV DEBIAN_FRONTEND=noninteractive

## apt setup

# output
ENV DEBIAN_FRONTEND=dialog
```

Reference Links:

- [https://code.visualstudio.com/docs/devcontainers/create-dev-container](https://code.visualstudio.com/docs/devcontainers/create-dev-container)
- [https://askubuntu.com/questions/972516/debian-frontend-environment-variable](https://askubuntu.com/questions/972516/debian-frontend-environment-variable)

### AWS-SAM Setup

```dockerfile
ARG SAM_FILE=aws-sam.zip
ARG SAM_INSTALL=sam-inst

RUN mkdir -p /tmp/setup \
    && curl -L -o ${SAM_FILE} https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip \
    && unzip ${SAM_FILE} -d ${SAM_INSTALL} \
    && ./${SAM_INSTALL}/install \
    && sam --version \
    && rm -rf ${SAM_FILE} ${SAM_INSTALL}
```

Reference Links:

- [https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)

### AWS-CDK Setup

```dockerfile
RUN sudo apt-get update \
    && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh \
    && sudo -E bash /tmp/nodesource_setup.sh \
    && sudo apt-get update \
    && sudo apt-get install -y nodejs \
    && rm /tmp/nodesource_setup.sh
```

Reference Links:

- [https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html)

### Terrafrom setup

```dockerfile
RUN wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list \
    && sudo apt update && sudo apt install terraform
```

Reference Links:

- [https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Kubectl Setup

```dockerfile
RUN curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH \
    && echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc \
    && rm kubectl
```

Reference Links:

- [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

### graphviz setup

```dockerfile
RUN apt-get update \
    && apt install graphviz -y
```

Reference Links:

- [https://graphviz.org/download/](https://graphviz.org/download/)
