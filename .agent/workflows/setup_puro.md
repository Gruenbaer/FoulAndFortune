---
description: Configure shell to use Puro for Flutter
---
To set up the environment for this project, run the following:

1. Check if Puro is available
// turbo
```powershell
puro --version
```

2. Use the stable environment
// turbo
```powershell
puro use stable
```

3. Verify Flutter access
// turbo
```powershell
puro flutter --version
```

4. (Optional) Alias flutter to puro flutter for this session
```powershell
function flutter { puro flutter $args }
```
