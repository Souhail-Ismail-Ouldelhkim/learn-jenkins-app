pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = '98205f75-7686-46bc-9b5d-4d9149cca3b0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        CI_ENVIRONMENT_URL = 'https://my-jenkins-formation-deploy-netlify.netlify.app'
    }

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

        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.50.0'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: false,
                                keepAll: false,
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Playwright Report Locally',
                                reportTitles: '',
                                useWrapperFileDirectly: true
                            ])
                        }
                    }
                }
            }
        }

        stage('Deploy - Netlify - staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status --auth=$NETLIFY_AUTH_TOKEN
                    node_modules/.bin/netlify deploy \
                        --dir=build \
                        --no-build \
                        --site=$NETLIFY_SITE_ID

                    echo "---Contenu de fichier------"

                '''
                script {
                    def deployUrl = sh(
                script: "grep -o 'https://[a-zA-Z0-9-]*\\.netlify\\.app' deploy-output.txt | head -1",
                returnStdout: true
            ).trim()
                    env.staging_URL = deployUrl
                    echo "staging URL capturée: ${env.staging_URL}"
                    echo'Znything'
                }
            }
        }

        stage('E2E - staging') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.50.0'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${env.staging_URL}"
            }
            steps {
                sh '''
            npx playwright test --reporter=html
        '''
            }
            post {
                always {
                    publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: false,
                reportDir: 'playwright-report',
                reportFiles: 'index.html',
                reportName: 'Playwright staging',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])
                }
            }
        }

        stage('approval')
         {
            steps
            {
                timeout(time: 10, unit: 'SECONDS')
                {
                    input message: 'Ready to deploy ???', ok: 'Yes, I\'m sure to deploy'
                }
            }
        }

        stage('Deploy - Netlify - Production') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy \
                        --dir=build \
                        --prod \
                        --no-build \
                        --site=$NETLIFY_SITE_ID \
                        --auth=$NETLIFY_AUTH_TOKEN
                '''
            }
        }

        stage('E2E - Production') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.50.0'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${env.CI_ENVIRONMENT_URL}" // URL fixe depuis le top du pipeline
            }
            steps {
                sh '''
            npx playwright test --reporter=html
        '''
            }
            post {
                always {
                    publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: false,
                reportDir: 'playwright-report',
                reportFiles: 'index.html',
                reportName: 'Playwright Production',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])
                }
            }
        }
    }
}
