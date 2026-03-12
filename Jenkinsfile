pipeline {
    agent any

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build 
                    ls -la
                '''
            }
        }

        stage('Test'){
            agent {
                docker {
                    images 'node:18-alpine'
                    reuseNode true
                }
                step {
                    sh '''
                      ls -la
                      echo " Test Application " 
                      npm test
                      ls -la
                    '''
                }
            }
        }
    }
}
