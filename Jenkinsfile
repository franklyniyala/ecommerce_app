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
                withCredentials([strings(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    sh '''
                    docker run --rm \
                    -e SONAR_TOKEN=${SONAR_TOKEN} \
                    -v $(pwd):/usr/src \
                    sonarsource/sonar-scanner-cli \
                    -Dsonar.projectKey=frank-org_ecommerce-app \
                    -Dsonar.organization=frank_org \
                    -Dsonar.sources=. \
                    -sonar.host.url=https://sonarcloud.io \
                    '''
                }
            }
        }
    }
}