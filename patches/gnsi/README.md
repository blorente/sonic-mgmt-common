# gnsi patch

openconfig/gnsi v1.7.0 BUILD files load `cpp_grpc_library` from
`@rules_proto_grpc//cpp:defs.bzl`. In rules_proto_grpc 5.0.0+ the C++ rules
were split into a separate Bazel module (`rules_proto_grpc_cpp`), so the old
label is no longer valid under bzlmod.

This patch rewrites the load statements in all five sub-package BUILD files
(acctz, authz, certz, credentialz, pathz) to use
`@rules_proto_grpc_cpp//cpp:defs.bzl` instead.
