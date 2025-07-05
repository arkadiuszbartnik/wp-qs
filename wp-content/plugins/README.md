# Custom Plugins

This directory contains custom WordPress plugins as **Git submodules**.

## ⚠️ Important: All plugins should be submodules

Each plugin in this directory should be a separate Git repository added as a submodule:

```bash
# Add plugin as submodule
make plugin-add name=my-plugin url=https://github.com/user/my-plugin.git

# Or manually
git submodule add https://github.com/user/my-plugin.git wp-content/plugins/my-plugin
```

## 🚫 Don't commit plugins directly

Plugins should **NOT** be committed directly to the main repo. 
They should be in separate repositories and added as submodules.

```
plugin-name/
├── plugin-name.php      # Main plugin file
├── assets/             # CSS, JS, images
├── includes/           # PHP classes
├── languages/          # Translations
├── README.md          # Documentation
└── .git/              # Separate repository (optional)
```

## Development

1. Create a new folder for the plugin
2. Add main PHP file with header information
3. Optionally: create separate Git repository for the plugin
4. Add as submodule to main repo

## Examples

```bash
# Create new plugin
./git-submodules.sh create-plugin my-plugin

# Add existing plugin as submodule
./git-submodules.sh add-plugin existing-plugin https://github.com/user/plugin.git
```
