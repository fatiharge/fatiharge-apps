# motto

Kişilik envanteri temelli motto ve alışkanlık zinciri.

## Flavors

Two, and neither is optional: a build without one refuses to start rather than
guessing which server to talk to.

```bash
fvm flutter run   --flavor stage        # mottostage.dafalabs.com
fvm flutter run   --flavor prod         # motto.dafalabs.com
fvm flutter build apk --flavor stage --debug
```

They install side by side. `stage` carries the `.stage` application id suffix
and is called **Motto Stage** on the home screen, so the two cannot be confused
on one phone — which is the whole reason for having them rather than a build
flag.

On iOS each flavor is a scheme with its own `Debug-`, `Release-` and `Profile-`
configurations. They were generated with the `xcodeproj` gem rather than clicked
together in Xcode, so `tool/` has no manual step to forget.

## Code generation

```bash
fvm dart run build_runner build          # routes and the DI container
./tool/coverage_helper.sh                # after adding a library
```

The coverage helper imports every library so that a file nobody tested counts
as 0% instead of vanishing from the report. Its own test fails when a new file
is missing from it.

## Where things go

`features/<feature>/{application,presentation}` and `domain` only where there is
real local logic — the chain will have some; scoring and entitlements live on
the server and have none here. Empty layers are a ceremony that misleads
whoever reads them next.
