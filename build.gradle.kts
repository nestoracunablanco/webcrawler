plugins {
    kotlin("jvm") version "1.8.20"
    id("com.github.johnrengelman.shadow") version "8.1.1"
    application
}

group = "org.myapp.webcrawler"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

kotlin {
    jvmToolchain(17)
}

application {
    mainClass.set("MainKt")
}