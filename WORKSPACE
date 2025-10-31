workspace(name = "sonic_mgmt_common")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_pkg",
    sha256 = "8f9ee2dc10c1ae514ee599a8b42ed99fa262b757058f65ad3c384289ff70c4b8",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.9.1/rules_pkg-0.9.1.tar.gz",
        "https://github.com/bazelbuild/rules_pkg/releases/download/0.9.1/rules_pkg-0.9.1.tar.gz",
    ],
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()

### Python
http_archive(
    name = "rules_python",
    sha256 = "a3a6e99f497be089f81ec082882e40246bfd435f52f4e82f37e89449b04573f6",
    strip_prefix = "rules_python-0.10.2",
    url = "https://github.com/bazelbuild/rules_python/archive/refs/tags/0.10.2.tar.gz",
)

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python3_8",
    # Available versions are listed in @rules_python//python:versions.bzl.
    # We recommend using the same version your team is already standardized on.
    python_version = "3.8",
)

load("@python3_8//:defs.bzl", "interpreter")
load("@rules_python//python:pip.bzl", "pip_install")

# Creates a central external repo, @pip, that contains Bazel targets for all the
# third-party packages specified in the requirements.txt file.
pip_install(
    name = "pip",
    python_interpreter_target = interpreter,
    requirements = "//third_party/pip:requirements.txt",
)

http_archive(
    name = "rules_foreign_cc",
    sha256 = "476303bd0f1b04cc311fc258f1708a5f6ef82d3091e53fd1977fa20383425a6a",
    strip_prefix = "rules_foreign_cc-0.10.1",
    url = "https://github.com/bazelbuild/rules_foreign_cc/releases/download/0.10.1/rules_foreign_cc-0.10.1.tar.gz",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies()

libyangBUILD = """
load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)

cmake(
    name = "libyang",
    lib_source = ":all_srcs",
    cache_entries = {
        # "CMAKE_INSTALL_PREFIX:PATH": ".",
    },
    # Using shared libs here.  When using static libs the libyang.a archive
    # contains undefined references to "extension" libraries which libyang
    # builds but does not install.  This results in linker errors later on
    # complaining that libyang.a does not define: nacm, metadata, yangdata,
    # user_yang_types, and user_inet_types.  These are all defined in .a
    # archives but are abandond in the libyang build directory when the
    # ENABLE_STATIC option is used.
    out_shared_libs = ["libyang.so", "libyang.so.1", "libyang.so.1.2.2"],
    deps = [
        "@pcre_archive//:pcre",
    ],
)
"""

http_archive(
    name = "com_github_cesnet_libyang",
    build_file_content = libyangBUILD,
    patch_args = ["-p1"],
    patches = [
        "//patches:libyang-repo.patch",
        "//patches:libyang.patch",
    ],
    #sha256 = "c4498a77a7c12a28c9911f993eeafbf2badd2ecea58bb74781bd61cfc635e4c9",
    #strip_prefix = "libyang-1.0.215",
    sha256 = "411f0c675b0858f8deabc0545e33fbd791ff7c7a5b7d2c27e347e3973d5b8ae4",
    strip_prefix = "libyang-1.0-r4",
    urls = [
        "https://github.com/CESNET/libyang/archive/refs/tags/v1.0-r4.tar.gz",
        #"https://github.com/CESNET/libyang/archive/refs/tags/v1.0.215.tar.gz",
    ],
)

pcreBUILD = """
load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "pcre_srcs",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)

cmake(
    name = "pcre",
    lib_source = ":pcre_srcs",
    working_directory = "pcre/",
    cache_entries = {
        "CMAKE_C_FLAGS": "-fPIC",
    },
    out_static_libs = [
        "libpcre.a",
        "libpcrecpp.a",
        "libpcreposix.a",
    ],
)
"""

http_archive(
    name = "pcre_archive",
    add_prefix = "pcre",
    build_file_content = pcreBUILD,
    sha256 = "4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8",
    strip_prefix = "pcre-8.45",
    urls = [
        "https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.bz2",
    ],
)

http_archive(
    name = "com_google_protobuf",
    sha256 = "b07772d38ab07e55eca4d50f4b53da2d998bb221575c60a4f81100242d4b4889",
    strip_prefix = "protobuf-3.20.0",
    urls = [
        "https://mirror.bazel.build/github.com/protocolbuffers/protobuf/archive/v3.20.0.tar.gz",
        "https://github.com/protocolbuffers/protobuf/archive/v3.20.0.tar.gz",
    ],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

buildimageBUILD = """
load("@rules_pkg//:pkg.bzl", "pkg_tar")
filegroup(
    name = "exported_yangs",
    srcs = glob(["src/sonic-yang-models/yang-models/*.yang"]),
    visibility = ["//visibility:public"],
)
filegroup(
    name = "exported_yang_templates",
    srcs = glob(["src/sonic-yang-models/yang-templates/*.yang.j2"]),
    visibility = ["//visibility:public"],
)
genrule(
    name = "yang-file-export",
    srcs = [
        ":exported_yangs",
        ":exported_yang_templates",
    ],
    outs = [
        "sonic-yangs-export.tar",
        "sonic-yang-templates-export.tar",
    ],
    cmd = "for f in $(locations :exported_yangs); do " +
          "  tar -r -f $(@D)/sonic-yangs-export.tar -C $$(dirname $$f) `basename $$f`;" +
          "done; " +
          "for f in $(locations :exported_yang_templates); do " +
          "  tar -r -f $(@D)/sonic-yang-templates-export.tar -C $$(dirname $$f) `basename $$f`;" +
          "done;",
    visibility = ["//visibility:public"],
)

pkg_tar(
    name = "sonic-cfggen",
    srcs = glob(["src/sonic-config-engine/*"]),
    mode = "0644",
    package_dir = "/sonic-config-engine",
    # strip_prefix = "/testdata",
    visibility = ["//visibility:public"],
)
"""

new_git_repository(
    name = "sonic-buildimage",
    branch = "master",
    build_file_content = buildimageBUILD,
    remote = "https://github.com/sonic-net/sonic-buildimage",
)

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "80a98277ad1311dacd837f9b16db62887702e9f1d1c4c9f796d0121a46c8e184",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.46.0/rules_go-v0.46.0.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.46.0/rules_go-v0.46.0.zip",
    ],
)

http_archive(
    name = "bazel_gazelle",
    integrity = "sha256-MpOL2hbmcABjA1R5Bj2dJMYO2o15/Uc5Vj9Q0zHLMgk=",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.35.0/bazel-gazelle-v0.35.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.35.0/bazel-gazelle-v0.35.0.tar.gz",
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

## Skylib rules
http_archive(
    name = "bazel_skylib",
    sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("//:deps.bzl", "go_dependencies")

# gazelle:repository_macro deps.bzl%go_dependencies
go_dependencies()

bazel_skylib_workspace()

go_rules_dependencies()

go_register_toolchains(version = "1.21.3")

gazelle_dependencies()
