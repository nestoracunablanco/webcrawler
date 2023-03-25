<a name="readme-top"></a>

# WEB CRAWLER WITH SELENIUM AND KOTLIN IN IBM CLOUD CODE ENGINE

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#steps">Steps</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This project explains step by step how to create a webcrawler with Kotlin and run it as a Job in IBM Cloud Code Engine.  
IBM Cloud Code Engine offers the ability to run jobs, in other words, software that is meant to run and finish
relatively quickly. Applications, on the other hand, are meant to accept HTTP requests. For more information visit
https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started

The job must comply the following:
* Linting rules
* Static code analysis
* Automatic deployment
* Cloud readiness

Each step will be described in detail in this README.  



<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

This section should list any major frameworks/libraries used to bootstrap your project. Leave any add-ons/plugins for the acknowledgements section. Here are a few examples.

* [![Kotlin][kotlinlang.org]][Kotlin-url]
* [![Gradle][gradle.org]][Gradle-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Clone the repo and build it using gradle

### Prerequisites

You need a JVM installed and we recommend IntelliJ IDEA as development environment


### Installation

No special requirements needed for now.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Just run the application using ```./gradlew run```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Steps

### Step One: create a hello world app using IntelliJ IDEA

Select new project and configure it with the following parameters:
- Language: Kotlin
- Build system: Gradle
- JDK: version 17
- Gradle DSL: Kotlin
- Add sample code

![IntelliJ Config](doc/img/IntelliJ-config.png?raw=true "IntelliJ Config")

This will create a file called "Main.kt" with the following content:  

```kotlin
fun main(args: Array<String>) {
    println("Hello World!")

    // Try adding program arguments via Run/Debug configuration.
    // Learn more about running applications: https://www.jetbrains.com/help/idea/running-applications.html.
    println("Program arguments: ${args.joinToString()}")
}
```

If the execution of ```./gradlew run``` finishes without problems, you can proceed to the next step. Otherwise, you can
check the following:
- JVM version
- Latest gradle version
- SDK in IntelliJ project


### Step Two: create a fatJar using shadow plugin

Please follow the following [link](https://imperceptiblethoughts.com/shadow/getting-started). Once the dependencies have
been downloaded, a new task ```./gradlew shadowJar``` should exist. Once executed, two jars can be found in
```build/libs```. We are interested in the one that ends with ```all.jar```, since that is the one that has all its
dependencies integrated.

In order to test if it works, run the command ```java -jar filename-all.jar``` inside ```build/libs```.


### Step Three: check the fatJar creation with GitHub Actions

The recommended option to set up a ci quickly is to use GitHub Actions. Based on a configuration in YAML format we can
define actions that will be executed, for example after any push. For more information, please visit the following
[link](https://docs.github.com/en/actions).  

We can include a file with the following content inside the directory ```.github/workflows/push.yml```:

```yaml
name: Push Workflow
on:
  push:
    branches-ignore:
      - main
jobs:
  Push-Actions:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v3
      - name: Build jar
        uses: gradle/gradle-build-action@v2
        with:
          arguments: shadowJar
```

This ensures that every time a developer pushes changes, this check will be executed.  


### Step Four: create a Dockerfile

To save time and headaches later on, it is recommended that the application be cloud-ready from the beginning of
development. One of the most effective ways to achieve this is to constantly maintain and test a Dockerfile. With this
we achieve the following:
1. Control over the environment in which the application is executed.
2. Being able to reproduce the problems on your local machine.
3. Possibility to upload that image to a container registry through a ci/cd pipeline.

In our case we use the ubi9/openjdk-17 image provided by Red Hat. This decision is based on two criteria:
1. constant maintenance by Red Hat.
2. Simple usage: we need to copy the jar file to `/deployments` and we do not need additional parameters for our program
to run.

The Dockerfile description:
```dockerfile
FROM registry.access.redhat.com/ubi9/openjdk-17:1.14-2

RUN mkdir app
WORKDIR app
COPY --chown=default . .
RUN ./gradlew shadowJar
RUN cp build/libs/webcrawler*-all.jar /deployments
```

Build command: `docker build . -t webcrawler:latest`  
Run command: `docker run --rm webcrawler:latest`  

With this we can even update our pipeline and make building the Dockerfile and execution part of it.  
```yaml
name: Push Workflow
on:
  push:
    branches-ignore:
      - main
jobs:
  Push-Actions:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v3
      - name: Build jar
        uses: gradle/gradle-build-action@v2
        with:
          arguments: shadowJar
      - name: Build docker image
        uses: docker/build-push-action@v4
        with:
          tags: webcrawler:latest
      - name: Run the software
        run: docker run webcrawler:latest
```


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Nestor Acuña Blanco - nacuna85@gmail.com

Project Link: [https://github.com/nestoracunablanco/webcrawler](https://github.com/nestoracunablanco/webcrawler)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [Choose an Open Source License](https://choosealicense.com)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [IntelliJ IDEA](https://www.jetbrains.com/help/idea/getting-started.html)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[kotlinlang.org]: https://img.shields.io/badge/-Kotlin-61DAFB?style=for-the-badge&logo=kotlin
[Kotlin-url]: https://kotlinlang.org/
[gradle.org]: https://img.shields.io/badge/-Gradle-4A4A55?style=for-the-badge&logo=gradle
[Gradle-url]: https://gradle.org/
