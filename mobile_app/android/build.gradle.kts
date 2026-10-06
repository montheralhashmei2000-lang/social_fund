allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep Flutter's expected output location: <project>/build/<module>.
rootProject.layout.buildDirectory.set(rootProject.layout.projectDirectory.dir("../build"))

subprojects {
    layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(name))
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}