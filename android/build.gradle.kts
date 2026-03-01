// 1. Sabse pehle buildscript block aayega
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // FIXED: Classpath hamesha yahan buildscript ke andar rehta hai
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Yahan se dependencies block delete kar diya gaya hai (galat tha)
}

// 2. Aapka purana build directory logic
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}