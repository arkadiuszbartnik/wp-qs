# Scripts

This directory contains all WordPress environment management scripts.

## Main scripts

### manage.sh
Docker container and WordPress management:
```bash
./manage.sh start|stop|restart|status|logs|shell|backup|restore
```

### setup.sh
Environment initialization:
```bash
./setup.sh
```

### git-submodules.sh
Submodule management (plugins/themes):
```bash
./git-submodules.sh create-plugin|add-plugin|update-plugin|remove-plugin
```

### mysql-logs.sh
MySQL log management:
```bash
./mysql-logs.sh copy-mysql-logs
```

### test-environment.sh
Environment correctness test:
```bash
./test-environment.sh
```

## Usage from main directory

All scripts can be run from the main directory via symlinks:
```bash
./manage.sh start
./setup.sh
```

Or via Makefile:
```bash
make start
make setup
```
