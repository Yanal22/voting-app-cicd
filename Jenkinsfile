pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_TAG = "${BUILD_NUMBER}"
        VOTE_IMAGE = "yanal2002/voting-vote"
        WORKER_IMAGE = "yanal2002/voting-worker"
        RESULT_IMAGE = "yanal2002/voting-result"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    echo 'Building Docker images...'
                    sh """
                        docker build -t ${VOTE_IMAGE}:${IMAGE_TAG} -t ${VOTE_IMAGE}:latest ./vote
                        docker build -t ${WORKER_IMAGE}:${IMAGE_TAG} -t ${WORKER_IMAGE}:latest ./worker
                        docker build -t ${RESULT_IMAGE}:${IMAGE_TAG} -t ${RESULT_IMAGE}:latest ./result
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Logging into Docker Hub...'
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    
                    echo 'Pushing images...'
                    sh """
                        docker push ${VOTE_IMAGE}:${IMAGE_TAG}
                        docker push ${VOTE_IMAGE}:latest
                        docker push ${WORKER_IMAGE}:${IMAGE_TAG}
                        docker push ${WORKER_IMAGE}:latest
                        docker push ${RESULT_IMAGE}:${IMAGE_TAG}
                        docker push ${RESULT_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'
                    sh """
                        kubectl rollout restart deployment/vote -n voting-app
                        kubectl rollout restart deployment/worker -n voting-app
                        kubectl rollout restart deployment/result -n voting-app
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
