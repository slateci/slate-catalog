# Main SLATE application catalog

This repository contains all the applications that are packaged to be installed on the SLATE platform.

# How to use

The slate-cli already points to this repository. To install packages using helm directly simply add the repositories

```bash
> helm repo add slate-dev `https://raw.githubusercontent.com/slateci/slate-catalog/master/incubator-repo/`
> helm repo add slate `https://raw.githubusercontent.com/slateci/slate-catalog/master/stable-repo/`
```

NOTE: the stable repo is currently empty

# Repository layout

As for the [main kubernates helm repository](https://github.com/kubernetes/charts), there are two directories: stable and incubator. Stable is currently empty and therefore is not shown in the github repository. Stable holds application that are fully vetted while incubator holds those that are still under development. Each application is a subdirectory within one of those two directories.

There are also other two directories which hold the built packages: incubator-repo and stable repo. These should contain only packages built by the corresponding sources in the stable/incubator directories.

# How to rebuild the packages

To rebuild all packages from sources:

On Linux:

```bash
> helm package ..\incubator\*
> helm repo index .
```

On windows:

```powershell
> helm package (get-item ..\incubator\*).FullName
> helm repo index .
```

The first command creates all the package while the second one creates the index file
