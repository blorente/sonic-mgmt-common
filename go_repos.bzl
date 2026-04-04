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

    # gnsi v1.7.0 ships WORKSPACE-style BUILD files that load cpp_grpc_library
    # from @rules_proto_grpc//cpp:defs.bzl. Under bzlmod with rules_proto_grpc
    # 5.0.0+, the C++ rules live in a separate module (rules_proto_grpc_cpp),
    # so those load statements are invalid.
    #
    # Rather than patching the BUILD files, we let gazelle regenerate them from
    # scratch ("clean"). sonic-gnmi only consumes the Go library targets from
    # gnsi (authz, certz, credentialz, pathz), not the C++ proto targets, so
    # the regenerated BUILD files (which omit cpp_grpc_library) are sufficient.
    # "gazelle:proto disable_global" prevents gazelle from registering proto
    # targets globally, avoiding conflicts with other proto providers.
    go_repository(
        name = "com_github_openconfig_gnsi",
        build_file_generation = "clean",
        build_directives = ["gazelle:proto disable_global"],
        importpath = "github.com/openconfig/gnsi",
        sum = "h1:Enn5i3m6KsnHeUI+kalB9OH8fADf0oeymd/3Ze0BzME=",
        version = "v1.7.0",
    )

    # SONiC patches glog to add syslog support, LOG_FIRST_N rate limiting,
    # stdout logging, and GetLogCount(). Pinned to the old pre-module version
    # that sonic-gnmi's go.mod replace directive also targets.
    go_repository(
        name = "com_github_golang_glog",
        importpath = "github.com/golang/glog",
        patch_args = ["-p1"],
        patches = ["//patches/glog:glog.patch"],
        sum = "h1:VKtxabqXZkF25pY9ekfRL6a582T4P37/31XEstQ5p58=",
        version = "v0.0.0-20160126235308-23def4e6c14b",
    )

    # gousb requires CGO with libusb and libudev from system packages.
    # The patch provides a hand-written BUILD file that uses @bookworm apt
    # packages for hermetic libusb/libudev linking instead of pkg-config.
    go_repository(
        name = "com_github_google_gousb",
        build_file_generation = "off",
        importpath = "github.com/google/gousb",
        patch_args = ["-p1"],
        patches = ["//patches/gousb:gousb_build.patch"],
        sum = "h1:xt6M5TDsGSZ+rlomz5Si5Hmd/Fvbmo2YCJHN+yGaK4o=",
        version = "v1.1.3",
    )

    # msteinert/pam requires CGO with libpam from system packages.
    # The patch provides a hand-written BUILD file that uses @bookworm apt
    # packages for hermetic libpam linking instead of pkg-config.
    go_repository(
        name = "com_github_msteinert_pam",
        build_file_generation = "off",
        importpath = "github.com/msteinert/pam",
        patch_args = ["-p1"],
        patches = ["//patches/pam:pam_build.patch"],
        sum = "h1:ZivaaKmjs9q90zi6I4gTLW6tbVGtlBjellr3hMYaly0=",
        version = "v0.0.0-20190215180659-f29b9f28d6f9",
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
