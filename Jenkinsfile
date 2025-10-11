// Declarative Jenkins pipeline for building Custom-Fishing using the Gradle wrapper
pipeline {
    agent any

    tools {
        // Assumes Jenkins has a JDK installation named 'jdk21' configured in Global Tool Configuration
        // Adjust to 'jdk17' or 'jdk11' based on your Jenkins setup and project requirements
        jdk 'jdk21'
    }

    environment {
        // Use Gradle wrapper provided in the repo
        GRADLE_WRAPPER = './gradlew'
        // Set Git user for version banner functionality
        GIT_AUTHOR_NAME = 'Jenkins Build'
        GIT_AUTHOR_EMAIL = 'jenkins@build.local'
        GIT_COMMITTER_NAME = 'Jenkins Build'
        GIT_COMMITTER_EMAIL = 'jenkins@build.local'
        // Gradle options for CI
        GRADLE_OPTS = '-Dorg.gradle.daemon=false -Dorg.gradle.parallel=true -Dorg.gradle.configureondemand=true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                // Ensure git is configured for the version banner functions
                bat 'git config user.name "Jenkins Build" || echo "Git config already set"'
                bat 'git config user.email "jenkins@build.local" || echo "Git config already set"'
            }
        }

        stage('Validate') {
            steps {
                // Validate the Gradle wrapper and project structure
                bat "${env.GRADLE_WRAPPER} --version"
                bat "${env.GRADLE_WRAPPER} projects"
            }
        }

        stage('Clean') {
            steps {
                bat "${env.GRADLE_WRAPPER} clean"
            }
        }

        stage('Build') {
            steps {
                // Run build with all subprojects. Use --no-daemon for CI stability.
                bat "${env.GRADLE_WRAPPER} build --no-daemon --stacktrace"
            }
        }

        stage('Shadow JAR') {
            steps {
                // Build the shadow JAR which is typically the main deliverable
                bat "${env.GRADLE_WRAPPER} shadowJar --no-daemon"
            }
        }

        stage('Archive Artifacts') {
            steps {
                // Archive all JAR files and important build artifacts
                archiveArtifacts artifacts: '**/build/libs/*.jar', fingerprint: true, allowEmptyArchive: true
                
                // Archive configuration files and resources if needed
                archiveArtifacts artifacts: '**/src/main/resources/**/*.yml', fingerprint: false, allowEmptyArchive: true
                archiveArtifacts artifacts: '**/src/main/resources/**/*.properties', fingerprint: false, allowEmptyArchive: true
            }
        }

        stage('Publish') {
            when {
                // Only publish on main/master branch or release branches
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'release/*'
                }
            }
            steps {
                echo 'Publishing artifacts...'
                // Add your publish steps here (e.g., Maven, Nexus, etc.)
                // Example: bat "${env.GRADLE_WRAPPER} publish"
            }
        }
    }

    post {
        always {
            // Clean up workspace and stop any Gradle daemons
            echo 'Cleaning up...'
            bat "${env.GRADLE_WRAPPER} --stop || echo 'No Gradle daemons to stop'"
        }
        success {
            echo 'Custom-Fishing build succeeded!'
            // Add success notifications here (Slack, Discord, etc.)
        }
        failure {
            echo 'Custom-Fishing build failed!'
            // Add failure notifications here
        }
        unstable {
            echo 'Custom-Fishing build is unstable!'
        }
        changed {
            echo 'Custom-Fishing build status changed!'
        }
    }
}