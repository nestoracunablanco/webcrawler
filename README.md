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


### Step Seven: multi-stage docker image
To keep the image size as small as possible, we can use multi-stage builds. An example would be:

```dockerfile
FROM registry.access.redhat.com/ubi9/openjdk-17:1.14-2 as builder

RUN mkdir app
WORKDIR app
COPY --chown=default . .
RUN ./gradlew shadowJar

FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.14-2

COPY --from=builder --chown=default /home/default/app/build/libs/*-all.jar /deployments
```

To build and upload the image to ibmcloud we can take inspiration from the steps above.  

For more information you can visit the
[official Docker documentation](https://docs.docker.com/build/building/multi-stage/)


### Step eight: automatic deployment to IBM Cloud Container registry
First, we need to create an API key to authorize a connection from GitHub Actions. In this
[link](https://cloud.ibm.com/iam/apikeys) you will find the button to create it.  

![IBM Cloud: Create API Key](doc/img/IBM-cloud-create-API-key.png?raw=true "IBM Cloud: Create API Key")

After creation, you have the opportunity to copy it and enter it as a secret in the repository settings on GitHub. In
Settings: `Secrets and Variables->Actions`, by clicking on the `New repository secret` button, we must add two variables:
`IBM_CLOUD_API_KEY` and `IBM_CLOUD_REGION`.  

![GitHub: Actions secrets](doc/img/GitHub-actions-secrets.png?raw=true "GitHub: Actions secrets")

In the tab next to `Secrets` we can also define variables. In our case, we define `CONTAINER_NAME`.  

![GitHub: Actions variables](doc/img/GitHub-actions-variables.png?raw=true "GitHub: Actions variables")  

After that, we are ready to add a new workflow for deployment, here is an example:  

```yaml
name: Deploy Workflow
on:
  push:
    branches:
      - main
jobs:
  Deploy-Actions:
    runs-on: ubuntu-latest
    steps:
      - name: Install IBM Cloud CLI
        run: |
          curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
          ibmcloud --version
          ibmcloud config --check-version=false
          ibmcloud plugin install -f container-registry
      - name: Authenticate with IBM Cloud CLI
        run: |
          ibmcloud login --apikey ${{ secrets.IBM_CLOUD_API_KEY }} -r ${{ secrets.IBM_CLOUD_REGION }}
          ibmcloud cr login --client docker
      - name: Build and push docker image
        uses: docker/build-push-action@v4
        with:
          tags: ${{ vars.CONTAINER_NAME }}
          push: true
      - name: Delete untagged images
        run : |
          ibmcloud cr image-prune-untagged -f
```

The code shows that we first download the IBM Cloud CLI, then install the dependencies, log in using the previously
defined secrets, build and upload the image to the registry and finally delete the previous images. This action will be
executed whenever there is a change in the `main` branch.

For more information you can visit the following links:  
* [Creating an API Key in IBM Cloud](https://www.ibm.com/docs/en/app-connect/containers_cd?topic=servers-creating-cloud-api-key)  
* [GitHub encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)


### Step nine: Configure automatic updates with dependabot

On GitHub we can configure dependabot to keep our packages up to date. In our case we need to keep up-to-date packages
in gradle, docker and github-actions. The configuration is very simple, defining the file `dependabot.yml` in the
`.github` directory.

```yaml
version: 2
updates:
  # Maintain dependencies for GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"

  # Maintain dependencies for gradle
  - package-ecosystem: "gradle"
    directory: "/"
    schedule:
      interval: "weekly"

  # Maintain dependencies for docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
```

More information and possibilities by following this [link](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file).


### Step ten: Selenium Hello World

First we have to install `chromium` and `chromedriver` on the Dockerfile. Part of the dependencies are in the
EPEL and CentOS Stream repositories. Here the code of the second part of the Dockerfile:

```dockerfile
ENV HEADLESS=TRUE
ARG packages="chromium chromedriver"

# Installs the os dependencies (chromium and chromedriver)
USER root
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
      && rpm -ivh https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-20.el9.noarch.rpm\
      && rpm -ivh https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-20.el9.noarch.rpm\
      && microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs install -y $packages \
      && microdnf clean all \
      && rpm -q $packages

# Copies the jar from the build container
USER default
COPY --from=builder --chown=default /home/default/app/build/libs/*-all.jar /deployments
```

Next we need to make sure that on our development machine we also have those dependencies installed, along with the
libraries specified in our gradle file:

```kotlin
dependencies {
    implementation("org.seleniumhq.selenium:selenium-java:4.8.3")
    implementation("com.github.ajalt.clikt:clikt:3.5.2")
    testImplementation(kotlin("test"))
}
```

A code to execute a simple selenium hello world would be the following:

```kotlin
val chromeOptions = ChromeOptions()
if (headless) {
    chromeOptions.addArguments(listOf("--headless", "--no-sandbox", "--disable-dev-shm-usage"))
}
val driver = ChromeDriver(chromeOptions)
driver.get("https://www.learn-html.org/en/Hello,_World!")
val element = driver.findElement(By.cssSelector("div#inner-text h1"))
println(element.text)
driver.close()
```

This code is based on the information in this
[link](https://reflect.run/articles/how-to-run-selenium-tests-inside-a-docker-container/). Basically in order to run
selenium inside a container we need to run it with the following arguments:
* no-sandbox
* headless
* disable-dev-shm-usage

To distinguish between execution in docker container and development machine we define a "headless" flag, which depends
on an environment variable. For this purpose we use the [Clikt](https://ajalt.github.io/clikt/) library. A complete code
example (without imports) would be the following:

```kotlin
class WebCrawler : CliktCommand() {

    private val headless: Boolean
            by option("--headless", help = "This flag sets the headless mode on", envvar = "HEADLESS")
                .flag()
    override fun run() {
        val chromeOptions = ChromeOptions()
        if (headless) {
            chromeOptions.addArguments(listOf("--headless", "--no-sandbox", "--disable-dev-shm-usage"))
        }
        val driver = ChromeDriver(chromeOptions)
        driver.get("https://www.learn-html.org/en/Hello,_World!")
        val element = driver.findElement(By.cssSelector("div#inner-text h1"))
        println(element.text)
        driver.close()
    }

}

fun main(args: Array<String>) = WebCrawler().main(args)
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

Use this space to list resources you find helpful and would like to give credit to.

* [Choose an Open Source License](https://choosealicense.com)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [IntelliJ IDEA](https://www.jetbrains.com/help/idea/getting-started.html)
* [IBM Cloud Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)
* [IBM Cloud Container Registry](https://cloud.ibm.com/docs/Registry)
* [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
* [Creating an API Key in IBM Cloud](https://www.ibm.com/docs/en/app-connect/containers_cd?topic=servers-creating-cloud-api-key)
* [GitHub encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
* [Dependabot](https://docs.github.com/en/code-security/dependabot)
* [Selenium inside Docker](https://reflect.run/articles/how-to-run-selenium-tests-inside-a-docker-container/)


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[kotlinlang.org]: https://img.shields.io/badge/-Kotlin-61DAFB?style=for-the-badge&logo=kotlin
[Kotlin-url]: https://kotlinlang.org/
[gradle.org]: https://img.shields.io/badge/-Gradle-4A4A55?style=for-the-badge&logo=gradle
[Gradle-url]: https://gradle.org/
