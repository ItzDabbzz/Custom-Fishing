pipeline {
    agent any
    
    tools {
        // Make sure Jenkins has JDK configured with this name
        jdk 'jdk21'        // Adjust this to match your Jenkins JDK 21 installation name
    }
    
    environment {
        // Use Gradle wrapper provided in the repo
        GRADLE_WRAPPER = './gradlew'
        // Set Gradle options for CI
        GRADLE_OPTS = '-Xmx1024m -Xms512m -Dorg.gradle.daemon=false -Dorg.gradle.parallel=true -Dorg.gradle.configureondemand=true'
        // Set Git user for version banner functionality
        GIT_AUTHOR_NAME = 'Jenkins Build'
        GIT_AUTHOR_EMAIL = 'jenkins@build.local'
        GIT_COMMITTER_NAME = 'Jenkins Build'
        GIT_COMMITTER_EMAIL = 'jenkins@build.local'
    }
    
    options {
        // Keep builds for 30 days
        buildDiscarder(logRotator(daysToKeepStr: '30', numToKeepStr: '50'))
        // Timeout after 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        // Add timestamps to console output
        timestamps()
    }
    
    triggers {
        // Poll SCM every 5 minutes for changes (adjust as needed)
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
                // Ensure git is configured for the version banner functions
                script {
                    if (isUnix()) {
                        sh 'git config user.name "Jenkins Build" || echo "Git config already set"'
                        sh 'git config user.email "jenkins@build.local" || echo "Git config already set"'
                    } else {
                        bat 'git config user.name "Jenkins Build" || echo "Git config already set"'
                        bat 'git config user.email "jenkins@build.local" || echo "Git config already set"'
                    }
                }
            }
        }
        
        stage('Build Info') {
            steps {
                script {
                    echo "Building branch: ${env.BRANCH_NAME}"
                    echo "Build number: ${env.BUILD_NUMBER}"
                    echo "Java version check:"
                    if (isUnix()) {
                        sh 'java -version'
                        echo "Gradle version check:"
                        sh "${env.GRADLE_WRAPPER} --version"
                    } else {
                        bat 'java -version'
                        echo "Gradle version check:"
                        bat "${env.GRADLE_WRAPPER} --version"
                    }
                }
            }
        }
        
        stage('Clean') {
            steps {
                echo 'Cleaning previous builds...'
                script {
                    if (isUnix()) {
                        sh "${env.GRADLE_WRAPPER} clean"
                    } else {
                        bat "${env.GRADLE_WRAPPER} clean"
                    }
                }
            }
        }
        
        stage('Compile') {
            steps {
                echo 'Compiling the project...'
                script {
                    if (isUnix()) {
                        sh "${env.GRADLE_WRAPPER} compileJava"
                    } else {
                        bat "${env.GRADLE_WRAPPER} compileJava"
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building the project...'
                script {
                    if (isUnix()) {
                        sh "${env.GRADLE_WRAPPER} build --no-daemon --stacktrace"
                    } else {
                        bat "${env.GRADLE_WRAPPER} build --no-daemon --stacktrace"
                    }
                }
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the project...'
                script {
                    if (isUnix()) {
                        sh "${env.GRADLE_WRAPPER} shadowJar --no-daemon"
                        echo 'Final plugin JAR info:'
                        sh 'ls -lh target/*.jar || true'
                        sh 'echo Final JAR location: target/'
                    } else {
                        bat "${env.GRADLE_WRAPPER} shadowJar --no-daemon"
                        echo 'Final plugin JAR info:'
                        bat 'dir target\\*.jar'
                        bat 'echo Final JAR location: target\\'
                    }
                }
            }
        }
        
        stage('Install') {
            when {
                anyOf {
                    branch 'master'
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                echo 'Installing to local repository...'
                script {
                    if (isUnix()) {
                        sh "${env.GRADLE_WRAPPER} publishToMavenLocal"
                    } else {
                        bat "${env.GRADLE_WRAPPER} publishToMavenLocal"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            // Archive the final plugin JAR (main artifact)
            archiveArtifacts artifacts: 'target/*.jar', 
                           fingerprint: true, 
                           allowEmptyArchive: false
            
            // Archive the resource pack if it exists
            archiveArtifacts artifacts: 'Resource Pack for games.zip', 
                           fingerprint: false, 
                           allowEmptyArchive: true
            
            // Stop any Gradle daemons
            script {
                try {
                    if (isUnix()) {
                        sh "${env.GRADLE_WRAPPER} --stop"
                    } else {
                        bat "${env.GRADLE_WRAPPER} --stop"
                    }
                } catch (Exception e) {
                    echo 'No Gradle daemons to stop'
                }
            }
        }
        
        success {
            echo 'Build completed successfully!'
            script {
                if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'main') {
                    echo 'Master/Main branch build succeeded - artifacts are ready for deployment'
                }
            }
        }
        
        failure {
            echo 'Build failed!'
            // You can add notification steps here (email, Slack, etc.)
        }
        
        unstable {
            echo 'Build completed with test failures'
        }
        
        cleanup {
            // Clean up workspace if needed
            deleteDir()
        }
    }
}