pipeline {

    agent any
    

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                sh '''
                    test -f Dockerfile
                    test -f docker-compose.yml
                    test -f index.html
                '''
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t nexvion-web:${BUILD_NUMBER} .'
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker run -d --name nexvion-test-${BUILD_NUMBER} -p 80:80 nexvion-web:${BUILD_NUMBER}
                    sleep 5
                    curl -f http://localhost:80
                '''
            }
        }


        stage('Image Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL nexvion-web:${BUILD_NUMBER}'
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'

                withCredentials([usernamePassword(credentialsId: 'docker_hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) 
                {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u ${DOCKER_USERNAME} --password-stdin
                        docker tag nexvion-web:${BUILD_NUMBER} ${DOCKER_USERNAME}/nexvion-web:${BUILD_NUMBER}
                        docker tag nexvion-web:${BUILD_NUMBER} ${DOCKER_USERNAME}/nexvion-web:latest
                        docker push ${DOCKER_USERNAME}/nexvion-web:latest
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
                docker rm -f nexvion-test-${BUILD_NUMBER} 2>/dev/null || true
            '''
        }

        success {
            echo 'NEXVION CI pipeline completed successfully.'
        }

        failure {
            echo 'NEXVION CI pipeline failed. Check the console log.'
        }
    }
    
}
