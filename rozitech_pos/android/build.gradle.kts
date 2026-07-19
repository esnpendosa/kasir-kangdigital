allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (project.name != "app") {
        project.plugins.withId("com.android.library") {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val method = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    method.invoke(android, 36)
                } catch (e: Exception) {
                    try {
                        val method = android.javaClass.getMethod("compileSdkVersion", Object::class.java)
                        method.invoke(android, 36)
                    } catch (ex: Exception) {}
                }
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(android)
                    if (currentNamespace == null || (currentNamespace as String).isEmpty()) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespace.invoke(android, "com.kangdigital.kasir_umkm.${project.name.replace("-", "_").replace(".", "_")}")
                    }
                } catch (e: Exception) {
                    try {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespace.invoke(android, "com.kangdigital.kasir_umkm.${project.name.replace("-", "_").replace(".", "_")}")
                    } catch (ex: Exception) {}
                }
            }
        }
    }
}

subprojects {
    val manifestFile = File(project.projectDir, "src/main/AndroidManifest.xml")
    if (manifestFile.exists()) {
        try {
            val content = manifestFile.readText()
            if (content.contains("package=\"")) {
                val updated = content.replace(Regex("""\bpackage="[^"]*""""), "")
                manifestFile.writeText(updated)
                logger.quiet("Removed package attribute from manifest of ${project.name}")
            }
        } catch (e: Exception) {
            logger.quiet("Failed to patch manifest of ${project.name}: ${e.message}")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
