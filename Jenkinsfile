pipeline {
    agent any
     environment {
        IMAGE_NAME = 'adarash08/my-go-app'  // DockerHub repo name
    }

    stages {
        stage('Fetch source code') {
            steps {
                git branch: 'main', url: 'https://github.com/Adarash-mehra/go-web-app'
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    go mod tidy
                    go test ./... -v
                '''
            }
        }

        stage('Build Docker') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:latest .'
            }
        }
        stage('Login & Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "Logging in to DockerHub..."
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        echo "Pushing image to DockerHub..."
                        docker push ${IMAGE_NAME}:latest

                        echo "Logout from DockerHub..."
                        docker logout
                    '''
                    }
                }
            }
        }
    }
