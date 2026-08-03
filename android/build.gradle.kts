allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.afterEvaluate {
        (project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension)?.apply {
            compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
