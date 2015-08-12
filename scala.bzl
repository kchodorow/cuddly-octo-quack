# scala.bzl
def impl(ctx):
    ctx.action(
        command = "%s %s; echo 'blah' > %s" % (
            ctx.file._scalac.path, ctx.file.src.path, ctx.outputs.sh.path),
        outputs = [ctx.outputs.sh]
    )

scala_binary = rule(
    attrs = {
        'src': attr.label(
            allow_files=True,
            single_file=True),
        '_scalac': attr.label(
            default=Label("@scala//:bin/scalac"),
            executable=True,
            allow_files=True,
            single_file=True),
    },
    outputs = {'sh': "%{name}.sh"},
    implementation = impl,
)
