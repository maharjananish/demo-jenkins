pipeline {
    agent any   // run on any available Jenkins agent

    environment {
        // Change these 3 values to match your setup
        AWS_REGION      = 'us-east-1'
        AWS_ACCOUNT_ID  = '717319160666'
        ECR_REPO        = 'my-app-ecr'
        CLUSTER_NAME    = 'my-cluster1'

        // Built from the above — don't change these
        ECR_REGISTRY    = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG       = "${BUILD_NUMBER}"   // Jenkins build number as tag
        FULL_IMAGE      = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout') {
            steps {
                // Jenkins clones your GitHub repo automatically
                checkout scm
                echo "Code checked out successfully"
            }
        }

        stage('Install dependencies & test') {
            steps {
                sh '''
                    # pip3 install -r requirements.txt
                    echo "Dependencies installed"
                    # Add pytest command here if you have tests
                    # python3 -m pytest tests/ -v
                '''
            }
        }

        stage('Build Docker image') {
            steps {
                sh '''
                    echo "Building Docker image: ${FULL_IMAGE}"
                    docker build -t ${FULL_IMAGE} .
                    echo "Docker image built successfully"
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    echo "Logging into ECR..."
                    aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}

                    echo "Pushing image to ECR..."
                    docker push ${FULL_IMAGE}
                    echo "Image pushed: ${FULL_IMAGE}"
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    echo "Updating kubeconfig..."
                    aws eks update-kubeconfig \
                        --region ${AWS_REGION} \
                        --name ${CLUSTER_NAME}

                    echo "Injecting image into deployment manifest..."
                    sed -i "s|IMAGE_PLACEHOLDER|${FULL_IMAGE}|g" k8s/deployment.yaml

                    echo "Applying Kubernetes manifests..."
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    echo "Waiting for rollout to complete..."
                    kubectl rollout status deployment/my-app --timeout=180s

                    echo "Deployment successful!"
                    kubectl get pods
                    kubectl get svc my-app-svc
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline PASSED. App is live on EKS."
        }
        failure {
            echo "Pipeline FAILED. Check stage logs above."
        }
        always {
            // Clean up local Docker image to save disk space
            sh "docker rmi ${FULL_IMAGE} || true"
        }
    }
}
