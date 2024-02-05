# Flare

This repository hosts main code and bootstrap script of Flare, a helper tool
that gathers diagnosis information from your computer system.

Flare can be run directly in command line:

```
$ curl -sL flare.vessl.ai | sudo sh
```

* Bootstrap script (which is actually the response of `flare.vessl.ai`) is in `flare.sh`.
* Flare is written in Python. Source code is in `flare.tar`.
* Bootstrap script will download and execute said Python code.