import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.options.flag
import com.github.ajalt.clikt.parameters.options.option
import org.openqa.selenium.By
import org.openqa.selenium.chrome.ChromeDriver
import org.openqa.selenium.chrome.ChromeOptions

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