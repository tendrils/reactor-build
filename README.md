# ReBuild
ReBuild is a set of scripts providing a common project model and build automation framework for complex modular software projects, based on GNU Make. The script framework is modular and extensible, making it easy to add new features and support new tools. ReBuild has no dependencies other than Make, and runs entirely within the Make process, making it trivial to integrate with projects which already use Make.

## Installation
ReBuild is designed to be integrated by including it into the project codebase as a git submodule. It is recommended that you create your own fork of the ReBuild git repo and include that into your project, as this gives you direct control over if and when your project receives updates to ReBuild from upstream.

```
git submodule add --name rebuild https://github.com/tendrils/reactor-build.git
```
