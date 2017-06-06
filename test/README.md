# Simple test suite

This uses [Sharness](https://github.com/chriscool/sharness) for running the tests.


At first start a fresh Minikube environment.

```bash
minikube delete
minikube start --memory 4096
```

Then run from this directory:
```
./simple.t
```

Since it test on the amount of indexed log lines repeat this after some time until successful.


*To be continued..*
