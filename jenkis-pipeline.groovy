pipeline {
    agent any
    
    tools {
        jdk 'Java17'
    }
    stages {
        stage('Checkout Source') {
            steps {
                git branch: 'main', url: 'https://github.com/Victor-Afonso/first-project'
            }
        }
        stage('Build') {
            steps {
                sh 'chmod +x ./mvnw'
                sh './mvnw compile quarkus:build'
            }
        }
        stage('Test'){
            steps {
                sh 'chmod +x ./mvnw'
                sh './mvnw test'
                junit '**/target/surefire-reports/TEST-*.xml'
            }
        }
        stage('Install Helm') {
            steps {
                git url: 'https://github.com/helm/helm.git'
                sh 'cd helm && make'
            }
        }
        stage('Deploy') {
            steps {
                sh 'helm upgrade --install quarkus-api ./my-api-chart'
            }
        }
    }
}