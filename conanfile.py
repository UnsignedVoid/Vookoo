from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps

class VookooRecipe(ConanFile):
    name = "vookoo"
    version = 0.1
    
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False], "build_examples":[True, False]}
    default_options = {"shared": False, "fPIC": True, "build_examples": False}

    exports_sources = "CMakeLists.txt", "src/*", "include/*", "external/*", "examples/*", "Config.cmake.in"

    def requirements(self):
        self.requires("vulkan-headers/1.3.239.0")
        self.requires("vulkan-loader/1.3.239.0")
        if self.options.build_examples:
            self.requires("glfw/3.3.8")
#            self.requires("spirv-tools/v2020.5")

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def layout(self):
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()

        tc = CMakeToolchain(self)

        print("BUILD EXAMPLES? ", self.options.build_examples)
        if self.options.build_examples:
            tc.variables["VOOKOO_BUILD_EXAMPLES"] = True

        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()
