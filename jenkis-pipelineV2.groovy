pipeline {
    agent any
    environment {
        KUBECONFIG = credentials('kubeconfig')
        IMAGE_TAG = "${env.BUILD_ID}-${env.BUILD_NUMBER}"
        DOCKER_USERNAME = credentials('DOCKERHUB_USERNAME')
        DOCKER_TOKEN = credentials('DOCKERHUB_TOKEN')
    }
    stages {
        stage('Checkout Source') {
            steps {
                bat '''
                    IF NOT EXIST first-project (
                        git clone https://github.com/Victor-Afonso/first-project.git
                    ) ELSE (
                        cd first-project && git pull
                    )
                '''
            }
        }
        stage('Api Build') {
            steps {
                bat '''
                    cd first-project
                    mvn package
                '''
            }
        }
        stage('SonarQube') {
            steps{
                bat '''
                    cd first-project
                    mvn compile sonar:sonar
                '''
            }
        }
        stage('Docker'){
            steps {
                    bat '''
                        docker login -u %DOCKERHUB_USERNAME% -p %DOCKERHUB_TOKEN%
                        cd first-project
                        docker build -f src/main/docker/Dockerfile.jvm -t victorafonso512/first-project-jvm:%IMAGE_TAG% .
                        docker push victorafonso512/first-project-jvm:%IMAGE_TAG%
                    '''
                }
        }
        stage('Deploy') {
            steps {
                script {
                    def imageTag = env.IMAGE_TAG
                    bat '''
                        IF NOT EXIST api-chart (
                            git clone https://github.com/Victor-Afonso/api-chart.git
                        ) ELSE (
                            cd api-chart && git pull
                        )
                        dir
                        cd..
                        helm upgrade --install quarkus-api api-chart --set image.tag=%IMAGE_TAG%
                    '''
                }
            }
        }
    }
}
