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
    # gnmi_deps.bzl fetches com_github_grpc_grpc, rules_proto_grpc,
    # com_google_protobuf, rules_proto, and com_google_googleapis.
    # None are needed: gnmi's upstream BUILD files use them for C++ targets,
    # but we delete those BUILD files and let Gazelle regenerate Go-only ones
    # (via build_file_generation = "on" + patch_cmds below).

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
