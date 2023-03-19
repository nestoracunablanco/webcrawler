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

```
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
