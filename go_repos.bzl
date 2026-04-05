"""Module extension providing SONiC-patched Go dependencies and their
transitive deps that need build graph fixes.

Patched packages carry SONiC-specific changes (syslog in glog,
JWT in gnxi, etc.). Transitive fixup packages have no code changes
but must live here so gazelle resolves imports to the patched copies
instead of the go_deps copies, avoiding diamond dependency conflicts.
"""

load("@gazelle//:deps.bzl", "go_repository")

# Repos with no SONiC patches that must live in sonic_go_repos
# only to keep the build graph consistent.
# They are transitive deps of patched repos and would otherwise
# be fetched by go_deps, causing duplicate-package linker errors.
#
# If a repo's checked-in BUILD files are broken under bzlmod
# (e.g. go_grpc_v2-only compilers, WORKSPACE-era labels),
# set build_file_generation = "clean" so gazelle regenerates them.
def _register_transitive_dependency_fixes():
    go_repository(
        name = "com_github_openconfig_grpctunnel",
        build_file_generation = "clean",
        build_directives = ["gazelle:proto disable_global"],
        importpath = "github.com/openconfig/grpctunnel",
        sum = "h1:EN99qtlExZczgQgp5ANnHRC/Rs62cAG+Tz2BQ5m/maM=",
        version = "v0.1.0",
    )

    # gnsi v1.7.0 ships WORKSPACE-style BUILD files that load
    # cpp_grpc_library from @rules_proto_grpc//cpp:defs.bzl.
    # Under bzlmod with rules_proto_grpc 5.0.0+,
    # the C++ rules live in a separate module (rules_proto_grpc_cpp),
    # so those load statements are invalid.
    #
    # sonic-gnmi only consumes the Go library targets from gnsi,
    # not the C++ proto targets, so omitting cpp_grpc_library is fine.
    go_repository(
        name = "com_github_openconfig_gnsi",
        build_file_generation = "clean",
        build_directives = ["gazelle:proto disable_global"],
        importpath = "github.com/openconfig/gnsi",
        sum = "h1:Enn5i3m6KsnHeUI+kalB9OH8fADf0oeymd/3Ze0BzME=",
        version = "v1.7.0",
    )

    go_repository(
        name = "com_github_protocolbuffers_txtpbfmt",
        build_file_generation = "clean",
        importpath = "github.com/protocolbuffers/txtpbfmt",
        sum = "h1:AKJY61V2SQtJ2a2PdeswKk0NM1qF77X+julRNYRxPOk=",
        version = "v0.0.0-20220608084003-fc78c767cd6a",
    )

    # gnoi's checked-in BUILD files reference @com_github_grpc_grpc for C++
    # targets that don't resolve under bzlmod.  Turning generation off keeps
    # those files inert; sonic-gnmi only uses the Go library targets anyway.
    go_repository(
        name = "com_github_openconfig_gnoi",
        build_file_generation = "off",
        importpath = "github.com/openconfig/gnoi",
        sum = "h1:7u+4jc9kEuaXMYHCLLW2eRO0WC3mElx+0/t/xqRtYJ4=",
        version = "v0.4.1-0.20240320162840-dbdca7782474",
    )

    go_repository(
        name = "com_github_mitchellh_go_wordwrap",
        importpath = "github.com/mitchellh/go-wordwrap",
        sum = "h1:TLuKupo69TCn6TQSyGxwI1EblZZEsQ0vMlAFQflz0v0=",
        version = "v1.0.1",
    )

def _sonic_go_repos_impl(module_ctx):

    _register_transitive_dependency_fixes()

    # TODO(bazel-ready): Migrate to a more recent version of openconfig/gnmi
    # so we can consume it from the BCR instead of using go_repository + gnmi_deps().
    # We add gnmi here because version 0.11.0 has BUILD files,
    # but is WORKSPACE-only, so we can't pull it from the BCR.
    go_repository(
        name = "com_github_openconfig_gnmi",
        # NOTE: Enable build-file generation, but disable it for protobuf.
        # gnmi already has hand-crafted BUILD files for protobuf,
        # we don't want to override those.
        build_file_generation = "on",
        build_directives = [
            "gazelle:proto disable_global",
        ],
        importpath = "github.com/openconfig/gnmi",
        patch_args = ["-p1"],
        patches = ["//patches/gnmi:gnmi.patch"],
        sum = "h1:H7pLIb/o3xObu3+x0Fv9DCK7TH3FUh7mNwbYe+34hFw=",
        version = "v0.11.0",
    )

    # gousb requires CGO with libusb and libudev from system packages.
    # Patch it so that we use hermetic @bookworm dependencies instead.
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
    # Patch it so that we use hermetic @bookworm dependencies instead.
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
        name = "com_github_google_gnxi",
        importpath = "github.com/google/gnxi",
        patch_args = ["-p1"],
        patches = ["//patches/gnxi:gnxi.patch"],
        sum = "h1:OtErLAncPdsEEhOI4ueR48dr6uThRIPkwWcOAdQ4LyI=",
        version = "v0.0.0-20191016182648-6697a080bc2d",
    )

    # Pinned to the old pre-module version from sonic-gnmi's go.mod
    go_repository(
        name = "com_github_golang_glog",
        importpath = "github.com/golang/glog",
        patch_args = ["-p1"],
        patches = ["//patches/glog:glog.patch"],
        sum = "h1:VKtxabqXZkF25pY9ekfRL6a582T4P37/31XEstQ5p58=",
        version = "v0.0.0-20160126235308-23def4e6c14b",
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
