# Useful Command Alias

↩ [Go Back](README.md)

## Table of contents

- [Useful Command Alias](#useful-command-alias)
  - [Table of contents](#table-of-contents)
  - [Permanent Alias](#permanent-alias)
  - [Alias 'k' for kubectl](#alias-k-for-kubectl)
  - [Alias 'tf' for terraform](#alias-tf-for-terraform)

## Permanent Alias

```sh
echo 'alias k=kubectl' > ~/.bash_aliases
echo 'alias tf=terraform' > ~/.bash_aliases
```

## Alias 'k' for kubectl

```sh
alias k=kubectl
```

Usage

```sh
# original command
kubectl get pods`
# aliased command
k get pods
```

## Alias 'tf' for terraform

```sh
alias tf=terraform
```

Usage

```sh
# original command
terraform apply
# aliased command
tf apply
```
