# dev-keys

**Test and local development only.** This key pair is committed on purpose, so
that `./mvnw verify` and `quarkus dev` run with no setup on a fresh clone.

It is safe because it is worthless:

- it is public, in a public repository, and signs nothing that matters;
- it sits outside `src/`, so it is never packaged into the jar or the image;
- every deployment supplies its own key through the environment.

A deployment that fell back to this key would be trivially forgeable, which is
why `smallrye.jwt.sign.key.location` points here only under the `dev` and `test`
profiles and has no value at all in the packaged application.

Rotating them is `openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048
-out private.pem` followed by `openssl rsa -in private.pem -pubout -out
public.pem`.
