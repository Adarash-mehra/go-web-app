pipeline {
    agent any
    environment {
        IMAGE_NAME = 'adarash08/my-go-app'
        CONFIG_REPO_URL = 'https://github.com/Adarash-mehra/go-web-app-config.git' 
        CONFIG_REPO_CRED_ID = 'gitea-pat-credentials'
        
        IMAGE_TAG = '' 
    }

    stages {
        stage('Fetch source code') {
            steps {
                git branch: 'main', url: 'https://github.com/Adarash-mehra/go-web-app'
            }
        }

        stage('Run Tests') {
            steps {
                sh """
                    go mod tidy
                    go test ./... -v
                """
            }
        }

        stage('Build Docker') {
            steps {
                script {
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    
                    if (commitHash == null || commitHash.isEmpty()) {
                        error "Failed to capture Git commit hash."
                    }
                    // set image tag
                    env.IMAGE_TAG = commitHash
                    echo "Image Tag: ${env.IMAGE_TAG}"

                    // Build the image
                    sh """
                        docker build -t ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${env.IMAGE_TAG} .
                    """
                }
            }
        }
        
        stage('Login & Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "Logging in to DockerHub"
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        echo "Pushing image: ${IMAGE_NAME}:${env.IMAGE_TAG}"
                        docker push ${IMAGE_NAME}:${env.IMAGE_TAG}
                        
                        echo "Pushing image: ${IMAGE_NAME}:latest"
                        docker push ${IMAGE_NAME}:latest

                        echo "Logout from DockerHub"
                        docker logout
                    """
                    }
                }
            }
        
        stage('Update Deployment Manifest') {
            steps {
                // Create/Enter the directory first
                dir('config-repo') {
                    
                    git branch: 'main', 
                        url: 'https://github.com/Adarash-mehra/go-web-app-config.git', 
                        credentialsId: 'gitea-pat-credentials'

                    withCredentials([usernamePassword(
                        credentialsId: 'gitea-pat-credentials', 
                        usernameVariable: 'GIT_USER', 
                        passwordVariable: 'GIT_PASS'
                    )]) {
                        sh """
                            # Configure Git identity
                            git config user.email "infoaadarshmehra@gmail.com"
                            git config user.name "Adarash-mehra"

                            echo "Updating Helm values.yaml image tag to ${env.IMAGE_TAG}..."
                            
                            # Run yq as root (-u 0)
                            docker run --rm -u 0 -v \$(pwd):/workdir \
                                mikefarah/yq:4 \
                                e ".image.tag = \\"${env.IMAGE_TAG}\\"" -i values.yaml

                            git add values.yaml
                            
                            if ! git diff --cached --quiet; then
                                git commit -m "Deploy: Update image tag to ${env.IMAGE_TAG}"
                                
                                
                                git push https://${GIT_USER}:${GIT_PASS}@github.com/Adarash-mehra/go-web-app-config.git main
                                
                                echo " Pushed new config to Git."
                            else
                                echo " No changes to values.yaml. Skipping commit."
                            fi
                        """
                    }
                }
            }
        }
    }
}