# Main SLATE application catalog

This repository contains all the applications that are packaged to be installed on the SLATE platform.

# How to use

The slate-cli already points to this repository. 

# Repository layout

Example:

	stable/
		my_app/
			my_app/
				(chart sources)
			images/
				my_app/
					Dockerfile
					image_nametag
					(other container image source files)
				a_helper_image/
					Dockerfile
					image_nametag
					(other container image source files)

As for the [main kubernetes helm repository](https://github.com/kubernetes/charts), there are two repositories: stable and incubator. Stable holds applications that are fully vetted while incubator holds those that are still under development. Each application is a subdirectory within one of those two directories.

Each application subdirectory must contain another subdirectory _with the same name_ which contains the helm chart sources.
This enables including other data besides chart sources for an application, however, because helm requires a chart source directory to have a name matching the chart name nested directories with the same names are unavoidable.

Besides the subdirectory for the chart sources, an application's directory can contain a subdirectory named 'images', which contains further subdirectories for any container image sources, one per image. The image source directories may have any names. Each image source directory should contain the Dockerfile which defines the image, any supporting files, and one special file named 'image\_nametag' which contains the name and tag to be used for the image, like "my\_app:latest". 

# How to rebuild the packages

To rebuild all packages from sources:

```bash
> mkdir build
> cd build
> cmake ..
> make
```

CMake 3 is required, so on some systems it may be necessary to replace `cmake` above with `cmake3`.

## Known limitations

When a chart is added or a file is added to a chart the cmake scripts will not take notice until `make rebuild_cache` is run.  

## Incubator vs Stable

When a new application is packaged as a helm chart and is added to the SLATE catalog it is initially placed into the Incubator. It will stay in the incubator until it has been thouroughly tested to prove that the application works in SLATE the same way it is supposed to outside of SLATE. Once all parties involved agree that the application functions it will be moved to the Stable repository where it can be easily accessed from the portal and command line interface

## Chart Version

Whenever a change is made to a chart in any way, from templates to documentation, the version value in Chart.yaml must be incremented so that Helm will update the helm charts used by the API Server
