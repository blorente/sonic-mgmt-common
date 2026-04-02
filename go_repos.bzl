"""Module extension providing SONiC-patched versions of openconfig/ygot and openconfig/goyang.

# TODO BL: update comment
Both packages are pinned to specific versions and patched with SONiC-specific changes
(adds YGStructMetaMap and related types used across the SONiC management stack).
Consumers of sonic-mgmt-common get these repos automatically via the transitive dep graph.
"""

load("@gazelle//:deps.bzl", "go_repository")

def _sonic_go_repos_impl(module_ctx):

    # TODO(bazel-ready): Migrate to a more recent version of openconfig/gnmi
    # so we can consume it from the BCR instead of using go_repository + gnmi_deps().
    # We add gnmi here because version 0.11.0 has BUILD files,
    # but is WORKSPACE-only, so we can't pull it from the BCR.
    go_repository(
        name = "com_github_openconfig_gnmi",
        # NOTE: Enable build-file generation, but disable it for protobuf.
        # gnmi already has hand-crafted BUILD files for protobuf, we don't want to override those.
        build_file_generation = "on",
        build_directives = ["gazelle:proto disable_global"],
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
        patches = [
            "//patches/ygot:ygot.patch",
            "//patches/ygot:ygot_build.patch",
        ],
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
