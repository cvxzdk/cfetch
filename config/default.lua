return {
    ignore_patterns = {
        "^%.git$",
        "^node_modules$",
        "^%.DS_Store$",
        "^__pycache__$",
        "%.pyc$",
    },
    default_branch = "main",
    line_numbers = true,
}
```

### 18. `config/.cfetchignore.example`
```
.git
node_modules
.DS_Store
__pycache__
*.pyc
dist
build
.vscode
.idea