from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
from distutils.command.build_ext import build_ext
from distutils.sysconfig import customize_compiler


class BuildExt(build_ext):
    def build_extensions(self):
        customize_compiler(self.compiler)
        for args in ["-Wstrict-prototypes"]:
            try:
                self.compiler.compiler_so.remove(args)
            except (AttributeError, ValueError):
                pass
        build_ext.build_extensions(self)


extensions = [
    Extension("cy_aho_corasick", ["cy_aho_corasick.pyx"],
              include_dirs=["./src"],
              libraries=[],
              library_dirs=[],
              language="c++",
              extra_compile_args=['-std=c++11', '-Ofast', '-march=native', '-fno-wrapv'])
]

setup(
    name="cy_aho_corasick",
    ext_modules=cythonize(extensions),
    cmdclass={'build_ext': BuildExt}
)
