// 将以下内容添加到你的 app/build.gradle.kts 文件中

android {
    lint {
        // 启用 lint 检查
        abortOnError = true
        warningsAsErrors = false
        checkDependencies = true
        checkGeneratedSources = false
        explainIssues = true
        
        // 忽略的文件和目录
        ignoreTestSources = true
        ignoreTestFixturesSources = true
        
        // 输出格式
        htmlReport = true
        htmlOutput = file("$buildDir/reports/lint/lint-results.html")
        xmlReport = true
        xmlOutput = file("$buildDir/reports/lint/lint-results.xml")
        
        // 使用配置文件
        lintConfig = file("../lint.xml")
        
        // 基线文件
        baseline = file("lint-baseline.xml")
    }
    
    // Ktlint 配置
    // 在项目根目录的 build.gradle.kts 添加：
    /*
    plugins {
        id("org.jlleitschuh.gradle.ktlint") version "11.6.1" apply false
    }
    */
    
    // 在 app/build.gradle.kts 添加：
    /*
    plugins {
        id("org.jlleitschuh.gradle.ktlint")
    }
    
    ktlint {
        version.set("0.50.0")
        debug.set(false)
        verbose.set(true)
        android.set(true)
        outputToConsole.set(true)
        outputColorName.set("RED")
        ignoreFailures.set(false)
        enableExperimentalRules.set(false)
        
        filter {
            exclude("**/generated/**")
            include("**/kotlin/**")
        }
    }
    */
}
