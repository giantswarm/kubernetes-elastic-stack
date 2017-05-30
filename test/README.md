# Simple test suite

This uses [Sharness](https://github.com/chriscool/sharness) for running the tests.


At first start a fresh Minikube environment.

```bash
minikube delete
minikube start --vm-driver kvm --memory 4096 --kubernetes-version "v1.6.0"
```

Then run from this directory:
```
./simple.t
```

Since it test on the amount of indexed log lines repeat this after some time until successful.


*To be continued..*
