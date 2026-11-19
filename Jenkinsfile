pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/franklyniyala/ecommerce_app.git'
            }
        }

        stage('Sonarqube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    sh '''
                    docker run --rm \
                    -e SONAR_TOKEN=${SONAR_TOKEN} \
                    -v $(pwd):/usr/src \
                    sonarsource/sonar-scanner-cli \
                    -Dsonar.projectKey=frank-org_ecommerce-app \
                    -Dsonar.organization=frank-org \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=https://sonarcloud.io \
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ SonarQube analysis completed successfully.'
        }
        failure {
            echo '❌ SonarQube analysis failed. Check logs for details.'
        }
    }
}
