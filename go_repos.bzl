"""Module extension providing SONiC-patched versions of openconfig/ygot and openconfig/goyang.

Both packages are pinned to specific versions and patched with SONiC-specific changes
(adds YGStructMetaMap and related types used across the SONiC management stack).
Consumers of sonic-mgmt-common get these repos automatically via the transitive dep graph.
"""

load("@gazelle//:deps.bzl", "go_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _gnmi_deps():
    """Inlined from gnmi_deps.bzl to avoid circular dep (gnmi is created by this extension).

    TODO(bazel-ready): Remove when migrating to a newer gnmi from the BCR.
    """
    http_archive(
        name = "com_github_grpc_grpc",
        url = "https://github.com/grpc/grpc/archive/refs/tags/v1.43.2.tar.gz",
        strip_prefix = "grpc-1.43.2",
        sha256 = "b74ce7d26fe187970d1d8e2c06a5d3391122f7bc1fdce569aff5e435fb8fe780",
    )
    http_archive(
        name = "rules_proto_grpc",
        sha256 = "507e38c8d95c7efa4f3b1c0595a8e8f139c885cb41a76cab7e20e4e67ae87731",
        strip_prefix = "rules_proto_grpc-4.1.1",
        urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/archive/4.1.1.tar.gz"],
    )
    http_archive(
        name = "com_google_protobuf",
        url = "https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-all-3.19.4.tar.gz",
        strip_prefix = "protobuf-3.19.4",
        sha256 = "ba0650be1b169d24908eeddbe6107f011d8df0da5b1a5a4449a913b10e578faf",
    )
    http_archive(
        name = "com_google_googleapis",
        url = "https://github.com/googleapis/googleapis/archive/ccb9d245ddac58b8d4ad918e6a914e841a64cc28.zip",
        strip_prefix = "googleapis-ccb9d245ddac58b8d4ad918e6a914e841a64cc28",
        sha256 = "feca5804fa0af2bc48d041a8b6e0356fb9e4848b3dd6ee74ab847022e90c69ff",
    )
    # Bumped from v4.0.0 (in gnmi_deps.bzl) to v7.1.0: the old version uses
    # the native proto_common symbol which was removed in Bazel 8.
    http_archive(
        name = "rules_proto",
        sha256 = "14a225870ab4e91869652cfd69ef2028277fc1dc4910d65d353b62d6e0ae21f4",
        strip_prefix = "rules_proto-7.1.0",
        urls = [
            "https://github.com/bazelbuild/rules_proto/archive/refs/tags/7.1.0.tar.gz",
        ],
    )

def _sonic_go_repos_impl(module_ctx):

    _gnmi_deps()

    # TODO(bazel-ready): Migrate to a more recent version of openconfig/gnmi
    # so we can consume it from the BCR instead of using go_repository + gnmi_deps().
    # We add gnmi here because version 0.11.0 has BUILD files,
    # but is WORKSPACE-only, so we can't pull it from the BCR.
    go_repository(
        name = "com_github_openconfig_gnmi",
        importpath = "github.com/openconfig/gnmi",
        patch_args = ["-p1"],
        patches = ["//patches/gnmi:gnmi.patch"],
        sum = "h1:H7pLIb/o3xObu3+x0Fv9DCK7TH3FUh7mNwbYe+34hFw=",
        version = "v0.11.0",
    )

    go_repository(
        name = "com_github_openconfig_ygot",
        build_directives = ["gazelle:proto_import_prefix github.com/openconfig/ygot"],
        importpath = "github.com/openconfig/ygot",
        patch_args = ["-p1"],
        patches = ["//patches/ygot:ygot.patch"],
        sum = "h1:EKaeFhx1WwTZGsYeqipyh1mfF8y+z2StaXZtwVnXklk=",
        version = "v0.13.1",
    )
    go_repository(
        name = "com_github_openconfig_goyang",
        importpath = "github.com/openconfig/goyang",
        patch_args = ["-p1"],
        patches = ["//patches/goyang:goyang.patch"],
        sum = "h1:Z95LskKYk6nBYOxHtmJCu3YEKlr3pJLWG1tYAaNh3yU=",
        version = "v0.2.9",
    )
    return module_ctx.extension_metadata(
        root_module_direct_deps = [],
        root_module_direct_dev_deps = [],
    )

sonic_go_repos = module_extension(implementation = _sonic_go_repos_impl)
