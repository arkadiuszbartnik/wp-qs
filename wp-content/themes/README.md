# Custom Themes

This directory contains custom WordPress themes as **Git submodules**.

## ⚠️ Important: All themes should be submodules

Each theme in this directory should be a separate Git repository added as a submodule:

```bash
# Add theme as submodule
make theme-add name=my-theme url=https://github.com/user/my-theme.git

# Or manually
git submodule add https://github.com/user/my-theme.git wp-content/themes/my-theme
```

## 🚫 Don't commit themes directly

Themes should **NOT** be committed directly to the main repo. 
They should be in separate repositories and added as submodules.

## Structure

Each theme should have its own structure:

```
theme-name/
├── style.css          # Main CSS file with header
├── index.php          # Main template
├── functions.php      # Theme functions
├── assets/           # CSS, JS, images
├── templates/        # Template files
├── README.md         # Documentation
└── .git/             # Separate repository (optional)
```

## Development

1. Create a new folder for the theme
2. Add style.css with header information
3. Add basic template files
4. Optionally: create separate Git repository for the theme

## Examples

```bash
# Create new theme
./git-submodules.sh create-theme my-theme

# Add existing theme as submodule
./git-submodules.sh add-theme existing-theme https://github.com/user/theme.git
```

## Available themes

# Add existing theme as submodule
./git-submodules.sh add-theme existing-theme https://github.com/user/theme.git
```
