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

		stage('Deploy to Remote Kind Kubernetes Cluster') {
 	    	steps {
				echo 'Deploying NEXVION to Kubernetes.....'
			
				sshagent(credentials: ['kind-ssh-key'])
				{
        			sh '''
		    			ssh ubuntu@3.111.217.173 "mkdir -p /home/ubuntu/k8s"
						scp -r k8s/. ubuntu@3.111.217.173:/home/ubuntu/k8s/
						ssh ubuntu@3.111.217.173 " 
		    			kubectl apply -f k8s/namespace.yml
		    			kubectl apply -f k8s/deployment.yml
            	    	kubectl apply -f k8s/service.yml
                    	kubectl apply -f k8s/ingress.yml
		    			kubectl set image deployment/nexvion nexvion=${DOCKERHUB_USERNAME}/nexvion-web:${BUILD_NUMBER} -n nexvion
		    			kubectl rollout status deployment/nexvion -n nexvion --timeout=180s 
						"
					'''
				}
			} 
		}	

		stage('Application Health Check') {
    	    steps {
        		sh '''
        	    	echo "Running health check..."

           	    	kubectl run nexvion-healthcheck --rm -i --restart=Never --image=curlimages/curl:latest -n nexvion -- curl -f http://nexvion-service
        		'''
				
    		}	
	   }
    
    }

    post {
        always {
            sh '''
                docker rm -f nexvion-test-${BUILD_NUMBER} > /dev/null 2&1 || true
                docker rmi nexvion-test-${BUILD_NUMBER} > /dev/null 2&1 || true
                docker rmi ${DOCKER_USERNAME}/nexvion-web:${BUILD_NUMBER} > /dev/null 2&1 || true
                docker rmi ${DOCKER_USERNAME}/nexvion-web:latest > /dev/null 2&1 || true
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
