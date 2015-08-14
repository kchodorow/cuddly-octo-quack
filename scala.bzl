def impl(ctx):
    cmd = [
        "%s %s" % (ctx.file._scalac.path, ctx.file.src.path),
        "echo Manifest-Version: 1.0 > MANIFEST.MF",
        "echo Main-Class: %s >> MANIFEST.MF" % ctx.attr.main_class,
        "find . -name '*.class' -print > classes.list",
        "jar cfm %s MANIFEST.MF @classes.list" % (ctx.outputs.jar.path),
    ]

    ctx.action(
        inputs = [ctx.file.src],
        command = "\n".join(cmd),
        outputs = [ctx.outputs.jar]
    )

    cp = "%s:%s" % (ctx.outputs.jar.basename, ctx.file._scala_lib.path)
    content = [
        "#!/bin/bash",
        "echo zero is $0",
        "case \"$0\" in",
        "/*) self=\"$0\" ;;",
        "*)  self=\"$PWD/$0\";;",
        "esac",
        "(cd $self.runfiles; java -cp %s %s)" % (cp, ctx.attr.main_class),
    ]
    ctx.file_action(
        content = "\n".join(content),
        output = ctx.outputs.executable,
    )

    return struct(runfiles = ctx.runfiles(files = [ctx.outputs.jar, ctx.file._scala_lib]))

scala_binary = rule(
    attrs = {
        'src': attr.label(
            allow_files=True,
            single_file=True),
        'main_class' : attr.string(),
        '_scalac': attr.label(
            default=Label("@scala//:bin/scalac"),
            executable=True,
            allow_files=True,
            single_file=True),
        '_scala_lib': attr.label(
            default=Label("@scala//:lib/scala-library.jar"),
            allow_files=True,
            single_file=True),
    },
    outputs = {
        'jar': "%{name}.jar",
    },
    implementation = impl,
    executable = True,
)
