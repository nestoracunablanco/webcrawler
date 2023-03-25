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


### Step Five: configure IBM Cloud Code Engine

If you do not have an account at [IBM Cloud](https://cloud.ibm.com/), it is the time to create one. Through the
following [link](https://cloud.ibm.com/codeengine/overview) you can see that there are two options, either specify an
image, or a repository. In our case the preferred option is an image that we can upload to IBM Cloud whenever we want.
This way we can replicate the same status locally, as in the cloud.

![IBM Cloud: Container vs Source](doc/img/IBM-cloud-container-vs-source.png?raw=true "IBM Cloud: Container vs Source")

By clicking on [Start Creating](https://cloud.ibm.com/codeengine/create/start)  we can select between creating an
application or a job. The difference between both is basically that the application is intended to serve HTTP requests
and the job is intended to execute a task.

![IBM Cloud: Application vs Job](doc/img/IBM-cloud-application-vs-job.png?raw=true "IBM Cloud: Application vs Job")

As name, we can write webcrawler and clicking on create project we can define the location, the name of the project,
resources and tags. For the moment we will focus only on the first two. As location, it is advisable to choose the
nearest one and as name we can write "webcrawler".

![IBM Cloud: Create Project](doc/img/IBM-cloud-create-project.png?raw=true "IBM Cloud: Create Project")

After clicking on "create project" we can configure the image to be executed. For the moment we can leave the
HelloWorld example.

![IBM Cloud: HelloWorld Container](doc/img/IBM-cloud-hello-world-container.png?raw=true "IBM Cloud: HelloWorld Container")

The rest of the options can be left as default and click on "create". On the next page we can leave the default settings
and click on "submit job". In the next menu we can leave the default settings.

![IBM Cloud: Submit Job](doc/img/IBM-cloud-submit-job.png?raw=true "IBM Cloud: Submit Job")

If everything worked correctly, the job will appear as completed.

![IBM Cloud: Job Completed](doc/img/IBM-cloud-job-completed.png?raw=true "IBM Cloud: Job Completed")

For more detailed information, please visit the
[official documentation](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Step Six: create container registry

The next step is to create a container registry, in which we can save our container images. To do this we start by
searching for `Container Registry` in the IBM Cloud search bar.

![IBM Cloud: Search Container Registry](doc/img/IBM-cloud-search-container-registry.png?raw=true "IBM Cloud: Search Container Registry")

After clicking, we enter a product information page. In it we see the limitations of the lite version. At the time of
writing, the limit is 0.5 GB of storage, which is sufficient for our purposes.

After clicking on "Get Started", we find a page that tells us how we can upload our images to the registry. To download
IBM Cloud CLI with the necessary plugins, these two commands are sufficient:

```bash
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
ibmcloud plugin install -f container-registry
```

Once we have the software installed, we can try to upload the image generated in step 4 using the following commands (in
the case of Central Europe region)

```bash
ibmcloud login
ibmcloud cr region-set eu-central
ibmcloud cr namespace-add webcrawler
docker tag webcrawler:latest de.icr.io/webcrawler/webcrawler:latest
ibmcloud cr login
docker push de.icr.io/webcrawler/webcrawler:latest
```

Now if you search inside the namespace in the container registry you can find the image.

![IBM Cloud: Container Registry Namespace](doc/img/IBM-cloud-container-registry-namespace.png?raw=true "IBM Cloud: Container Registry Namespace")

Due to the 512MB space limitation, it is important to retain only the most recent image. This is achieved by going into
settings and selecting the `Retain only the most recent images in each repository` option, as well as disabling `Retain
untagged images`. Finally, select `Set recurring policy.

![IBM Cloud: Image Retention](doc/img/IBM-cloud-image-retention.png?raw=true "IBM Cloud: Image Retention")

For more information, you can consult the [official documentation](https://cloud.ibm.com/docs/Registry).


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
* [IBM Cloud Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)
* [IBM Cloud Container Registry](https://cloud.ibm.com/docs/Registry)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[kotlinlang.org]: https://img.shields.io/badge/-Kotlin-61DAFB?style=for-the-badge&logo=kotlin
[Kotlin-url]: https://kotlinlang.org/
[gradle.org]: https://img.shields.io/badge/-Gradle-4A4A55?style=for-the-badge&logo=gradle
[Gradle-url]: https://gradle.org/
