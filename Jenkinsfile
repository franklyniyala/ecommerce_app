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

        stage('Build Frontend Image') {
            steps {
                dir('frontend') {
                    sh 'docker build -t ekenefranklyn/ecommerce-frontend-image:v1 .' 
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                dir('backend') {
                    sh 'docker build -t ekenefranklyn/ecommerce-backend-image:v1 .'
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_LOGIN', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                }
            }
        }

        stage('Push Images to DockerHub') {
            steps {
                sh 'docker push ekenefranklyn/ecommerce-frontend-image:v1'
                sh 'docker push ekenefranklyn/ecommerce-backend-image:v1'
            }
        }

        stage('Deploy Application') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'e0456e22-5995-4d0d-bb22-0347a780ca52',
                usernameVariable: 'MONGO_INITDB_ROOT_USERNAME', passwordVariable:
                'MONGO_INITDB_ROOT_PASSWORD')]) {
                    withEnv(['MONGO_INITDB_DATABASE=ecommerce']) {
                        sh 'docker compose -f docker-compose.yml up -d'
                    }
                    
                }   
                
            }
        }
    }

    post {
        success {
            echo '✅ SonarQube analysis completed successfully.'
            echo '✅ Pipeline executed successfully. Application deployed 🚀.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
