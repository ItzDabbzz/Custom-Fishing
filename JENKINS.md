Jenkins Setup for Custom-Fishing
================================

This document explains how to configure Jenkins to build the Custom-Fishing project using the provided `Jenkinsfile` (Declarative Pipeline).

Prerequisites
-------------
- A Jenkins server (2.401+ recommended) with Pipeline support
- Jenkins agents (Windows agent recommended for running `gradlew.bat`, or Linux agent with `./gradlew`)
- Git repository access (SSH or HTTPS)
- JDK 21 (or adjust the Jenkinsfile to use JDK 17/11 if preferred)

Jenkins Configuration
--------------------

### 1. Global Tool Configuration
Configure the following tools in Jenkins Global Tool Configuration:

**JDK Installation:**
- Name: `jdk21` (or adjust name in Jenkinsfile)
- Install automatically or provide JAVA_HOME path
- Version: OpenJDK 21 or equivalent

**Git:**
- Ensure Git is available on Jenkins agents
- Configure Git credentials if repository is private

### 2. Pipeline Job Setup

1. Create a new **Pipeline** job in Jenkins
2. In the job configuration:
   - **Source Code Management:** Git
     - Repository URL: Your Custom-Fishing repository URL
     - Credentials: Configure if repository is private
     - Branch Specifier: `*/main` (or your default branch)
   - **Build Triggers:** Configure as needed:
     - Poll SCM: `H/5 * * * *` (every 5 minutes)
     - GitHub hook trigger (if using GitHub)
     - Webhook triggers (recommended)
   - **Pipeline:**
     - Definition: Pipeline script from SCM
     - SCM: Git (same as above)
     - Script Path: `Jenkinsfile`

### 3. Webhook Configuration (Recommended)

For automatic builds on code changes:

**GitHub:**
1. Go to repository Settings → Webhooks
2. Add webhook with URL: `http://your-jenkins-url/github-webhook/`
3. Select "Just the push event"
4. Content type: `application/json`

**GitLab:**
1. Go to repository Settings → Webhooks
2. Add webhook with URL: `http://your-jenkins-url/project/YOUR_JOB_NAME`
3. Select "Push events" and "Merge request events"

Build Process
-------------

The Jenkins pipeline performs the following stages:

1. **Checkout:** Retrieves the source code from the repository
2. **Validate:** Verifies Gradle wrapper and project structure
3. **Clean:** Removes previous build artifacts
4. **Build:** Compiles all modules and runs tests
5. **Shadow JAR:** Creates the final plugin JAR with dependencies
6. **Archive Artifacts:** Stores build outputs for download
7. **Publish:** (Optional) Publishes to artifact repository

Build Artifacts
---------------

The following artifacts are archived after each build:
- `**/build/libs/*.jar` - All compiled JAR files
- Configuration files (`.yml`, `.properties`)

These can be downloaded from the Jenkins build page.

Environment Variables
--------------------

The pipeline sets the following environment variables:
- `GRADLE_WRAPPER`: Path to the Gradle wrapper script
- `GIT_AUTHOR_NAME`: Git author for version banner
- `GIT_AUTHOR_EMAIL`: Git email for version banner

Customization
-------------

### Changing JDK Version
Edit the `tools` section in Jenkinsfile:
```groovy
tools {
    jdk 'jdk17'  // Change to your configured JDK name
}
```

### Adding Notifications
Add notification steps in the `post` section:
```groovy
post {
    success {
        // Slack notification
        slackSend(channel: '#builds', color: 'good', message: "Custom-Fishing build succeeded!")
    }
    failure {
        // Email notification
        emailext(to: 'dev-team@example.com', subject: 'Build Failed', body: 'Custom-Fishing build failed!')
    }
}
```

### Publishing Artifacts
Uncomment and configure the publish steps in the `Publish` stage:
```groovy
stage('Publish') {
    steps {
        bat "${env.GRADLE_WRAPPER} publish"
    }
}
```

Troubleshooting
---------------

**Common Issues:**

1. **Git not found:**
   - Ensure Git is installed on Jenkins agents
   - Add Git to PATH environment variable

2. **JDK not found:**
   - Verify JDK is configured in Global Tool Configuration
   - Check JDK name matches the one in Jenkinsfile

3. **Gradle wrapper permissions (Linux):**
   - Ensure `gradlew` has execute permissions
   - Add `chmod +x gradlew` to checkout stage if needed

4. **Build failures:**
   - Check console output for detailed error messages
   - Verify all dependencies are available
   - Ensure proper network access for dependency downloads

5. **Git version banner issues:**
   - Git user configuration is handled automatically in the pipeline
   - Ensure git repository has at least one commit

Monitoring
----------

Monitor your builds through:
- Jenkins dashboard
- Email notifications (configure in Jenkins)
- Slack/Discord webhooks
- Build status badges in README

For more advanced monitoring, consider integrating with:
- SonarQube for code quality
- JaCoCo for test coverage
- Dependency-Check for security vulnerabilities