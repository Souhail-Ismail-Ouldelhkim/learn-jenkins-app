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

        stage ('Tests') {
            parallel {
                          stage('Test'){
             agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
               steps {
                    sh '''
                      # this is just Test
                      test -f build/index.html
                      npm test
                    '''
               }

                post {
    always {
        junit 'jest-results/junit.xml'
    }
   }

        }

        stage('E2E '){
             agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.50.0-noble'
                    reuseNode true
                                         // args '-u root:root' 
                } 
            }
               steps {
                    sh '''
                      # this is just Test
                      # npm install -g serve  
                      # this command need a root on peut installer localement et faire npx serve 
                      # playwright a besoin d'un url pour Naviguer
                      # Probleme root dans workspace
                      node_modules/.bin/serve -s build & 
   
                      npx playwright test --reporter=html

                    '''
               }
        }
            } 

 post {
    always {
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
    }
   }

        }
    }
}